package com.example.fn_tracker

import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.android.FlutterFragmentActivity

class QuickAddActivity : FlutterFragmentActivity() {
    override fun getInitialRoute(): String = "/quick-add"

    override fun getBackgroundMode(): BackgroundMode = BackgroundMode.transparent
}
