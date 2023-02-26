package com.waktaverse.music.audio_service

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class ClientMethodCallHandler(
        var context: Context,
) : MethodCallHandler {
    companion object {
        private const val url: String = "waktaverse.music.audio_service.client.methods"
    }

    private lateinit var channel: MethodChannel
    var activity: Activity? = null
//    var result: MethodChannel.Result? = null

    fun init(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, url)
        channel.setMethodCallHandler(this)
        Log.d("tqclinit", "tlzzzvcv")
    }

    fun dispose() {
        if (::channel.isInitialized) {
            channel.setMethodCallHandler(null)
        }
    }

    fun wasLaunchedFromRecents(): Boolean {
        return activity!!.intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY == Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments
        Log.d("tqccxv", "onMethodCall called")

        when (call.method) {
            "getPlatformVersion" -> result.success("${android.os.Build.VERSION.RELEASE}")
            "configure" -> {
                NotificationOptions.putData(context, mapOf(
                        PrefsKey.RESUME_ON_CLICK to true,
                        PrefsKey.NOTIFICATION_CHANNEL_ID to "com.waktaverse.music",
                        PrefsKey.NOTIFICATION_CHANNEL_NAME to "Waktaverse Music",
                        PrefsKey.NOTIFICATION_CHANNEL_DESCRIPTION to "",
                        PrefsKey.NOTIFICATION_COLOR to -1,
                        PrefsKey.NOTIFICATION_ICON to "mipmap/ic_launcher",
                        PrefsKey.SHOW_NOTIFICATION_BADGE to false,
                        PrefsKey.NOTIFICATION_CLICK_STARTS_ACTIVITY to true,
                        PrefsKey.NOTIFICATION_ONGOING to false,
                        PrefsKey.STOP_FOREGROUND_ON_PAUSE to true,
                        PrefsKey.ACTIVITY_CLASS_NAME to AudioService::class.java.name,
                        PrefsKey.BROWSABLE_ROOT_EXTRAS to null
                ))
                Log.d("tqconf", "${NotificationOptions.getData(context)}, ${AudioService.instance}")
                AudioService.instance?.configure()
                result.success(null)
            }
        }
    }
}