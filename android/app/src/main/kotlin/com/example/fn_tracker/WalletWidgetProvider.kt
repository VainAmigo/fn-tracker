package com.example.fn_tracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews

class WalletWidgetProvider : AppWidgetProvider() {
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
        fun updateAll(context: Context, manager: AppWidgetManager, ids: IntArray) {
            ids.forEach { updateAppWidget(context, manager, it) }
        }

        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val provider = ComponentName(context, WalletWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(provider)
            if (ids.isEmpty()) return
            updateAll(context, manager, ids)
        }

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val hasWallet = prefs.getBoolean("flutter.widget_wallet_has_wallet", false)
            val name = prefs.getString("flutter.widget_wallet_name", "") ?: ""
            val color = prefs.getInt("flutter.widget_wallet_color", 0xFF9E9E9E.toInt())
            val iconId = prefs.getString("flutter.widget_wallet_icon_id", "") ?: ""
            val hideAmount = prefs.getBoolean("flutter.widget_wallet_hide_amount", false)
            val amountPrefix = prefs.getString("flutter.widget_wallet_amount_prefix", "") ?: ""
            val amountInteger = prefs.getString("flutter.widget_wallet_amount_integer", "") ?: ""
            val amountSuffix = prefs.getString("flutter.widget_wallet_amount_suffix", "") ?: ""
            val title = prefs.getString("flutter.widget_wallet_title", "") ?: ""
            val emptyLabel = prefs.getString("flutter.widget_wallet_empty_label", "") ?: ""

            val surface = WidgetThemeColors.storedOr(
                prefs.getInt("flutter.widget_wallet_theme_surface", 0),
                WidgetThemeColors.surface(context),
            )
            val secondary = WidgetThemeColors.storedOr(
                prefs.getInt("flutter.widget_wallet_theme_secondary", 0),
                WidgetThemeColors.secondary(context),
            )
            val onSurface = WidgetThemeColors.storedOr(
                prefs.getInt("flutter.widget_wallet_theme_on_surface", 0),
                WidgetThemeColors.onSurface(context),
            )
            val onSecondary = WidgetThemeColors.storedOr(
                prefs.getInt("flutter.widget_wallet_theme_on_secondary", 0),
                WidgetThemeColors.onSecondary(context),
            )
            val primary = WidgetThemeColors.storedOr(
                prefs.getInt("flutter.widget_wallet_theme_primary", 0),
                WidgetThemeColors.primary(context),
            )

            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val minWidthDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 160)
            val minHeightDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110)
            val isCompact = minHeightDp < 80
            val layoutRes = if (isCompact) R.layout.widget_wallet_compact else R.layout.widget_wallet
            val iconSizePx = dpToPx(context, if (isCompact) 32f else 40f)
            val walletColor = if (color == 0) 0xFF9E9E9E.toInt() else color
            val amountSp = when {
                isCompact -> 18f
                minWidthDp < 180 -> 22f
                else -> 28f
            }
            val fractionSp = when {
                isCompact -> 12f
                minWidthDp < 180 -> 13f
                else -> 16f
            }
            val views = RemoteViews(context.packageName, layoutRes).apply {
                setInt(R.id.wallet_root, "setBackgroundColor", secondary.takeIf { it != 0 } ?: surface)
                if (hasWallet) {
                    setViewVisibility(R.id.wallet_content, View.VISIBLE)
                    setViewVisibility(R.id.wallet_empty, View.GONE)
                    setImageViewBitmap(
                        R.id.wallet_icon,
                        WalletIconBitmap.create(context, walletColor, iconId, iconSizePx),
                    )
                    setTextViewText(R.id.wallet_name, name)
                    setTextColor(R.id.wallet_name, onSurface)
                    setTextViewText(R.id.wallet_title, title.ifBlank { context.getString(R.string.wallet_widget_name) })
                    setTextColor(R.id.wallet_title, onSecondary)
                    setViewVisibility(R.id.wallet_title, if (isCompact) View.GONE else View.VISIBLE)
                    setTextColor(R.id.wallet_star, primary)
                    setViewVisibility(R.id.wallet_star, if (isCompact) View.GONE else View.VISIBLE)
                    setTextViewText(R.id.wallet_amount_prefix, amountPrefix)
                    setTextColor(R.id.wallet_amount_prefix, onSecondary)
                    setTextViewTextSize(R.id.wallet_amount_prefix, TypedValue.COMPLEX_UNIT_SP, fractionSp)
                    setTextViewText(R.id.wallet_amount_integer, amountInteger)
                    setTextColor(R.id.wallet_amount_integer, onSurface)
                    setTextViewTextSize(R.id.wallet_amount_integer, TypedValue.COMPLEX_UNIT_SP, amountSp)
                    setTextViewText(R.id.wallet_amount_suffix, if (hideAmount) "" else amountSuffix)
                    setTextColor(R.id.wallet_amount_suffix, onSecondary)
                    setTextViewTextSize(R.id.wallet_amount_suffix, TypedValue.COMPLEX_UNIT_SP, fractionSp)
                } else {
                    setViewVisibility(R.id.wallet_content, View.GONE)
                    setViewVisibility(R.id.wallet_empty, View.VISIBLE)
                    setImageViewBitmap(
                        R.id.wallet_empty_icon,
                        WalletIconBitmap.create(
                            context,
                            onSecondary,
                            "fin_wallet",
                            iconSizePx,
                        ),
                    )
                    setTextViewText(
                        R.id.wallet_empty_label,
                        emptyLabel.ifBlank { context.getString(R.string.wallet_widget_empty) },
                    )
                    setTextColor(R.id.wallet_empty_label, onSecondary)
                }
            }

            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId + 20_000,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.wallet_root, pendingIntent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun dpToPx(context: Context, dp: Float): Int {
            return (dp * context.resources.displayMetrics.density).toInt().coerceAtLeast(1)
        }
    }
}
