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
}
