package com.example.fn_tracker

object WalletIconBitmap {
    fun create(
        context: android.content.Context,
        color: Int,
        iconId: String,
        sizePx: Int,
    ) = WidgetIconBitmap.create(context, color, iconId, sizePx)
}
