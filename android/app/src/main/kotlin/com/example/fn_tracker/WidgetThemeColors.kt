package com.example.fn_tracker

import android.content.Context
import android.content.res.Configuration
import android.graphics.Color
import android.os.Build
import androidx.core.content.ContextCompat

object WidgetThemeColors {
    private fun isDarkTheme(context: Context): Boolean {
        val mode = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
        return mode == Configuration.UI_MODE_NIGHT_YES
    }

    fun surface(context: Context): Int {
        val dark = isDarkTheme(context)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.getColor(
                context,
                if (dark) android.R.color.system_neutral1_900 else android.R.color.system_neutral1_50
            )
        } else {
            Color.parseColor(if (dark) "#1C1B1F" else "#F7F2FA")
        }
    }

    fun onSurface(context: Context): Int {
        val dark = isDarkTheme(context)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.getColor(
                context,
                if (dark) android.R.color.system_neutral1_50 else android.R.color.system_neutral1_900
            )
        } else {
            Color.parseColor(if (dark) "#E6E1E5" else "#1C1B1F")
        }
    }

    /**
     * Matches [AppThemes.themeFromDynamicColor]: cards use a layered surface
     * ([ColorScheme.secondary] ← [ColorScheme.onInverseSurface]).
     */
    fun secondary(context: Context): Int {
        val dark = isDarkTheme(context)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.getColor(
                context,
                if (dark) android.R.color.system_neutral1_800 else android.R.color.system_neutral2_100
            )
        } else {
            Color.parseColor(if (dark) "#242C3A" else "#D8E4F0")
        }
    }

    fun onSecondary(context: Context): Int {
        val dark = isDarkTheme(context)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.getColor(
                context,
                if (dark) android.R.color.system_neutral2_200 else android.R.color.system_neutral2_600
            )
        } else {
            Color.parseColor(if (dark) "#565D67" else "#939DAD")
        }
    }

    fun primary(context: Context): Int {
        val dark = isDarkTheme(context)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.getColor(
                context,
                if (dark) android.R.color.system_accent1_200 else android.R.color.system_accent1_600
            )
        } else {
            Color.parseColor(if (dark) "#53C5E9" else "#69C2F5")
        }
    }

    fun storedOr(prefsColor: Int, fallback: Int): Int {
        return if (prefsColor == 0) fallback else prefsColor
    }
}
