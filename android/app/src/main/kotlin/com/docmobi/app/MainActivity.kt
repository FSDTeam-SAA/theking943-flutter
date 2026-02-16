package com.docmobi.app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.docmobi.app/call"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "showCallScreen" -> {
                    val chatId = call.argument<String>("chatId")
                    val callerId = call.argument<String>("callerId")
                    val callerName = call.argument<String>("callerName")
                    val callerAvatar = call.argument<String>("callerAvatar")
                    val isVideo = call.argument<Boolean>("isVideo") ?: false
                    
                    val intent = Intent(this, CallActivity::class.java).apply {
                        putExtra("chatId", chatId)
                        putExtra("callerId", callerId)
                        putExtra("callerName", callerName)
                        putExtra("callerAvatar", callerAvatar)
                        putExtra("isVideo", isVideo)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "cancelCall" -> {
                    // Cancel any ongoing call activity
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        
        // Handle call accept/decline actions
        val action = intent.getStringExtra("action")
        if (action == "accept") {
            // Handle accept
        } else if (action == "decline") {
            // Handle decline
        }
    }
}
