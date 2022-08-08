package com.example.adachi_capture

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "adachi.capture.line/intent"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if(call.method == "sendLineIntent") {
                var intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://lin.ee/NKKmZgz"))
                startActivity(intent)
            }
        }
    }
}
