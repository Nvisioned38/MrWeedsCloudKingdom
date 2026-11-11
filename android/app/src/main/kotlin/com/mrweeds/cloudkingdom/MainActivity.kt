package com.mrweeds.cloudkingdom

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val profileChannel = "cloud_kingdom/qa_profile"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, profileChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "profileMetadata") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val requested = intent?.getStringExtra("CK_FRAME_SCENARIO")
                val allowed = setOf(
                    "normal_match3", "long_cascade", "torch", "prism",
                    "cloud_bomb", "reduced_motion"
                )
                result.success(
                    mapOf(
                        "packageName" to applicationContext.packageName,
                        "scenario" to requested?.takeIf { it in allowed }
                    )
                )
            }
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
