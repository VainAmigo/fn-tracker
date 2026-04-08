package com.example.fn_tracker

object CategoryIconMapper {
    fun getIconRes(iconId: String): Int {
        return when {
            iconId.startsWith("food_") -> android.R.drawable.ic_menu_compass
            iconId.startsWith("transport_") -> android.R.drawable.ic_menu_directions
            iconId.startsWith("health_") -> android.R.drawable.ic_menu_info_details
            iconId.startsWith("shop_") -> android.R.drawable.ic_menu_agenda
            iconId.startsWith("home_") -> android.R.drawable.ic_menu_myplaces
            iconId.startsWith("edu_") -> android.R.drawable.ic_menu_edit
            iconId.startsWith("fun_") -> android.R.drawable.ic_media_play
            iconId.startsWith("family_") -> android.R.drawable.ic_menu_gallery
            iconId.startsWith("fin_") -> android.R.drawable.ic_menu_manage
            else -> android.R.drawable.ic_menu_help
        }
    }
}
