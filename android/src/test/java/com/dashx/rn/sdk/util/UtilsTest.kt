package com.dashx.rn.sdk.util

import com.facebook.react.bridge.JavaOnlyArray
import com.facebook.react.bridge.JavaOnlyMap
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReadableType
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.add
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.double
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.put
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

/**
 * Pure-JVM unit tests for the conversion helpers in [Utils.kt]. Swaps
 * [WritableFactory] over to `JavaOnlyMap` / `JavaOnlyArray` in [setUp] so
 * the JNI-backed `WritableNative*` constructors don't execute — those need
 * the Android runtime and would crash a plain JUnit run.
 *
 * `JavaOnlyMap` / `JavaOnlyArray` are pure-Java RN-provided stand-ins that
 * implement the full `WritableMap` / `WritableArray` contracts, so their
 * `.get*` accessors let the assertions inspect everything the helpers wrote.
 */
class UtilsTest {

    @Before
    fun setUp() {
        WritableFactory.createMap = { JavaOnlyMap() }
        WritableFactory.createArray = { JavaOnlyArray() }
    }

    @After
    fun tearDown() {
        // Not strictly necessary (tests don't share state with prod) but keeps
        // the invariant clear: the object factory is production-pointed at
        // rest, test-pointed only inside a test method.
        WritableFactory.createMap = { error("WritableNativeMap not available in JVM tests") }
        WritableFactory.createArray = { error("WritableNativeArray not available in JVM tests") }
    }

    // ---------------------------------------------------------------------
    // convertMapToJson: ReadableMap → kotlinx JsonObject
    // ---------------------------------------------------------------------

    @Test
    fun convertMapToJson_returnsNullForNullInput() {
        assertNull(convertMapToJson(null))
    }

    @Test
    fun convertMapToJson_emptyMapProducesEmptyJsonObject() {
        val json = convertMapToJson(JavaOnlyMap())
        assertEquals(0, json!!.size)
    }

    @Test
    fun convertMapToJson_primitives() {
        val input = JavaOnlyMap().apply {
            putBoolean("flag", true)
            putDouble("n", 3.14)
            putString("s", "hello")
            putNull("nothing")
        }

        val json = convertMapToJson(input)!!

        assertEquals(true, json["flag"]!!.jsonPrimitive.boolean)
        assertEquals(3.14, json["n"]!!.jsonPrimitive.double, 0.0)
        assertEquals("hello", json["s"]!!.jsonPrimitive.content)
        assertTrue(
            "null RN value should land as JsonNull",
            json["nothing"] is JsonNull
        )
    }

    @Test
    fun convertMapToJson_nestedMap() {
        val inner = JavaOnlyMap().apply { putString("k", "v") }
        val input = JavaOnlyMap().apply { putMap("child", inner) }

        val json = convertMapToJson(input)!!
        val childJson = json["child"]!!.jsonObject

        assertEquals("v", childJson["k"]!!.jsonPrimitive.content)
    }

    @Test
    fun convertMapToJson_nestedArray() {
        val inner = JavaOnlyArray().apply {
            pushString("a")
            pushDouble(1.0)
        }
        val input = JavaOnlyMap().apply { putArray("xs", inner) }

        val json = convertMapToJson(input)!!
        val arr = json["xs"]!!.jsonArray

        assertEquals(2, arr.size)
        assertEquals("a", arr[0].jsonPrimitive.content)
        assertEquals(1.0, arr[1].jsonPrimitive.double, 0.0)
    }

    // ---------------------------------------------------------------------
    // convertArrayToJson: ReadableArray → kotlinx JsonArray
    // ---------------------------------------------------------------------

    @Test
    fun convertArrayToJson_returnsNullForNullInput() {
        assertNull(convertArrayToJson(null))
    }

    @Test
    fun convertArrayToJson_mixedPrimitives() {
        val input = JavaOnlyArray().apply {
            pushBoolean(false)
            pushDouble(42.0)
            pushString("foo")
            pushNull()
        }

        val arr = convertArrayToJson(input)!!

        assertEquals(4, arr.size)
        assertFalse(arr[0].jsonPrimitive.boolean)
        assertEquals(42.0, arr[1].jsonPrimitive.double, 0.0)
        assertEquals("foo", arr[2].jsonPrimitive.content)
        assertTrue(arr[3] is JsonNull)
    }

    // ---------------------------------------------------------------------
    // convertReadableArrayToKJsonList: ReadableArray[ReadableMap] → List<JsonObject>
    // ---------------------------------------------------------------------

    @Test
    fun convertReadableArrayToKJsonList_filtersNonMapEntries() {
        val input = JavaOnlyArray().apply {
            pushMap(JavaOnlyMap().apply { putString("a", "1") })
            pushString("not-a-map")
            pushMap(JavaOnlyMap().apply { putString("b", "2") })
        }

        val list = convertReadableArrayToKJsonList(input)!!

        assertEquals(2, list.size)
        assertEquals("1", list[0]["a"]!!.jsonPrimitive.content)
        assertEquals("2", list[1]["b"]!!.jsonPrimitive.content)
    }

    @Test
    fun convertReadableArrayToKJsonList_returnsNullForEmpty() {
        assertNull(convertReadableArrayToKJsonList(null))
        assertNull(convertReadableArrayToKJsonList(JavaOnlyArray()))
    }

    // ---------------------------------------------------------------------
    // convertJsonToMap: kotlinx JsonObject → WritableMap
    // ---------------------------------------------------------------------

    @Test
    fun convertJsonToMap_returnsNullForNullInput() {
        assertNull(convertJsonToMap(null))
    }

    @Test
    fun convertJsonToMap_primitives() {
        val input = buildJsonObject {
            put("flag", true)
            put("n", 3.14)
            put("s", "hello")
            put("nothing", JsonNull)
        }

        val map = convertJsonToMap(input) as JavaOnlyMap

        assertEquals(true, map.getBoolean("flag"))
        assertEquals(3.14, map.getDouble("n"), 0.0)
        assertEquals("hello", map.getString("s"))
        assertTrue(
            "JsonNull should land as RN null",
            map.isNull("nothing")
        )
    }

    @Test
    fun convertJsonToMap_nestedObject() {
        val input = buildJsonObject {
            put("outer", buildJsonObject {
                put("inner", "deep")
            })
        }

        val map = convertJsonToMap(input) as JavaOnlyMap
        val inner = map.getMap("outer") as JavaOnlyMap

        assertEquals("deep", inner.getString("inner"))
    }

    @Test
    fun convertJsonToMap_nestedArray() {
        val input = buildJsonObject {
            put("xs", buildJsonArray {
                add("a")
                add(1.0)
                add(JsonNull)
            })
        }

        val map = convertJsonToMap(input) as JavaOnlyMap
        val arr = map.getArray("xs") as JavaOnlyArray

        assertEquals(3, arr.size())
        assertEquals("a", arr.getString(0))
        assertEquals(1.0, arr.getDouble(1), 0.0)
        assertTrue(arr.isNull(2))
    }

    // ---------------------------------------------------------------------
    // Round-trip: ReadableMap → JsonObject → WritableMap
    // ---------------------------------------------------------------------

    @Test
    fun roundTrip_preservesEverything() {
        val input = JavaOnlyMap().apply {
            putString("str", "hello")
            putDouble("num", 12.5)
            putBoolean("bool", true)
            putNull("nil")
            putMap(
                "nested",
                JavaOnlyMap().apply { putString("k", "v") }
            )
            putArray(
                "arr",
                JavaOnlyArray().apply {
                    pushString("a")
                    pushDouble(1.0)
                }
            )
        }

        val json = convertMapToJson(input)!!
        val roundTripped = convertJsonToMap(json) as JavaOnlyMap

        assertEquals("hello", roundTripped.getString("str"))
        assertEquals(12.5, roundTripped.getDouble("num"), 0.0)
        assertEquals(true, roundTripped.getBoolean("bool"))
        assertTrue(roundTripped.isNull("nil"))
        assertEquals("v", (roundTripped.getMap("nested") as JavaOnlyMap).getString("k"))
        val arr = roundTripped.getArray("arr") as JavaOnlyArray
        assertEquals("a", arr.getString(0))
        assertEquals(1.0, arr.getDouble(1), 0.0)
    }

    // ---------------------------------------------------------------------
    // Regression: pre-migration crashes
    // ---------------------------------------------------------------------

    /**
     * The Gson-based `convertJsonToMap` crashed on JSON nulls because
     * `value.asJsonPrimitive.isBoolean` throws when `value is JsonNull`.
     * The kotlinx rewrite explicitly branches `is JsonNull` → `putNull(key)`.
     */
    @Test
    fun convertJsonToMap_doesNotCrashOnNestedJsonNull() {
        val input = buildJsonObject {
            put("outer", buildJsonObject {
                put("inner", JsonNull)
            })
        }

        val map = convertJsonToMap(input) as JavaOnlyMap
        val nested = map.getMap("outer") as JavaOnlyMap
        assertTrue(nested.isNull("inner"))
    }

    /**
     * Pre-migration `saveStoredPreferences` NPE'd on a null preferenceData
     * because `MapUtil.toJSONElement(null).toString()` dereferenced null.
     * The new path is `convertMapToJson(null) ?: buildJsonObject {}` which
     * can't NPE — null input returns a null `JsonObject?`, caller
     * substitutes an empty object.
     */
    @Test
    fun convertMapToJson_nullInputIsSafe() {
        val fallback: JsonObject = convertMapToJson(null) ?: buildJsonObject { }
        assertEquals(0, fallback.size)
    }
}
