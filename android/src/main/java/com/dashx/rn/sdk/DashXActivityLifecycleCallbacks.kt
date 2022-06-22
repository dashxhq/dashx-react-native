package com.dashx.rn.sdk

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import com.facebook.react.bridge.Arguments

class DashXActivityLifecycleCallbacks : Application.ActivityLifecycleCallbacks {
    private val dashXClient = DashXClientInterceptor.instance.getDashXClient()
    private var startSession = System.currentTimeMillis().toDouble()

    init {
        dashXClient?.trackAppStarted()
    }

    override fun onActivityPaused(activity: Activity) {
        if (!lifecycleTrackingEnabled) {
            return
        }

        dashXClient?.trackAppSession(System.currentTimeMillis().toDouble() - startSession)
    }

    override fun onActivityResumed(activity: Activity) {
        if (!lifecycleTrackingEnabled) {
            return
        }

        startSession = System.currentTimeMillis().toDouble()
        dashXClient?.trackAppStarted(fromBackground = true)
    }

    override fun onActivityStarted(activity: Activity) {
        if (!screenTrackingEnabled) {
            return
        }

        val packageManager = activity.packageManager
        val info = packageManager?.getActivityInfo(activity.componentName, PackageManager.GET_META_DATA)
        val activityLabel = info?.loadLabel(packageManager)
        activityLabel?.let { it -> dashXClient?.screen(it.toString(), hashMapOf()) }
    }

    override fun onActivityDestroyed(activity: Activity) {

    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {

    }

    override fun onActivityStopped(activity: Activity) {

    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {

    }

    companion object {
        private var dashXActivityLifecycleCallbacks: DashXActivityLifecycleCallbacks? = null
        private var screenTrackingEnabled = false
        private var lifecycleTrackingEnabled = false

        private fun registerCallbacks(context: Context) {
            dashXActivityLifecycleCallbacks = DashXActivityLifecycleCallbacks()
            val application = context as Application
            application.registerActivityLifecycleCallbacks(dashXActivityLifecycleCallbacks)
        }

        fun enableActivityLifecycleTracking(context: Context) {
            lifecycleTrackingEnabled = true

            if (dashXActivityLifecycleCallbacks != null) {
                return
            }

            registerCallbacks(context)
        }

        fun enableScreenTracking(context: Context) {
            screenTrackingEnabled = true

            if (dashXActivityLifecycleCallbacks != null) {
                return
            }

            registerCallbacks(context)
        }
    }
}
