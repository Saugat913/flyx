package com.example.flyx

import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flyx/device_info")
            .setMethodCallHandler { call, result ->
                if (call.method == "getDeviceName") {
                    val customName = Settings.Global.getString(
                        contentResolver,
                        Settings.Global.DEVICE_NAME
                    )
                    if (!customName.isNullOrBlank()) {
                        result.success(customName)
                    } else {
                        val manufacturer = Build.MANUFACTURER.replaceFirstChar { it.uppercase() }
                        val model = Build.MODEL
                        val fallback = if (model.startsWith(manufacturer, ignoreCase = true)) {
                            model
                        } else {
                            "$manufacturer $model"
                        }
                        result.success(fallback)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
