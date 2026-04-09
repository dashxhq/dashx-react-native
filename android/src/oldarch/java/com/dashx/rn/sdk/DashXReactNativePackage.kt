package com.dashx.rn.sdk

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

class DashXReactNativePackage : BaseReactPackage() {
    override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
        return if (name == DashXReactNativeModuleImpl.NAME) {
            DashXReactNativeModule(reactContext)
        } else {
            null
        }
    }

    override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
        return ReactModuleInfoProvider {
            mapOf(
                DashXReactNativeModuleImpl.NAME to ReactModuleInfo(
                    DashXReactNativeModuleImpl.NAME,
                    DashXReactNativeModuleImpl.NAME,
                    false, // canOverrideExistingModule
                    false, // needsEagerInit
                    false, // hasConstants
                    false, // isCxxModule
                    false  // isTurboModule
                )
            )
        }
    }
}
