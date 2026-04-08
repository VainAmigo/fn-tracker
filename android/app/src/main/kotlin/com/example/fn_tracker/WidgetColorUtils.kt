package com.example.fn_tracker

import android.graphics.Color

object WidgetColorUtils {
    fun withAlpha(color: Int, alpha: Float): Int {
        val r = Color.red(color)
        val g = Color.green(color)
        val b = Color.blue(color)
        val a = (alpha * 255).toInt().coerceIn(0, 255)
        return Color.argb(a, r, g, b)
    }
}
