package com.example.fn_tracker

import android.graphics.Bitmap
import android.graphics.Canvas
object WidgetItemBackgroundBitmap {
    fun create(
        widthPx: Int,
        heightPx: Int,
        fillColor: Int,
        radiusGroup: WidgetListCardRadius,
        density: Float,
    ): Bitmap {
        val w = widthPx.coerceAtLeast(1)
        val h = heightPx.coerceAtLeast(1)
        val mainPx = 12f * density
        val cornerPx = 4f * density
        val drawable = WidgetListCardRadiusUtils.roundedRectDrawable(
            fillColor,
            radiusGroup,
            mainPx,
            cornerPx,
        )
        drawable.setBounds(0, 0, w, h)
        val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.draw(canvas)
        return bitmap
    }
}
