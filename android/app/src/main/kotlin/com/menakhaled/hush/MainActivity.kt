package com.menakhaled.hush

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
private val CHANNEL = "com.menakhaled.hush/blocker"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startBlocking" -> {
                        val apps = call.argument<List<String>>("apps") ?: emptyList()
                        val intent = Intent(this, BlockerService::class.java).apply {
                            action = "START"
                            putStringArrayListExtra("blocked_apps", ArrayList(apps))
                        }
                        startService(intent)
                        result.success(null)
                    }
                    "stopBlocking" -> {
                        val intent = Intent(this, BlockerService::class.java).apply { action = "STOP" }
                        startService(intent)
                        result.success(null)
                    }
                    "hasUsagePermission" -> {
                        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
                        val mode = appOps.checkOpNoThrow(
                            AppOpsManager.OPSTR_GET_USAGE_STATS,
                            android.os.Process.myUid(), packageName
                        )
                        result.success(mode == AppOpsManager.MODE_ALLOWED)
                    }
                    "hasOverlayPermission" -> {
                        result.success(Settings.canDrawOverlays(this))
                    }
                    "requestUsagePermission" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "requestOverlayPermission" -> {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}