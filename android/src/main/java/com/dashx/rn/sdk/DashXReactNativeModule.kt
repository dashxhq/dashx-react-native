package com.dashx.rn.sdk

import com.dashx.rn.sdk.util.*
import com.facebook.react.bridge.*
import com.dashx.sdk.DashXClient as DashX
import com.dashx.sdk.DashXLog
import java.io.File
import kotlin.collections.HashMap

class DashXReactNativeModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    private val tag = DashXReactNativeModule::class.java.simpleName
    private var dashXClient: DashX? = null

    override fun getName(): String {
        return "DashXReactNative"
    }

    @ReactMethod
    fun setLogLevel(logLevel: Int) {
        DashXLog.setLogLevel(logLevel)
    }

    @ReactMethod
    fun setup(options: ReadableMap) {
        dashXClient = DashX.createInstance(
            reactContext, 
            options.getString("publicKey")!!,
            options.getStringIfPresent("baseUri")!!,
            options.getStringIfPresent("targetEnvironment")
        )
    }

    @ReactMethod
    fun identify(uid: String?, options: ReadableMap?) {
        val optionsHashMap = MapUtil.toMap(options)
        dashXClient?.identify(optionsHashMap as HashMap<String, String>?)
    }

    @ReactMethod
    fun reset() {
        dashXClient?.reset()
    }

    @ReactMethod
    fun track(event: String, data: ReadableMap?) {
        val jsonData = try {
            MapUtil.toMap(data) as HashMap<String, String>
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            return
        }

        dashXClient?.track(event, jsonData)
    }

    @ReactMethod
    fun screen(screenName: String, data: ReadableMap?) {
        dashXClient?.screen(screenName, MapUtil.toMap(data) as HashMap<String, String>)
    }

    @ReactMethod
    fun fetchContent(urn: String, options: ReadableMap?, promise: Promise) {
        dashXClient?.fetchContent(
            urn,
            options?.getBooleanIfPresent("preview"),
            options?.getStringIfPresent("language"),
            listOf(options?.getArray("fields")) as List<String>?,
            listOf(options?.getArray("include")) as List<String>?,
            listOf(options?.getArray("exclude")) as List<String>?,
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = {
                promise.resolve(convertJsonToMap(it))
            }
        )
    }

    @ReactMethod
    fun searchContent(contentType: String, options: ReadableMap?, promise: Promise) {
        val jsonFilter = try {
            convertMapToJson(options?.getMap("filter"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            throw Exception("Encountered an error while parsing filter")
        }

        val jsonOrder = try {
            convertMapToJson(options?.getMap("order"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            throw Exception("Encountered an error while parsing order")
        }

        dashXClient?.searchContent(
            contentType,
            options?.getString("returnType") ?: "all",
            jsonFilter,
            jsonOrder,
            options?.getIntIfPresent("limit"),
            options?.getBooleanIfPresent("preview"),
            options?.getStringIfPresent("language"),
            listOf(options?.getArray("fields")) as List<String>?,
            listOf(options?.getArray("include")) as List<String>?,
            listOf(options?.getArray("exclude")) as List<String>?,
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                val readableArray = Arguments.createArray()
                content.forEach {
                    readableArray.pushMap(convertJsonToMap(it))
                }
                promise.resolve(readableArray)
            }
        )
    }

    @ReactMethod
    fun addItemToCart(
        itemId: String,
        pricingId: String,
        quantity: String,
        reset: Boolean? = false,
        custom: ReadableMap? = null,
        promise: Promise
    ) {
        val jsonCustom = try {
            convertMapToJson(custom)
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            throw Exception("Encountered an error while parsing custom")
        }

        dashXClient?.addItemToCart(
            itemId,
            pricingId,
            quantity,
            reset ?: false,
            jsonCustom,
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(content))
            }
        )
    }

    @ReactMethod
    fun fetchCart(promise: Promise) {
        dashXClient?.fetchCart(
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(content))
            }
        )
    }

    @ReactMethod
    fun fetchStoredPreferences(promise: Promise) {
        dashXClient?.fetchStoredPreferences(
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(content))
            }
        )
    }

    @ReactMethod
    fun uploadExternalAsset(
        file: ReadableMap, 
        externalColumnId: String, 
        promise: Promise
    ) {
        val jsonFile = try {
            convertMapToJson(file)
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            throw Exception("Encountered an error while parsing file")
        }

        val fileObject = File(jsonFile?.get("uri") as String)

        dashXClient?.uploadExternalAsset(
            fileObject,
            externalColumnId,
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(content))
            }
        )
    }

    @ReactMethod
    fun subscribe() {
        dashXClient?.subscribe()
    }
}
