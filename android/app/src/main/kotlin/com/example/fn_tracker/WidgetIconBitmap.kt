package com.example.fn_tracker

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.GradientDrawable
import androidx.core.content.ContextCompat

object WidgetIconBitmap {
    fun create(
        context: Context,
        color: Int,
        iconId: String,
        sizePx: Int,
    ): Bitmap {
        val size = sizePx.coerceAtLeast(1)
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        val density = context.resources.displayMetrics.density
        val radius = 8f * density
        val background = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = radius
            setColor(WidgetColorUtils.withAlpha(color, 0.3f))
        }
        background.setBounds(0, 0, size, size)
        background.draw(canvas)

        val icon = ContextCompat.getDrawable(context, iconRes(iconId)) ?: return bmp
        icon.mutate().setTint(color)
        val pad = (size * 0.22f).toInt().coerceAtLeast(1)
        icon.setBounds(pad, pad, size - pad, size - pad)
        icon.draw(canvas)
        return bmp
    }

    fun iconRes(iconId: String): Int {
        return when (iconId) {
            "food_coffee", "food_local_cafe" -> R.drawable.ic_widget_coffee
            "food_fastfood", "food_local_pizza", "food_lunch_dining" -> R.drawable.ic_widget_fastfood
            "transport_flight" -> R.drawable.ic_widget_flight
            "health_hospital", "health_medical", "health_pharmacy" -> R.drawable.ic_widget_hospital
            "shop_cart" -> R.drawable.ic_widget_shopping_cart
            "fun_music", "fun_headset" -> R.drawable.ic_widget_music
            "family_child", "family_baby", "family_stroller" -> R.drawable.ic_widget_child
            "fin_bank" -> R.drawable.ic_widget_bank
            "fin_credit" -> R.drawable.ic_widget_card
            "fin_savings" -> R.drawable.ic_widget_savings
            "fin_money" -> R.drawable.ic_widget_attach_money
            "fin_receipt", "fin_payments" -> R.drawable.ic_widget_payments
            else -> when {
                iconId.startsWith("food_") -> R.drawable.ic_widget_restaurant
                iconId.startsWith("transport_") -> R.drawable.ic_widget_car
                iconId.startsWith("health_") -> R.drawable.ic_widget_favorite
                iconId.startsWith("shop_") -> R.drawable.ic_widget_shopping_bag
                iconId.startsWith("home_") -> R.drawable.ic_widget_home
                iconId.startsWith("edu_") -> R.drawable.ic_widget_school
                iconId.startsWith("fun_") -> R.drawable.ic_widget_movie
                iconId.startsWith("family_") -> R.drawable.ic_widget_people
                iconId.startsWith("fin_") -> R.drawable.ic_widget_wallet
                else -> R.drawable.ic_widget_category
            }
        }
    }
}
