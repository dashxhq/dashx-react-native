package com.dashx.rn.sdk

import android.app.Activity
import android.content.Intent
import android.os.Bundle

class NotificationReceiver : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        finish()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        finish()
    }
}
