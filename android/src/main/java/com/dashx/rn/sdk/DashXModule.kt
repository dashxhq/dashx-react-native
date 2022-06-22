package com.dashx.rn.sdk

import com.facebook.react.bridge.*
import com.dashx.sdk.DashXLog
import com.google.android.gms.tasks.OnCompleteListener
import com.google.firebase.messaging.FirebaseMessaging

class DashXModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    private val tag = DashXModule::class.java.simpleName
    private var interceptor: DashXClientInterceptor = DashXClientInterceptor.instance


    override fun getName(): String {
        return "DashX"
    }

    @ReactMethod
    fun setLogLevel(logLevel: Int) {
        DashXLog.setLogLevel(logLevel)
    }

    @ReactMethod
    fun setup(options: ReadableMap) {
        interceptor.createDashXClient(
            reactContext,
            options.getString("publicKey")!!,
            options.getStringIfPresent("baseUri"),
            options.getStringIfPresent("targetEnvironment"),
            options.getStringIfPresent("targetInstallation")
        )
        interceptor.getDashXClient()?.generateAnonymousUid()

        if (options.hasKey("trackAppLifecycleEvents") && options.getBoolean("trackAppLifecycleEvents")) {
            DashXExceptionHandler.enable()
            DashXActivityLifecycleCallbacks.enableActivityLifecycleTracking(reactContext.applicationContext)
        }

        if (options.hasKey("trackScreenViews") && options.getBoolean("trackScreenViews")) {
            DashXActivityLifecycleCallbacks.enableScreenTracking(reactContext.applicationContext)
        }

        FirebaseMessaging.getInstance().getToken()
            .addOnCompleteListener(OnCompleteListener { task ->
                if (!task.isSuccessful) {
                    DashXLog.d(tag, "FirebaseMessaging.getInstance().getToken() failed: $task.exception")
                    return@OnCompleteListener
                }

                val token = task.getResult()
                token?.let { it -> interceptor.getDashXClient()?.setDeviceToken(it) }
                DashXLog.d(tag, "Firebase Initialised with: $token")
            });
    }

    @ReactMethod
    fun identify(uid: String?, options: ReadableMap?) {
        val optionsHashMap = options?.toHashMap()
        interceptor.getDashXClient()?.identify(uid, optionsHashMap as HashMap<String, String>?)
    }

    @ReactMethod
    fun reset() {
        interceptor.getDashXClient()?.reset()
    }

    @ReactMethod
    fun track(event: String, data: ReadableMap?) {
        val jsonData = try {
            data?.toHashMap() as HashMap<String, String>
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            return
        }

        interceptor.getDashXClient()?.track(event, jsonData)
    }

    @ReactMethod
    fun screen(screenName: String, data: ReadableMap?) {
        interceptor.getDashXClient()?.screen(screenName, data?.toHashMap() as HashMap<String, String>)
    }

    @ReactMethod
    fun setIdentityToken(identityToken: String) {
        interceptor.getDashXClient()?.setIdentityToken(identityToken)
    }

    @ReactMethod
    fun fetchContent(urn: String, options: ReadableMap?, promise: Promise) {
        interceptor.getDashXClient()?.fetchContent(
            urn,
            options?.getBooleanIfPresent("preview"),
            options?.getStringIfPresent("language"),
            options?.getArray("fields")?.toArrayList() as List<String>?,
            options?.getArray("include")?.toArrayList() as List<String>?,
            options?.getArray("exclude")?.toArrayList() as List<String>?,
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

        interceptor.getDashXClient()?.searchContent(
            contentType,
            options?.getString("returnType") ?: "all",
            jsonFilter,
            jsonOrder,
            options?.getIntIfPresent("limit"),
            options?.getBooleanIfPresent("preview"),
            options?.getStringIfPresent("language"),
            options?.getArray("fields")?.toArrayList() as List<String>?,
            options?.getArray("include")?.toArrayList() as List<String>?,
            options?.getArray("exclude")?.toArrayList() as List<String>?,
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

        interceptor.getDashXClient()?.addItemToCart(
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
        interceptor.getDashXClient()?.fetchCart(
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
        interceptor.getDashXClient()?.subscribe()
    }
}
