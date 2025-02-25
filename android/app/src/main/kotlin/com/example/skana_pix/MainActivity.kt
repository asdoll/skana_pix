package com.skanaone.skana_pix

import io.flutter.embedding.android.FlutterActivity
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.skanaone.skana_pix.Safer
import android.content.Intent

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Safer.bindChannel(this, flutterEngine)
    }

    override fun onActivityResult(
        requestCode: Int, resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        Safer.bindResult(this, requestCode, resultCode, data)
    }
}
