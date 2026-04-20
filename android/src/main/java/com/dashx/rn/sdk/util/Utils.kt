@file:JvmName("Utils")

package com.dashx.rn.sdk.util

import com.facebook.react.bridge.*
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.add
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.put

// JSON conversion helpers between React Native's ReadableMap/ReadableArray/
// WritableMap/WritableArray types and kotlinx.serialization's JsonObject/
// JsonArray. Kept kotlinx-only on purpose — the DashX Android SDK uses
// kotlinx-serialization end-to-end (see `mapScalar("JSON", "kotlinx...JsonObject")`
// in dashx-android/dashx/build.gradle), so threading a single JSON library
// through the bridge avoids string round-trips and the type-confusion class
// of bugs that arose when Gson/org.json/kotlinx all coexisted.

/**
 * Factory seam for Writable instances. Production defaults to the JNI-backed
 * `WritableNativeMap` / `WritableNativeArray`. JVM unit tests swap these to
 * `JavaOnlyMap` / `JavaOnlyArray` (pure-Java, no JNI) — the native writables
 * crash in a plain JUnit harness because their constructors call into
 * `initHybrid()`. `internal` visibility keeps the seam invisible to SDK
 * consumers.
 */
internal object WritableFactory {
    var createMap: () -> WritableMap = { WritableNativeMap() }
    var createArray: () -> WritableArray = { WritableNativeArray() }
}

/**
 * Convert a [ReadableMap] (RN → native boundary) into a kotlinx [JsonObject].
 * Returns `null` when [readableMap] is null, so callers can distinguish
 * "absent" from "empty".
 *
 * Numbers are coerced to [Double] on purpose — RN has a single JS `Number`
 * type and the DashX backend's JSON scalars are agnostic to int/double.
 */
fun convertMapToJson(readableMap: ReadableMap?): JsonObject? {
    val iterator = readableMap?.keySetIterator() ?: return null
    return buildJsonObject {
        while (iterator.hasNextKey()) {
            val key = iterator.nextKey()
            when (readableMap.getType(key)) {
                ReadableType.Null -> put(key, JsonNull)
                ReadableType.Boolean -> put(key, readableMap.getBoolean(key))
                ReadableType.Number -> put(key, readableMap.getDouble(key))
                ReadableType.String -> put(key, readableMap.getString(key))
                ReadableType.Map -> put(key, convertMapToJson(readableMap.getMap(key)) ?: JsonNull)
                ReadableType.Array -> put(key, convertArrayToJson(readableMap.getArray(key)) ?: JsonNull)
            }
        }
    }
}

/**
 * Convert a [ReadableArray] into a kotlinx [JsonArray]. Mirrors
 * [convertMapToJson] — null in, null out.
 */
fun convertArrayToJson(readableArray: ReadableArray?): JsonArray? {
    if (readableArray == null) return null
    return buildJsonArray {
        for (i in 0 until readableArray.size()) {
            when (readableArray.getType(i)) {
                ReadableType.Null -> add(JsonNull)
                ReadableType.Boolean -> add(readableArray.getBoolean(i))
                ReadableType.Number -> add(readableArray.getDouble(i))
                ReadableType.String -> add(readableArray.getString(i))
                ReadableType.Map -> add(convertMapToJson(readableArray.getMap(i)) ?: JsonNull)
                ReadableType.Array -> add(convertArrayToJson(readableArray.getArray(i)) ?: JsonNull)
            }
        }
    }
}

/**
 * Convert a [ReadableArray] of maps into a list of [JsonObject]s. Used for
 * the `fields` / `include` / `exclude` / `order` option arrays on
 * `fetchRecord` / `searchRecords`. Non-map entries are silently dropped to
 * preserve the behaviour of the pre-migration helper.
 */
fun convertReadableArrayToKJsonList(readableArray: ReadableArray?): List<JsonObject>? {
    if (readableArray == null || readableArray.size() == 0) return null
    return (0 until readableArray.size()).mapNotNull { i ->
        if (readableArray.getType(i) == ReadableType.Map) {
            readableArray.getMap(i)?.let { convertMapToJson(it) }
        } else {
            null
        }
    }.ifEmpty { null }
}

/**
 * Convert a kotlinx [JsonObject] (native → RN boundary) into a [WritableMap].
 * Returns `null` when [jsonObject] is null.
 *
 * Numeric primitives are coerced to [Double] (`putDouble`) to match JS's
 * single `Number` type. JSON nulls map to `putNull(key)`. Non-finite /
 * non-numeric primitives fall back to string form.
 */
fun convertJsonToMap(jsonObject: JsonObject?): WritableMap? {
    jsonObject ?: return null
    val map: WritableMap = WritableFactory.createMap()
    for ((key, element) in jsonObject) {
        when (element) {
            is JsonNull -> map.putNull(key)
            is JsonPrimitive -> putPrimitive(map, key, element)
            is JsonObject -> map.putMap(key, convertJsonToMap(element))
            is JsonArray -> map.putArray(key, convertJsonToArray(element))
        }
    }
    return map
}

/**
 * Convert a kotlinx [JsonArray] into a [WritableArray]. Mirrors
 * [convertJsonToMap]. Null-safe.
 */
fun convertJsonToArray(jsonArray: JsonArray?): WritableArray? {
    jsonArray ?: return null
    val array: WritableArray = WritableFactory.createArray()
    for (element in jsonArray) {
        when (element) {
            is JsonNull -> array.pushNull()
            is JsonPrimitive -> pushPrimitive(array, element)
            is JsonObject -> array.pushMap(convertJsonToMap(element))
            is JsonArray -> array.pushArray(convertJsonToArray(element))
        }
    }
    return array
}

// Shared primitive dispatch — keeps the two public functions free of repeated
// isString / booleanOrNull / doubleOrNull ladders. [primitive] is guaranteed
// not to be [JsonNull] by the caller (JsonNull is a subtype of JsonPrimitive).
private fun putPrimitive(map: WritableMap, key: String, primitive: JsonPrimitive) {
    when {
        primitive.isString -> map.putString(key, primitive.content)
        primitive.booleanOrNull != null -> map.putBoolean(key, primitive.booleanOrNull!!)
        primitive.doubleOrNull != null -> map.putDouble(key, primitive.doubleOrNull!!)
        else -> map.putString(key, primitive.content)
    }
}

private fun pushPrimitive(array: WritableArray, primitive: JsonPrimitive) {
    when {
        primitive.isString -> array.pushString(primitive.content)
        primitive.booleanOrNull != null -> array.pushBoolean(primitive.booleanOrNull!!)
        primitive.doubleOrNull != null -> array.pushDouble(primitive.doubleOrNull!!)
        else -> array.pushString(primitive.content)
    }
}

/**
 * Generic `Map<*, *>` → `WritableMap` converter. Preserved from the original
 * [Utils] surface — no JSON libraries involved, but used by callers that
 * need to hand arbitrary Kotlin maps to the RN bridge.
 */
@JvmOverloads
@Throws(Exception::class)
fun convertToWritableMap(
    map: Map<*, *>,
    blacklist: List<String> = emptyList<String>()
): WritableMap {
    val writableMap: WritableMap = WritableFactory.createMap()
    val iterator: Iterator<String> = map.keys.iterator() as Iterator<String>
    while (iterator.hasNext()) {
        val key = iterator.next()

        if (blacklist.contains(key)) {
            continue
        }

        when (val value = map[key]) {
            is Boolean -> writableMap.putBoolean(key, value)
            is Int -> writableMap.putInt(key, value)
            is Double -> writableMap.putDouble(key, value)
            is String -> writableMap.putString(key, value)
            else -> writableMap.putString(key, value.toString())
        }
    }
    return writableMap
}

// --- ReadableMap convenience accessors (unchanged from the previous Utils). ---

fun ReadableMap.getMapIfPresent(key: String): ReadableMap? {
    return if (this.hasKey(key)) this.getMap(key) else null
}

fun ReadableMap.getIntIfPresent(key: String): Int? {
    return if (this.hasKey(key)) this.getInt(key) else null
}

fun ReadableMap.getStringIfPresent(key: String): String? {
    return if (this.hasKey(key)) this.getString(key) else null
}

fun ReadableMap.getBooleanIfPresent(key: String): Boolean? {
    return if (this.hasKey(key)) this.getBoolean(key) else null
}
