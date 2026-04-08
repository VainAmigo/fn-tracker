package com.example.fn_tracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import java.text.DecimalFormat
import org.json.JSONArray

class AnalyticsWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        updateAll(context, appWidgetManager, appWidgetIds)
    }

    companion object {
        fun updateAll(context: Context, manager: AppWidgetManager, ids: IntArray) {
            ids.forEach { updateAppWidget(context, manager, it) }
        }

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val income = prefs.getFloat("flutter.widget_analytics_total_income", 0f).toDouble()
            val expense = prefs.getFloat("flutter.widget_analytics_total_expense", 0f).toDouble()
            val balance = prefs.getFloat("flutter.widget_analytics_balance", 0f).toDouble()
            val period = prefs.getString("flutter.widget_analytics_period_label", "") ?: ""
            val trendPoints = parseTrendPoints(
                prefs.getString("flutter.widget_analytics_trend_points_json", "[]") ?: "[]"
            )

            val views = RemoteViews(context.packageName, R.layout.widget_analytics).apply {
                setTextViewText(R.id.analytics_period, period.ifBlank { "Analytics" })
                setTextViewText(R.id.analytics_income_value, formatAmount(income))
                setTextViewText(R.id.analytics_expense_value, formatAmount(expense))
                setTextViewText(R.id.analytics_balance_value, formatAmount(balance))
                setInt(R.id.analytics_root, "setBackgroundColor", WidgetThemeColors.surface(context))
                setTextColor(R.id.analytics_title, WidgetThemeColors.onSurface(context))
                setTextColor(R.id.analytics_period, WidgetThemeColors.onSurface(context))
                setTextColor(R.id.analytics_income_label, WidgetThemeColors.onSurface(context))
                setTextColor(R.id.analytics_expense_label, WidgetThemeColors.onSurface(context))
                setTextColor(R.id.analytics_balance_label, WidgetThemeColors.onSurface(context))
                setTextColor(R.id.analytics_income_value, WidgetThemeColors.onSurface(context))
                setTextColor(R.id.analytics_expense_value, WidgetThemeColors.onSurface(context))
                setTextColor(R.id.analytics_balance_value, WidgetThemeColors.onSurface(context))
                val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
                val chartWidthPx = ((options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 220))
                        * context.resources.displayMetrics.density).toInt().coerceAtLeast(dpToPx(context, 180f))
                val chartHeightPx = ((options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 120))
                        * context.resources.displayMetrics.density).toInt().coerceAtLeast(dpToPx(context, 80f))
                val gradientBase = Color.parseColor("#FF6750A4")
                val lineColor = Color.argb((255 * 0.6f).toInt(), Color.red(gradientBase), Color.green(gradientBase), Color.blue(gradientBase))
                val fillColor = Color.argb((255 * 0.4f).toInt(), Color.red(gradientBase), Color.green(gradientBase), Color.blue(gradientBase))
                setImageViewBitmap(
                    R.id.analytics_chart,
                    AnalyticsChartBitmap.createLineChart(
                        widthPx = chartWidthPx,
                        heightPx = chartHeightPx,
                        points = trendPoints,
                        lineColor = lineColor,
                        fillColor = fillColor,
                        minYFactor = 0.6f,
                    )
                )
            }

            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId + 10_000,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.analytics_root, pendingIntent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun formatAmount(value: Double): String {
            val fmt = DecimalFormat("#,##0.##")
            return fmt.format(value)
        }

        private fun parseTrendPoints(raw: String): List<Double> {
            return try {
                val arr = JSONArray(raw)
                buildList {
                    for (i in 0 until arr.length()) {
                        add(arr.optDouble(i, 0.0))
                    }
                }
            } catch (_: Throwable) {
                emptyList()
            }
        }

        private fun dpToPx(context: Context, dp: Float): Int {
            return (dp * context.resources.displayMetrics.density).toInt().coerceAtLeast(1)
        }
    }
}
