package com.example.fn_tracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService

class QuickCategoriesRemoteViewsFactory(
    private val context: Context,
    private val intent: Intent,
) : RemoteViewsService.RemoteViewsFactory {
    private val items = mutableListOf<WidgetCategory>()
    private var isCompact: Boolean = true

    override fun onCreate() {
        isCompact = intent.getBooleanExtra(QuickCategoriesWidgetProvider.EXTRA_IS_COMPACT, true)
        reload()
    }

    override fun onDataSetChanged() {
        isCompact = intent.getBooleanExtra(QuickCategoriesWidgetProvider.EXTRA_IS_COMPACT, true)
        reload()
    }

    override fun onDestroy() {
        items.clear()
    }

    override fun getCount(): Int = items.size

    override fun getViewAt(position: Int): RemoteViews? {
        if (position !in items.indices) return null
        val item = items[position]
        val layout = if (isCompact) R.layout.widget_item_small else R.layout.widget_item_large
        val radiusGroup = WidgetListCardRadiusUtils.radiusForIndex(position, items.size)
        val density = context.resources.displayMetrics.density
        val rowW = rowWidthPx()
        val rowH = context.resources.getDimensionPixelSize(R.dimen.widget_list_row_height)
        val secondary = QuickCategoriesWidgetData.themeColor(
            context,
            "flutter.widget_categories_theme_secondary",
            WidgetThemeColors.secondary(context),
        )
        val onSurface = QuickCategoriesWidgetData.themeColor(
            context,
            "flutter.widget_categories_theme_on_surface",
            WidgetThemeColors.onSurface(context),
        )
        val iconSizePx = (32f * density).toInt().coerceAtLeast(1)
        val bgBitmap = WidgetItemBackgroundBitmap.create(
            rowW,
            rowH,
            secondary,
            radiusGroup,
            density,
        )
        return RemoteViews(context.packageName, layout).apply {
            setImageViewBitmap(R.id.item_bg, bgBitmap)
            setImageViewBitmap(
                R.id.item_icon,
                WidgetIconBitmap.create(context, item.color, item.iconId, iconSizePx),
            )
            setTextViewText(R.id.item_text, item.name)
            setTextColor(R.id.item_text, onSurface)

            val fillInIntent = Intent().apply {
                putExtra(QuickCategoriesWidgetProvider.EXTRA_CATEGORY_ID, item.id)
            }
            setOnClickFillInIntent(R.id.item_root, fillInIntent)
        }
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 2

    override fun getItemId(position: Int): Long {
        if (position !in items.indices) return position.toLong()
        return items[position].id.hashCode().toLong()
    }

    override fun hasStableIds(): Boolean = true

    private fun reload() {
        items.clear()
        items.addAll(QuickCategoriesWidgetData.readDisplayCategories(context))
    }

    private fun rowWidthPx(): Int {
        val dm = context.resources.displayMetrics
        val density = dm.density
        val widgetPadDp = if (isCompact) 24f else 28f
        val itemMarginHDp = 8f
        val insetDp = widgetPadDp + itemMarginHDp
        val appWidgetId = intent.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        )
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            return ((dm.widthPixels - insetDp * density).toInt()).coerceAtLeast(80)
        }
        val opts = AppWidgetManager.getInstance(context).getAppWidgetOptions(appWidgetId)
        val minWdDp = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 180)
        return ((minWdDp - insetDp) * density).toInt().coerceAtLeast(80)
    }
}
