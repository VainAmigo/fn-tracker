package com.example.fn_tracker

import android.graphics.drawable.GradientDrawable

/**
 * Mirrors [lib/core/utils/card_radius_utils.dart]: first / last / middle / single.
 * mainRadiusDp = AppSizing.borderRadius12 (12), cornerRadiusDp = AppSizing.borderRadius4 (4).
 */
enum class WidgetListCardRadius {
    First,
    Last,
    Middle,
    Single,
}

object WidgetListCardRadiusUtils {
    fun radiusForIndex(index: Int, total: Int): WidgetListCardRadius {
        if (total == 1) return WidgetListCardRadius.Single
        if (index == 0) return WidgetListCardRadius.First
        if (index == total - 1) return WidgetListCardRadius.Last
        return WidgetListCardRadius.Middle
    }

    /**
     * GradientDrawable.cornerRadii order: top-left x,y, top-right x,y, bottom-right x,y, bottom-left x,y.
     */
    fun cornerRadiiPx(
        group: WidgetListCardRadius,
        mainRadiusPx: Float,
        cornerRadiusPx: Float,
    ): FloatArray {
        val m = mainRadiusPx
        val c = cornerRadiusPx
        return when (group) {
            WidgetListCardRadius.Single -> floatArrayOf(m, m, m, m, m, m, m, m)
            WidgetListCardRadius.First -> floatArrayOf(m, m, m, m, c, c, c, c)
            WidgetListCardRadius.Last -> floatArrayOf(c, c, c, c, m, m, m, m)
            WidgetListCardRadius.Middle -> floatArrayOf(c, c, c, c, c, c, c, c)
        }
    }

    fun roundedRectDrawable(
        fillColor: Int,
        group: WidgetListCardRadius,
        mainRadiusPx: Float,
        cornerRadiusPx: Float,
    ): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadii = cornerRadiiPx(group, mainRadiusPx, cornerRadiusPx)
            setColor(fillColor)
        }
    }
}
