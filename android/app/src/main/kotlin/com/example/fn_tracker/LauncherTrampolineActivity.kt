package com.example.fn_tracker

import android.app.Activity
import android.app.ActivityOptions
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log

/**
 * Launch entry for the app icon and Pixel Quick Tap.
 *
 * Quick Tap comes from SystemUI / Android System Intelligence and should open
 * [QuickAddActivity]. The home icon, Recents, and Play Store open [MainActivity].
 *
 * Trampoline lives in its own task so FLAG_ACTIVITY_RESET_TASK_IF_NEEDED from
 * the launcher cannot skip this activity and just resume [MainActivity].
 */
class LauncherTrampolineActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        routeLaunch(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        routeLaunch(intent)
    }

    private fun routeLaunch(incoming: Intent?) {
        val launchedFrom = resolveCallerPackage()
        val openQuickAdd = shouldOpenQuickAdd(launchedFrom)
        Log.d(
            TAG,
            "openQuickAdd=$openQuickAdd launchedFrom=$launchedFrom " +
                "quickTapCaller=${launchedFrom?.let(::isQuickTapCaller)} " +
                "referrer=$referrer flags=0x${Integer.toHexString(incoming?.flags ?: 0)}",
        )

        val next = Intent(
            this,
            if (openQuickAdd) QuickAddActivity::class.java else MainActivity::class.java,
        ).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (openQuickAdd) {
                addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
                putExtra("route", "/quick-add")
            } else {
                addFlags(
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_REORDER_TO_FRONT,
                )
            }
        }

        startActivity(next, activityOptionsBundle())
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

        val resetTask =
            intent.flags and Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED != 0

        if (launchedFrom.isNullOrBlank()) {
            return !resetTask
        }
        if (launchedFrom == packageName) return false
        if (isMainEntryCaller(launchedFrom)) {
            // Home icon almost always sets RESET_TASK_IF_NEEDED.
            // Quick Tap via getLaunchIntentForPackage often does not.
            return !resetTask
        }
        // SystemUI, ASI, Settings, and other non-launcher system packages.
        return true
    }

    private fun resolveCallerPackage(): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            launchedFromPackage?.let { return it }
        }
        callingPackage?.let { return it }
        referrer?.host?.let { return it }
        return referrer?.authority
    }

    private fun isMainEntryCaller(pkg: String): Boolean {
        if (pkg in MAIN_ENTRY_PACKAGES) return true
        val lower = pkg.lowercase()
        return lower.contains("launcher") ||
            lower.contains("lawnchair") ||
            (lower.contains("home") && lower.contains("miui"))
    }

    private fun isQuickTapCaller(pkg: String): Boolean {
        if (pkg in QUICK_TAP_PACKAGES) return true
        return pkg.startsWith("com.google.android.as") ||
            pkg.contains("systemui", ignoreCase = true)
    }

    private fun hasShortcutExtra(): Boolean {
        val extras = intent.extras ?: return false
        return extras.containsKey(EXTRA_TYPE) ||
            extras.containsKey(EXTRA_SHORTCUT_TYPE) ||
            extras.containsKey(EXTRA_SHORTCUT_ID) ||
            !intent.getStringExtra(EXTRA_TYPE).isNullOrEmpty()
    }

    private fun activityOptionsBundle(): android.os.Bundle? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return null
        }
        val options = ActivityOptions.makeBasic()
        options.setPendingIntentBackgroundActivityStartMode(
            ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED,
        )
        options.setPendingIntentCreatorBackgroundActivityStartMode(
            ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED,
        )
        return options.toBundle()
    }

    companion object {
        private const val TAG = "LauncherTrampoline"
        private const val EXTRA_TYPE = "type"
        private const val EXTRA_SHORTCUT_TYPE = "shortcutType"
        private const val EXTRA_SHORTCUT_ID = "shortcutId"

        private val QUICK_TAP_PACKAGES = setOf(
            "com.android.systemui",
            "com.google.android.systemui",
            "com.google.android.as",
            "com.google.android.as.oss",
            "com.android.settings",
            "com.google.android.settings.intelligence",
            "android",
        )

        private val MAIN_ENTRY_PACKAGES = setOf(
            "com.google.android.apps.nexuslauncher",
            "com.android.launcher3",
            "com.android.shell",
            "com.android.vending",
            "com.google.android.packageinstaller",
            "com.android.packageinstaller",
            "com.google.android.googlequicksearchbox",
            "com.google.android.apps.googleapp",
            "com.sec.android.app.launcher",
            "com.miui.home",
            "com.huawei.android.launcher",
            "net.oneplus.launcher",
            "com.oppo.launcher",
            "com.nothing.launcher",
            "com.microsoft.launcher",
        )
    }
}
