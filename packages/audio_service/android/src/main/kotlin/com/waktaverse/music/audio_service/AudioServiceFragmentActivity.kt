package com.waktaverse.music.audio_service

import android.content.Context
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class AudioServiceFragmentActivity : FlutterFragmentActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return AudioServicePlugin.getFlutterEngine(context)
    }

    override fun getCachedEngineId(): String? {
        AudioServicePlugin.getFlutterEngine(this)
        return AudioServicePlugin.flutterEngineId
    }

    // The engine is created and managed by AudioServicePlugin,
    // it should not be destroyed with the activity.
    override fun shouldDestroyEngineWithHost(): Boolean {
        return false
    }
}
