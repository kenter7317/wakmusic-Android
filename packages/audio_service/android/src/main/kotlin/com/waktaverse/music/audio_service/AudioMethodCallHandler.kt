package com.waktaverse.music.audio_service

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.waktaverse.music.audio_service.models.AudioMetadata
import com.waktaverse.music.audio_service.models.AudioState
import com.waktaverse.music.audio_service.models.MediaButton
import com.waktaverse.music.audio_service.models.PlaybackState
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.concurrent.Executors

class AudioMethodCallHandler(
        var context: Context,
) : MethodCallHandler, AudioHandler {
    companion object {
        private const val url: String = "waktaverse.music.audio_service.handler.methods"
    }

    private lateinit var channel: MethodChannel
    private val handler: Handler = Handler(Looper.getMainLooper())

    fun init(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, url)
        channel.setMethodCallHandler(this)
        Log.d("tqadinit", "tlzzzvcv")
    }

    fun dispose() {
        if (::channel.isInitialized) {
            channel.setMethodCallHandler(null)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments

        when (call.method) {
            "setMetadata" -> {
//                val map = args as Map<*, *>
//                val metadata = AudioMetadata(
//                        id = map["id"] as String,
//                        title = map["title"] as String,
//                        artist = map["artist"] as String,
//                        duration = map["duration"] as Int)
//                Log.d("tqtrz", "$metadata, ${AudioService.instance}")
//                AudioService.instance?.setMetadata(metadata)
//                result.success(null)
                Executors.newSingleThreadExecutor().execute {
                    try {
                        val map = args as Map<*, *>
                        val metadata = AudioMetadata(
                                id = map["id"] as String,
                                title = map["title"] as String,
                                artist = map["artist"] as String,
                                duration = map["duration"] as Int)
                        Log.d("tqtrz", "$metadata, ${AudioService.instance}")
                        AudioService.instance?.setMetadata(metadata)
                        handler.post { result.success(null) }
                    } catch (e: Exception) {
                        handler.post {
                            result.error("UNEXPECTED_ERROR",
                                    "Unexpected Error",
                                    Log.getStackTraceString(e))
                        }
                    }
                }
            }
            "setState" -> {
                val map = args as Map<*, *>
                val state = AudioState(
                        playbackState = PlaybackState.byCode(map["playbackState"] as Int),
                        position = map["position"] as Int,
                        nextPlayable = map["nextPlayable"] as Boolean,
                        prevPlayable = map["prevPlayable"] as Boolean,
                )
                var currentTime = System.currentTimeMillis()
                Log.d("tqts", "$state, ${AudioService.instance}")
                AudioService.instance?.setState(state, currentTime - AudioServicePlugin.bootTime)
                result.success(null)
            }
            "stopService" -> {
                AudioService.instance?.stop()
                result.success(null)
            }
        }
    }

    private fun invokeMethod(method: String, args: Any?) {
        Log.d("tqllinvk", method)
        channel.invokeMethod(method, args)
    }

    override fun onPlay() {
        invokeMethod("play", null)
    }

    override fun onPause() {
        invokeMethod("pause", null)
    }

    override fun onStop() {
        invokeMethod("stop", null)
    }

    override fun onToNext() {
        invokeMethod("toNext", null)
    }

    override fun onToPrevious() {
        invokeMethod("toPrevious", null)
    }

    override fun onSeek(pos: Long) {
        invokeMethod("seek", mapOf("position" to pos))
    }

    override fun onButtonClicked(button: MediaButton) {
        invokeMethod("onButtonClicked", mapOf("button" to button.ordinal))
    }

    override fun onNotiClicked() {
        invokeMethod("onNotiClicked", null)
    }

    override fun onNotiDeleted() {
        invokeMethod("onNotiDeleted", null)
    }

    override fun onTaskRemoved() {
        invokeMethod("onTaskRemoved", null)
    }
}