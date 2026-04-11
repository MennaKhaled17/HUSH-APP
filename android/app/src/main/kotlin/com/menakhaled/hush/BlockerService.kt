package com.menakhaled.hush

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.IBinder
import android.view.Gravity
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat

class BlockerService : Service() {

    private var overlayView: android.view.View? = null
    private val blockedApps = mutableListOf<String>()
    private var isRunning = false
    private val handler = android.os.Handler(android.os.Looper.getMainLooper())

    // ── Map display names → real package names ──────────────────
    private val appPackageMap = mapOf(
        "TikTok"      to "com.zhiliaoapp.musically",
        "Instagram"   to "com.instagram.android",
        "YouTube"     to "com.google.android.youtube",
        "Twitter"     to "com.twitter.android",
        "X"           to "com.twitter.android",
        "Snapchat"    to "com.snapchat.android",
        "Facebook"    to "com.facebook.katana",
        "WhatsApp"    to "com.whatsapp",
        "Reddit"      to "com.reddit.frontpage",
        "Telegram"    to "org.telegram.messenger",
        "Netflix"     to "com.netflix.mediaclient",
        "Spotify"     to "com.spotify.music",
        "Discord"     to "com.discord",
        "LinkedIn"    to "com.linkedin.android",
        "Pinterest"   to "com.pinterest",
        "Twitch"      to "tv.twitch.android.app",
        "BeReal"      to "com.bereal.ft",
        "Threads"     to "com.instagram.barcelona",
    )

    private val checkRunnable = object : Runnable {
        override fun run() {
            if (isRunning) {
                checkForegroundApp()
                handler.postDelayed(this, 1000)
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "START" -> {
                val apps = intent.getStringArrayListExtra("blocked_apps") ?: arrayListOf()
                blockedApps.clear()
                blockedApps.addAll(apps)
                isRunning = true
                startForegroundNotification()
                handler.post(checkRunnable)
            }
            "STOP" -> {
                isRunning = false
                removeOverlay()
                stopSelf()
            }
        }
        return START_STICKY
    }

    private fun checkForegroundApp() {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, time - 5000, time
        )
        val foregroundApp = stats
            ?.filter { it.lastTimeUsed > time - 3000 }
            ?.maxByOrNull { it.lastTimeUsed }
            ?.packageName ?: return

        if (foregroundApp == packageName) {
            removeOverlay()
            return
        }

        // Convert blocked display names to package names for comparison
        val blockedPackages = blockedApps.mapNotNull { appPackageMap[it] }

        if (blockedPackages.any { foregroundApp == it }) {
            showOverlay()
        } else {
            removeOverlay()
        }
        android.util.Log.d("HUSH_BLOCKER", "Foreground: $foregroundApp | Blocked: $blockedPackages")
    }

    private fun showOverlay() {
        if (overlayView != null) return
        val wm = getSystemService(WINDOW_SERVICE) as WindowManager
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(0xFF0F1117.toInt())
            val title = TextView(context).apply {
                text = "Focus Mode Active"
                textSize = 24f
                setTextColor(0xFFC8F135.toInt())
                gravity = Gravity.CENTER
            }
            val sub = TextView(context).apply {
                text = "This app is blocked during your session."
                textSize = 14f
                setTextColor(0xFF888B9A.toInt())
                gravity = Gravity.CENTER
                setPadding(40, 16, 40, 40)
            }
            val btn = Button(context).apply {
                text = "Go Back to HUSH"
                setBackgroundColor(0xFFC8F135.toInt())
                setTextColor(0xFF111111.toInt())
                setOnClickListener {
                    val launch = packageManager.getLaunchIntentForPackage(packageName)
                    launch?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(launch)
                }
            }
            addView(title)
            addView(sub)
            addView(btn)
        }
        overlayView = layout
        wm.addView(overlayView, params)
    }

    private fun removeOverlay() {
        overlayView?.let {
            val wm = getSystemService(WINDOW_SERVICE) as WindowManager
            try { wm.removeView(it) } catch (_: Exception) {}
            overlayView = null
        }
    }

    private fun startForegroundNotification() {
        val channelId = "hush_blocker"
        val channel = NotificationChannel(
            channelId, "Focus Blocker", NotificationManager.IMPORTANCE_LOW
        )
        (getSystemService(NOTIFICATION_SERVICE) as NotificationManager)
            .createNotificationChannel(channel)
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Focus mode active")
            .setContentText("Blocking distractions")
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .build()
        startForeground(1, notification)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        isRunning = false
        removeOverlay()
        super.onDestroy()
    }
}