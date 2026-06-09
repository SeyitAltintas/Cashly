package com.seyitaltintas.cashly

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Red Team Yaması: Ekran görüntüsü almayı, ekran kaydını ve 
        // son uygulamalar (recents) menüsünde uygulamanın önizlemesinin görünmesini engeller.
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
    }
}
