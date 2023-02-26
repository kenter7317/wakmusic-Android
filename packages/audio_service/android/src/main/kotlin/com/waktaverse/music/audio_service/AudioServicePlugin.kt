package com.waktaverse.music.audio_service

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.support.v4.media.MediaBrowserCompat
import android.support.v4.media.session.MediaControllerCompat
import android.support.v4.media.session.MediaSessionCompat
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry.NewIntentListener

class AudioServicePlugin : FlutterPlugin, ActivityAware {
    companion object {
        private var mediaBrowser: MediaBrowserCompat? = null
        private var mediaController: MediaControllerCompat? = null
        val bootTime: Long = System.currentTimeMillis() - SystemClock.elapsedRealtime()
        var flutterEngineId = "audio_service_engine"

        private var clientMethodCallHandler: ClientMethodCallHandler? = null
        private var audioMethodCallHandler: AudioMethodCallHandler? = null

        @Synchronized
        fun getFlutterEngine(context: Context): FlutterEngine {
            var flutterEngine = FlutterEngineCache.getInstance()[flutterEngineId]
            if (flutterEngine == null) {
                flutterEngine = FlutterEngine(context.applicationContext)
                var initialRoute: String? = null
                if (context is FlutterActivity) {
                    initialRoute = context.initialRoute
                    if (initialRoute == null) {
                        if (context.shouldHandleDeeplinking()) {
                            val data = context.intent.data
                            if (data != null) {
                                initialRoute = data.path
                                if (data.query != null && data.query!!.isNotEmpty()) {
                                    initialRoute += "?" + data.query
                                }
                            }
                        }
                    }
                }
                if (initialRoute == null) {
                    initialRoute = "/"
                }
                flutterEngine.navigationChannel.setInitialRoute(initialRoute)
                flutterEngine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
                FlutterEngineCache.getInstance().put(flutterEngineId, flutterEngine)
            }
            return flutterEngine
        }

        @Synchronized
        fun disposeFlutterEngine() {
            if (clientMethodCallHandler?.activity != null) return
            val flutterEngine = FlutterEngineCache.getInstance()[flutterEngineId]
            if (flutterEngine != null) {
                flutterEngine.destroy()
                FlutterEngineCache.getInstance().remove(flutterEngineId)
            }
        }
    }

    private var flutterBinding: FlutterPluginBinding? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var newIntentListener: NewIntentListener? = null
    private var applicationContext: Context? = null



    private val connectionCallback = object : MediaBrowserCompat.ConnectionCallback() {
        override fun onConnected() {
            try {
                Log.d("tqtrzxcv", "connection")
                val token: MediaSessionCompat.Token = mediaBrowser!!.sessionToken
                mediaController = MediaControllerCompat(applicationContext, token)
                val activity: Activity? = clientMethodCallHandler?.activity
                if (activity != null) {
                    MediaControllerCompat.setMediaController(activity, mediaController)
                }
            } catch (e: Exception) {
                e.printStackTrace()
                throw java.lang.RuntimeException(e)
            }
        }

        override fun onConnectionSuspended() {
            Log.d("tqtr", "connection: suspended")

        }

        override fun onConnectionFailed() {
            Log.d("tqtr", "connection: dksl dhodlfjgrp ehlsrjwl")
        }
    }

    private fun connect() {
        Log.d("tqzzxcsdf", "connect()")
        if (mediaBrowser == null) {
            mediaBrowser = MediaBrowserCompat(applicationContext,
                    ComponentName(applicationContext!!, AudioService::class.java),
                    connectionCallback,
                    null)
            mediaBrowser!!.connect()
        }
    }

    private fun disconnect() {
        clientMethodCallHandler?.activity?.intent = Intent(Intent.ACTION_MAIN)
        if (mediaController != null) {
            mediaController = null
        }
        if (mediaBrowser != null) {
            mediaBrowser!!.disconnect()
            mediaBrowser = null
        }
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        flutterBinding = binding
        clientMethodCallHandler = ClientMethodCallHandler(binding.applicationContext)
        clientMethodCallHandler!!.init(binding.binaryMessenger)

        if (applicationContext == null) {
            applicationContext = binding.applicationContext
        }
        audioMethodCallHandler = AudioMethodCallHandler(binding.applicationContext)
        audioMethodCallHandler!!.init(binding.binaryMessenger)
        AudioService.init(audioMethodCallHandler!!)
        Log.d("tqzvbb", "onAttachedToEngine called")

        if (mediaBrowser == null) {
            connect()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        Log.d("tqzvbb", "onDetachedFromEngine called")
        if (clientMethodCallHandler != null) {
            disconnect()
        }
        clientMethodCallHandler?.dispose()
        audioMethodCallHandler?.dispose()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d("tqzvbb", "onAttachedToActivity called")
        activityBinding = binding
        clientMethodCallHandler?.activity = binding.activity
        clientMethodCallHandler?.context = binding.activity
        registerOnNewIntentListener()
        if (mediaController != null) {
            MediaControllerCompat.setMediaController(
                    clientMethodCallHandler?.activity!!, mediaController)
        }
        if (mediaBrowser != null) {
            connect()
        }

        var activity: Activity? = clientMethodCallHandler?.activity
        if (clientMethodCallHandler?.wasLaunchedFromRecents() == true) {
            activity?.intent = Intent(Intent.ACTION_MAIN)
        }
        sendNotificationClicked()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d("tqzvbb", "onDetachedFromActivityForConfigChanges called")
        newIntentListener?.let { activityBinding?.removeOnNewIntentListener(it) }
        activityBinding = null
        clientMethodCallHandler?.activity = null
        if (flutterBinding != null) {
            clientMethodCallHandler?.context = flutterBinding!!.applicationContext
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d("tqzvbb", "onReattachedToActivityForConfigChanges called")
        activityBinding = binding
        clientMethodCallHandler?.activity = binding.activity
        clientMethodCallHandler?.context = binding.activity
        registerOnNewIntentListener()
    }

    override fun onDetachedFromActivity() {
        Log.d("tqzvbb", "onDetachedFromActivity called")
        newIntentListener?.let { activityBinding?.removeOnNewIntentListener(it) }
        activityBinding = null
        newIntentListener = null
        clientMethodCallHandler?.activity = null
        if (flutterBinding != null) {
            clientMethodCallHandler?.context = flutterBinding!!.applicationContext
        }
        if (clientMethodCallHandler != null) {
            disconnect()
        }
    }

    private fun registerOnNewIntentListener() {
        activityBinding?.addOnNewIntentListener(NewIntentListener { intent: Intent? ->
            clientMethodCallHandler?.activity?.intent = intent
            sendNotificationClicked()
            true
        }.also { newIntentListener = it })
    }

    private fun sendNotificationClicked() {
        val activity: Activity? = clientMethodCallHandler?.activity
        if (activity?.intent?.action != null) {
            val clicked = activity.intent.action == AudioService.NOTIFICATION_CLICK_ACTION
            audioMethodCallHandler?.onNotiClicked()
        }
    }
}