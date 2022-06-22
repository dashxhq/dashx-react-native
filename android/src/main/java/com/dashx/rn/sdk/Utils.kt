@file:JvmName("Utils")

package com.dashx.rn.sdk

import com.facebook.react.bridge.*
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import org.json.JSONException

@Throws(JSONException::class)
fun convertMapToJson(readableMap: ReadableMap?): JsonObject? {
    val iterator = readableMap?.keySetIterator() ?: return null
    val jsonObject = JsonObject()
    while (iterator.hasNextKey()) {
        val key = iterator.nextKey()
        when (readableMap.getType(key)) {
            ReadableType.Null -> jsonObject.add(key, null)
            ReadableType.Boolean -> jsonObject.addProperty(key, readableMap.getBoolean(key))
            ReadableType.Number -> jsonObject.addProperty(key, readableMap.getDouble(key))
            ReadableType.String -> jsonObject.addProperty(key, readableMap.getString(key))
            ReadableType.Map -> jsonObject.add(key, convertMapToJson(readableMap.getMap(key)))
            ReadableType.Array -> jsonObject.add(key, convertArrayToJson(readableMap.getArray(key)))
        }
    }
    return jsonObject
}

@Throws(JSONException::class)
fun convertArrayToJson(readableArray: ReadableArray?): JsonArray {
    val jsonArray = JsonArray()
    for (i in 0 until readableArray!!.size()) {
        when (readableArray.getType(i)) {
            ReadableType.Null -> {
            }
            ReadableType.Boolean -> jsonArray.add(readableArray.getBoolean(i))
            ReadableType.Number -> jsonArray.add(readableArray.getDouble(i))
            ReadableType.String -> jsonArray.add(readableArray.getString(i))
            ReadableType.Map -> jsonArray.add(convertMapToJson(readableArray.getMap(i)))
            ReadableType.Array -> jsonArray.add(convertArrayToJson(readableArray.getArray(i)))
        }
    }
    return jsonArray
}

@JvmOverloads
@Throws(Exception::class)
fun convertToWritableMap(
    map: Map<*, *>,
    blacklist: List<String> = emptyList<String>()
): WritableMap {
    val writableMap: WritableMap = WritableNativeMap()
    val iterator: Iterator<String> = map.keys.iterator() as Iterator<String>
    while (iterator.hasNext()) {
        val key = iterator.next()

        if (blacklist.contains(key)) {
            continue;
        }

        when (val value = map[key]) {
            is Boolean -> writableMap.putBoolean(key, (value as Boolean?)!!)
            is Int -> writableMap.putInt(key, (value as Int?)!!)
            is Double -> writableMap.putDouble(key, (value as Double?)!!)
            is String -> writableMap.putString(key, value as String?)
            else -> writableMap.putString(key, value.toString())
        }
    }
    return writableMap
}

@Throws(JSONException::class)
fun convertJsonToMap(jsonObject: JsonObject?): WritableMap? {
    val entries = jsonObject?.entrySet() ?: return null
    val map: WritableMap = WritableNativeMap()
    for ((key) in entries) {
        val value = jsonObject[key]

        if (value is JsonObject) {
            map.putMap(key, convertJsonToMap(value))
        } else if (value is JsonArray) {
            map.putArray(key, convertJsonToArray(value))
        } else if (value.asJsonPrimitive.isBoolean) {
            map.putBoolean(key, value.asBoolean)
        } else if (value.asJsonPrimitive.isNumber) {
            map.putDouble(key, value.asDouble)
        } else if (value.asJsonPrimitive.isString) {
            map.putString(key, value.asString)
        } else {
            map.putString(key, value.toString())
        }
    }
    return map
}

@Throws(JSONException::class)
fun convertJsonToArray(jsonArray: JsonArray): WritableArray? {
    val array: WritableArray = WritableNativeArray()
    for (i in 0 until jsonArray.size()) {
        val value = jsonArray[i]
        if (value is JsonObject) {
            array.pushMap(convertJsonToMap(value))
        } else if (value is JsonArray) {
            array.pushArray(convertJsonToArray(value))
        } else if (value.asJsonPrimitive.isBoolean) {
            array.pushBoolean(value.asBoolean)
        } else if (value.asJsonPrimitive.isNumber) {
            array.pushDouble(value.asDouble)
        } else if (value.asJsonPrimitive.isString) {
            array.pushString(value.asString)
        } else {
            array.pushString(value.toString())
        }
    }
    return array
}

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
