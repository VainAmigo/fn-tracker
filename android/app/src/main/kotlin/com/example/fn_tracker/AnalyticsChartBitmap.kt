package com.example.fn_tracker

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Shader

object AnalyticsChartBitmap {
    fun createLineChart(
        widthPx: Int,
        heightPx: Int,
        points: List<Double>,
        lineColor: Int,
        fillColor: Int,
        minYFactor: Float = 0.6f,
    ): Bitmap {
        val w = widthPx.coerceAtLeast(1)
        val h = heightPx.coerceAtLeast(1)
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        if (points.isEmpty()) return bmp

        val canvas = Canvas(bmp)
        val safePoints = if (points.size == 1) listOf(points.first(), points.first()) else points
        val minValue = safePoints.minOrNull() ?: 0.0
        val maxValue = safePoints.maxOrNull() ?: 0.0

        val horizontalPadding = 0f
        val chartTop = 0f
        val chartBottom = (h * minYFactor).coerceAtMost(h.toFloat())
        val chartH = (chartBottom - chartTop).coerceAtLeast(1f)
        val chartW = (w - horizontalPadding * 2).coerceAtLeast(1f)
        val step = chartW / (safePoints.size - 1).coerceAtLeast(1)

        fun yFor(v: Double): Float {
            val range = maxValue - minValue
            if (range <= 0.0) return chartTop
            val t = ((v - minValue) / range).coerceIn(0.0, 1.0)
            return (chartTop + (1.0 - t) * chartH).toFloat()
        }

        val linePath = Path()
        linePath.moveTo(horizontalPadding, yFor(safePoints.first()))
        for (i in 1 until safePoints.size) {
            val prevX = horizontalPadding + step * (i - 1)
            val prevY = yFor(safePoints[i - 1])
            val x = horizontalPadding + step * i
            val y = yFor(safePoints[i])
            val cx = (prevX + x) / 2f
            linePath.cubicTo(cx, prevY, cx, y, x, y)
        }

        val fillPath = Path(linePath).apply {
            lineTo(w.toFloat(), h.toFloat())
            lineTo(0f, h.toFloat())
            close()
        }

        val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            shader = LinearGradient(
                0f,
                0f,
                0f,
                h.toFloat(),
                fillColor,
                (fillColor and 0x00FFFFFF),
                Shader.TileMode.CLAMP,
            )
        }
        val linePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = 2f
            strokeCap = Paint.Cap.ROUND
            strokeJoin = Paint.Join.ROUND
            color = lineColor
        }

        canvas.drawPath(fillPath, fillPaint)
        canvas.drawPath(linePath, linePaint)
        return bmp
    }
}
