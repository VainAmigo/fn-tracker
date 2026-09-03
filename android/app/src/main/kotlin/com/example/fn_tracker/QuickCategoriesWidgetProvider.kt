package com.example.fn_tracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.widget.RemoteViews

class QuickCategoriesWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        updateAll(context, appWidgetManager, appWidgetIds)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    companion object {
        const val EXTRA_WIDGET_ID = "extra_widget_id"
        const val EXTRA_IS_COMPACT = "extra_is_compact"
        const val EXTRA_CATEGORY_ID = "widget_category_id"

        fun updateAll(context: Context, manager: AppWidgetManager, ids: IntArray) {
            ids.forEach { updateAppWidget(context, manager, it) }
        }

        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val provider = ComponentName(context, QuickCategoriesWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(provider)
            if (ids.isEmpty()) return
            manager.notifyAppWidgetViewDataChanged(ids, R.id.widget_grid)
            updateAll(context, manager, ids)
        }

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val minWidthDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
            val isCompact = minWidthDp < 140
            val layoutRes = if (isCompact) {
                R.layout.widget_small
            } else {
                R.layout.widget_large
            }

            val surface = QuickCategoriesWidgetData.themeColor(
                context,
                "flutter.widget_categories_theme_surface",
                WidgetThemeColors.surface(context),
            )
            val onSurface = QuickCategoriesWidgetData.themeColor(
                context,
                "flutter.widget_categories_theme_on_surface",
                WidgetThemeColors.onSurface(context),
            )

            val views = RemoteViews(context.packageName, layoutRes)
            views.setInt(R.id.widget_root, "setBackgroundColor", surface)
            views.setTextViewText(R.id.widget_empty, QuickCategoriesWidgetData.emptyLabel(context))
            views.setTextColor(R.id.widget_empty, onSurface)

            val serviceIntent = Intent(context, QuickCategoriesWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                putExtra(EXTRA_WIDGET_ID, appWidgetId)
                putExtra(EXTRA_IS_COMPACT, isCompact)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }

            views.setRemoteAdapter(R.id.widget_grid, serviceIntent)
            views.setEmptyView(R.id.widget_grid, R.id.widget_empty)

            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra(EXTRA_CATEGORY_ID, "")
            }
            val templatePendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or mutableFlag(),
            )
            views.setPendingIntentTemplate(R.id.widget_grid, templatePendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_grid)
        }

        private fun mutableFlag(): Int {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_MUTABLE
            } else {
                0
            }
        }
    }
}
