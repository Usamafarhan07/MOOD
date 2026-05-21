package com.example.mood

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.mood/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "shareText") {
                val text = call.argument<String>("text")
                val title = call.argument<String>("title")
                if (text != null) {
                    shareText(text, title)
                    result.success(true)
                } else {
                    result.error("UNAVAILABLE", "Text parameter is null.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun shareText(text: String, title: String?) {
        val sendIntent: Intent = Intent().apply {
            action = Intent.ACTION_SEND
            putExtra(Intent.EXTRA_TEXT, text)
            if (title != null) {
                putExtra(Intent.EXTRA_TITLE, title)
            }
            type = "text/plain"
        }
        val shareIntent = Intent.createChooser(sendIntent, title ?: "Share Piece")
        startActivity(shareIntent)
    }
}
