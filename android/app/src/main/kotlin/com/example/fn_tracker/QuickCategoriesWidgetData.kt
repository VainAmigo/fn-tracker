package com.example.fn_tracker

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

data class WidgetCategory(
    val id: String,
    val name: String,
    val color: Int,
    val iconId: String,
)

object QuickCategoriesWidgetData {
    private const val PREFS_NAME = "FlutterSharedPreferences"
    private const val KEY_CATEGORIES = "flutter.widget_categories_json"

    fun readDisplayCategories(context: Context): List<WidgetCategory> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return parseCategories(prefs.getString(KEY_CATEGORIES, "[]").orEmpty())
    }

    fun emptyLabel(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getString("flutter.widget_categories_empty_label", "")
            .orEmpty()
            .ifBlank { context.getString(R.string.quick_categories_widget_empty) }
    }

    fun themeColor(context: Context, key: String, fallback: Int): Int {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return WidgetThemeColors.storedOr(prefs.getInt(key, 0), fallback)
    }

    private fun parseCategories(json: String): List<WidgetCategory> {
        return try {
            val arr = JSONArray(json)
            buildList {
                for (i in 0 until arr.length()) {
                    val obj = arr.optJSONObject(i) ?: continue
                    val id = obj.optString("id")
                    if (id.isBlank()) continue
                    add(
                        WidgetCategory(
                            id = id,
                            name = obj.optString("name", ""),
                            color = parseColor(obj),
                            iconId = obj.optString("icon_id", ""),
                        )
                    )
                }
            }
        } catch (_: Throwable) {
            emptyList()
        }
    }

    private fun parseColor(obj: JSONObject): Int {
        val raw = obj.opt("color") ?: return 0xFF9E9E9E.toInt()
        return when (raw) {
            is Number -> raw.toLong().toInt()
            is String -> raw.toLongOrNull()?.toInt() ?: 0xFF9E9E9E.toInt()
            else -> 0xFF9E9E9E.toInt()
        }
    }
}
