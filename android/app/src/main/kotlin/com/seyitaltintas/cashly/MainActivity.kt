package com.seyitaltintas.cashly

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.seyitaltintas.cashly/security"
    private var isSecureVaultOpen = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "secureScreenOn" -> {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    isSecureVaultOpen = true
                    result.success(null)
                }
                "secureScreenOff" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    isSecureVaultOpen = false
                    result.success(null)
                }
                "clearClipboard" -> {
                    clearClipboardData()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        // Eğer gizli kasa açıksa ve ekran odağı kaybolursa (Örn: App Switcher açılırsa)
        // ANINDA panoyu temizle. Bu sayede Android'in arka plan kısıtlamalarına takılmaz.
        if (!hasFocus && isSecureVaultOpen) {
            clearClipboardData()
        }
    }

    private fun clearClipboardData() {
        try {
            val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            // Android bazı durumlarda boş string'i kabul etmez, görünmez bir boşluk atıyoruz.
            val clip = ClipData.newPlainText("cleared", " ")
            clipboard.setPrimaryClip(clip)
            
            // Eğer Android 9 (Pie) ve üzeriyse, panoyu tamamen temizleme yetkisini kullan
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                clipboard.clearPrimaryClip()
            }
        } catch (e: Exception) { }
    }
}
