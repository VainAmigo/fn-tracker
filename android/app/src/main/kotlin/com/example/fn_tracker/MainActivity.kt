package com.example.fn_tracker

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var categoryTapEventSink: EventChannel.EventSink? = null
    private var pendingCategoryId: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "fn_tracker/android_widget/methods"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "syncWidgetData" -> {
                    val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                    saveWidgetData(args)
                    refreshWidgets()
                    result.success(null)
                }

                "clearWidgetData" -> {
                    clearWidgetData()
                    refreshWidgets()
                    result.success(null)
                }

                "consumeInitialCategoryId" -> {
                    val id = pendingCategoryId
                    pendingCategoryId = null
                    result.success(id)
                }

                "syncAnalyticsWidgetData" -> {
                    val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                    saveAnalyticsWidgetData(args)
                    refreshAnalyticsWidgets()
                    result.success(null)
                }

                "clearAnalyticsWidgetData" -> {
                    clearAnalyticsWidgetData()
                    refreshAnalyticsWidgets()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "fn_tracker/android_widget/events"
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                categoryTapEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                categoryTapEventSink = null
            }
        })

        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val categoryId = intent?.getStringExtra(QuickCategoriesWidgetProvider.EXTRA_CATEGORY_ID)
        if (categoryId.isNullOrEmpty()) return
        pendingCategoryId = categoryId
        categoryTapEventSink?.success(categoryId)
    }

    private fun saveWidgetData(args: Map<*, *>) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        prefs.edit()
            .putString(
                "flutter.widget_categories_json",
                args["categories_json"] as? String ?: "[]"
            )
            .putString(
                "flutter.widget_pinned_ids_json",
                args["pinned_ids_json"] as? String ?: "[]"
            )
            .putString(
                "flutter.widget_recent_ids_json",
                args["recent_ids_json"] as? String ?: "[]"
            )
            .putLong(
                "flutter.widget_updated_at_ms",
                (args["updated_at_ms"] as? Number)?.toLong() ?: System.currentTimeMillis()
            )
            .apply()
    }

    private fun clearWidgetData() {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        prefs.edit()
            .putString("flutter.widget_categories_json", "[]")
            .putString("flutter.widget_pinned_ids_json", "[]")
            .putString("flutter.widget_recent_ids_json", "[]")
            .apply()
    }

    private fun refreshWidgets() {
        val manager = AppWidgetManager.getInstance(this)
        val provider = ComponentName(this, QuickCategoriesWidgetProvider::class.java)
        val ids = manager.getAppWidgetIds(provider)
        if (ids.isEmpty()) return
        manager.notifyAppWidgetViewDataChanged(ids, R.id.widget_grid)
        QuickCategoriesWidgetProvider.updateAll(this, manager, ids)
    }

    private fun saveAnalyticsWidgetData(args: Map<*, *>) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        prefs.edit()
            .putFloat(
                "flutter.widget_analytics_total_income",
                (args["total_income"] as? Number)?.toFloat() ?: 0f
            )
            .putFloat(
                "flutter.widget_analytics_total_expense",
                (args["total_expense"] as? Number)?.toFloat() ?: 0f
            )
            .putFloat(
                "flutter.widget_analytics_balance",
                (args["balance"] as? Number)?.toFloat() ?: 0f
            )
            .putString(
                "flutter.widget_analytics_period_label",
                args["period_label"] as? String ?: ""
            )
            .putString(
                "flutter.widget_analytics_trend_points_json",
                args["trend_points_json"] as? String ?: "[]"
            )
            .putLong(
                "flutter.widget_analytics_updated_at_ms",
                (args["updated_at_ms"] as? Number)?.toLong() ?: System.currentTimeMillis()
            )
            .apply()
    }

    private fun clearAnalyticsWidgetData() {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        prefs.edit()
            .putFloat("flutter.widget_analytics_total_income", 0f)
            .putFloat("flutter.widget_analytics_total_expense", 0f)
            .putFloat("flutter.widget_analytics_balance", 0f)
            .putString("flutter.widget_analytics_period_label", "")
            .putString("flutter.widget_analytics_trend_points_json", "[]")
            .apply()
    }

    private fun refreshAnalyticsWidgets() {
        val manager = AppWidgetManager.getInstance(this)
        val provider = ComponentName(this, AnalyticsWidgetProvider::class.java)
        val ids = manager.getAppWidgetIds(provider)
        if (ids.isEmpty()) return
        AnalyticsWidgetProvider.updateAll(this, manager, ids)
    }
}
