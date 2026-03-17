package com.dashx.rn.sdk

import com.dashx.android.DashXLibraryInfoProvider

class ReactNativeLibraryInfoProvider : DashXLibraryInfoProvider {
    override val name = "@dashx/react-native"
    override val version: String = BuildConfig.VERSION_NAME
}
