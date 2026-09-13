package com.example.fn_tracker

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log

/**
 * Launch entry for the app icon and Pixel Quick Tap.
 *
 * Quick Tap comes from SystemUI and should open [QuickAddActivity].
 * The home icon, Recents, and shortcuts open [MainActivity].
 */
class LauncherTrampolineActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val launchedFrom = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            launchedFromPackage
        } else {
            null
        }
        Log.d(TAG, "launchedFromPackage=$launchedFrom flags=${intent.flags}")

        val openQuickAdd = shouldOpenQuickAdd(launchedFrom)
        val next = Intent(
            this,
            if (openQuickAdd) QuickAddActivity::class.java else MainActivity::class.java,
        ).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (openQuickAdd) {
                addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
            } else {
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            intent.extras?.let { putExtras(it) }
            if (!intent.action.isNullOrEmpty()) {
                action = intent.action
            }
            data = intent.data
        }
        startActivity(next)
        finish()
        if (openQuickAdd) {
            overridePendingTransition(0, 0)
        }
    }

    private fun shouldOpenQuickAdd(launchedFrom: String?): Boolean {
        val fromHistory =
            intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0
        if (fromHistory) return false
        if (hasShortcutExtra()) return false
        return launchedFrom == SYSTEM_UI_PACKAGE
    }

    private fun hasShortcutExtra(): Boolean {
        val extras = intent.extras ?: return false
        return extras.containsKey(EXTRA_TYPE) ||
            extras.containsKey(EXTRA_SHORTCUT_TYPE) ||
            !intent.getStringExtra(EXTRA_TYPE).isNullOrEmpty()
    }

    companion object {
        private const val TAG = "LauncherTrampoline"
        private const val SYSTEM_UI_PACKAGE = "com.android.systemui"
        private const val EXTRA_TYPE = "type"
        private const val EXTRA_SHORTCUT_TYPE = "shortcutType"
    }
}
