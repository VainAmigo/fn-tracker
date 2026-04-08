package com.example.fn_tracker

import android.content.Context
import org.json.JSONArray

data class WidgetCategory(
    val id: String,
    val name: String,
    val color: Int,
    val iconId: String
)

object QuickCategoriesWidgetData {
    private const val PREFS_NAME = "FlutterSharedPreferences"
    private const val KEY_CATEGORIES = "flutter.widget_categories_json"
    private const val KEY_PINNED_IDS = "flutter.widget_pinned_ids_json"
    private const val KEY_RECENT_IDS = "flutter.widget_recent_ids_json"

    fun readDisplayCategories(context: Context, maxItems: Int = 12): List<WidgetCategory> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val categoriesJson = prefs.getString(KEY_CATEGORIES, "[]").orEmpty()
        val pinnedIdsJson = prefs.getString(KEY_PINNED_IDS, "[]").orEmpty()
        val recentIdsJson = prefs.getString(KEY_RECENT_IDS, "[]").orEmpty()

        val all = parseCategories(categoriesJson)
        if (all.isEmpty()) return emptyList()
        val byId = all.associateBy { it.id }

        val result = LinkedHashMap<String, WidgetCategory>()
        for (id in parseStringList(pinnedIdsJson)) {
            val item = byId[id] ?: continue
            result[id] = item
            if (result.size >= maxItems) return result.values.toList()
        }
        for (id in parseStringList(recentIdsJson)) {
            val item = byId[id] ?: continue
            result[id] = item
            if (result.size >= maxItems) return result.values.toList()
        }
        if (result.isEmpty()) {
            for (item in all) {
                result[item.id] = item
                if (result.size >= maxItems) break
            }
        }
        return result.values.toList()
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
                            color = obj.optInt("color", 0xFF9E9E9E.toInt()),
                            iconId = obj.optString("icon_id", "")
                        )
                    )
                }
            }
        } catch (_: Throwable) {
            emptyList()
        }
    }

    private fun parseStringList(json: String): List<String> {
        return try {
            val arr = JSONArray(json)
            buildList {
                for (i in 0 until arr.length()) {
                    val value = arr.optString(i)
                    if (value.isNotBlank()) add(value)
                }
            }
        } catch (_: Throwable) {
            emptyList()
        }
    }
}
