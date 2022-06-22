package com.dashx.rn.sdk

class DashXExceptionHandler(private val mainExceptionHandler: Thread.UncaughtExceptionHandler)
    : Thread.UncaughtExceptionHandler {
    private val dashXClient = DashXClientInterceptor.instance.getDashXClient()

    companion object {
        fun enable() {
            val defaultExceptionHandler = Thread.getDefaultUncaughtExceptionHandler()
            if (defaultExceptionHandler is DashXExceptionHandler) {
                return
            }

            if (defaultExceptionHandler != null) {
                val dashXExceptionHandler = DashXExceptionHandler(defaultExceptionHandler)
                Thread.setDefaultUncaughtExceptionHandler(dashXExceptionHandler)
            }
        }
    }

    override fun uncaughtException(thread: Thread, exception: Throwable) {
        if (dashXClient != null) {
            dashXClient.trackAppCrashed(exception)
        }

        mainExceptionHandler.uncaughtException(thread, exception)
    }
}
