package com.example.linksafe

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "linksafe/url"
    private var initialUrl: String? = null

    private fun isSelfTriggeredIntent(intent: Intent?): Boolean {
        if (intent == null) return false
        if (intent.action != Intent.ACTION_VIEW) return false
        val flags = intent.flags
        if ((flags and Intent.FLAG_ACTIVITY_FORWARD_RESULT) != 0) return true
        if (intent.`package` == packageName) return true
        return false
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (isSelfTriggeredIntent(intent)) {
            finish()
            return
        }
        initialUrl = intent?.data?.toString()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialUrl" -> {
                    result.success(initialUrl)
                    initialUrl = null
                }
                "openSafeUrl" -> {
                    val url = call.arguments as String?
                    if (url != null) {
                        try {
                            val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                            val resolveIntent = Intent(Intent.ACTION_VIEW, Uri.parse("http://"))
                            val defaultBrowser = packageManager.resolveActivity(resolveIntent, PackageManager.MATCH_DEFAULT_ONLY)
                            
                            if (defaultBrowser != null && defaultBrowser.activityInfo.packageName != packageName) {
                                browserIntent.setPackage(defaultBrowser.activityInfo.packageName)
                            }
                            
                            browserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_FORWARD_RESULT)
                            startActivity(browserIntent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    } else {
                        result.error("ERROR", "URL is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (isSelfTriggeredIntent(intent)) {
            finish()
            return
        }
        val url = intent.data?.toString()
        if (url != null) {
            flutterEngine?.dartExecutor?.binaryMessenger?.let {
                MethodChannel(it, CHANNEL).invokeMethod("checkUrl", url)
            }
        }
    }
}
