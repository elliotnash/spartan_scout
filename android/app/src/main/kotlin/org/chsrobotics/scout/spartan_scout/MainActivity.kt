package org.chsrobotics.scout.spartan_scout

import io.flutter.embedding.android.FlutterActivity
import android.os.Build;
import android.os.Bundle
import android.view.Window;
import android.view.WindowManager;

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // add these lines
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            val window: Window = getWindow()
            window.setFlags(
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
            )
        }
    }
}
