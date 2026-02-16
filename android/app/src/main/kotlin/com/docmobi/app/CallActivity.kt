package com.docmobi.app

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterActivity

class CallActivity : AppCompatActivity() {
    
    private lateinit var callerNameText: TextView
    private lateinit var callerAvatarImage: ImageView
    private lateinit var acceptButton: View
    private lateinit var declineButton: View
    
    private var chatId: String = ""
    private var callerId: String = ""
    private var callerName: String = ""
    private var isVideo: Boolean = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // ✅ Show over lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
        
        // Unlock keyguard
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            keyguardManager.requestDismissKeyguard(this, null)
        }
        
        setContentView(R.layout.activity_call)
        
        // Get data from intent
        chatId = intent.getStringExtra("chatId") ?: ""
        callerId = intent.getStringExtra("callerId") ?: ""
        callerName = intent.getStringExtra("callerName") ?: "Unknown"
        isVideo = intent.getBooleanExtra("isVideo", false)
        
        // Initialize views
        callerNameText = findViewById(R.id.callerName)
        callerAvatarImage = findViewById(R.id.callerAvatar)
        acceptButton = findViewById(R.id.acceptButton)
        declineButton = findViewById(R.id.declineButton)
        
        callerNameText.text = callerName
        
        // Set button actions
        acceptButton.setOnClickListener {
            acceptCall()
        }
        
        declineButton.setOnClickListener {
            declineCall()
        }
    }
    
    private fun acceptCall() {
        // Send result back to Flutter
        val resultIntent = Intent(this, FlutterActivity::class.java).apply {
            putExtra("action", "accept")
            putExtra("chatId", chatId)
            putExtra("callerId", callerId)
            putExtra("callerName", callerName)
            putExtra("isVideo", isVideo)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        startActivity(resultIntent)
        finish()
    }
    
    private fun declineCall() {
        // Send decline action to Flutter
        val resultIntent = Intent(this, FlutterActivity::class.java).apply {
            putExtra("action", "decline")
            putExtra("chatId", chatId)
            putExtra("callerId", callerId)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        startActivity(resultIntent)
        finish()
    }
    
    override fun onBackPressed() {
        // Prevent back button from closing call screen
    }
}