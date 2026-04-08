package com.example.fn_tracker

import android.content.Intent
import android.widget.RemoteViewsService

class QuickCategoriesWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsService.RemoteViewsFactory {
        return QuickCategoriesRemoteViewsFactory(applicationContext, intent)
    }
}
