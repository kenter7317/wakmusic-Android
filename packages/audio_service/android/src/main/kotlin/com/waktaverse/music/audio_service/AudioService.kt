package com.waktaverse.music.audio_service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.net.wifi.WifiManager
import android.net.wifi.WifiManager.WifiLock
import android.os.*
import android.os.PowerManager.WakeLock
import android.support.v4.media.MediaBrowserCompat
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import android.util.Log
import android.view.KeyEvent
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.core.content.getSystemService
import androidx.media.MediaBrowserServiceCompat
import androidx.media.app.NotificationCompat.MediaStyle
import androidx.media.utils.MediaConstants
import com.waktaverse.music.audio_service.models.AudioMetadata
import com.waktaverse.music.audio_service.models.AudioState
import com.waktaverse.music.audio_service.models.MediaControl
import com.waktaverse.music.audio_service.models.PlaybackState
import io.flutter.embedding.engine.FlutterEngine
import java.lang.Integer.min
import java.net.HttpURLConnection
import java.net.URL

class AudioService : MediaBrowserServiceCompat() {
    companion object {
        const val NOTIFICATION_CLICK_ACTION = "com.waktaverse.music.audio_service.NOTIFICATION_CLICK"
        const val KEYCODE_BYPASS_PLAY = KeyEvent.KEYCODE_MUTE
        const val KEYCODE_BYPASS_PAUSE = KeyEvent.KEYCODE_MEDIA_RECORD
        private const val NOTIFICATION_ID = 870724
        private const val REQUEST_CONTENT_INTENT: Int = 1000
        private const val RECENT_ROOT_ID = "recent"
        private const val BROWSABLE_ROOT_ID = "root"
        private const val AUTO_ENABLED_ACTIONS: Long = PlaybackStateCompat.ACTION_PLAY or
                PlaybackStateCompat.ACTION_PAUSE or
                PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS or
                PlaybackStateCompat.ACTION_SKIP_TO_NEXT


        var instance: AudioService? = null
        var contentIntent: PendingIntent? = null
        var isRunningService = false
            private set

        private var audioHandler: AudioHandler? = null

        fun init(handler: AudioHandler) {
            audioHandler = handler
            Log.d("tqas", "inited $handler")
        }
    }

    private var flutterEngine: FlutterEngine? = null
    private val handler: Handler = Handler(Looper.getMainLooper())

    private var config: NotificationOptions? = null
    private var mediaSession: MediaSessionCompat? = null
    private var mediaMetadata: MediaMetadataCompat? = null
    private var wakeLock: WakeLock? = null
    private var wifiLock: WifiLock? = null
    private var imageBitmap: Bitmap? = null

    private var notificationCreated: Boolean = false
    private var notificationChannelId: String? = null
    private var actions: ArrayList<MediaControl> = arrayListOf()
    private val nativeActions: ArrayList<NotificationCompat.Action> = arrayListOf()
    private val compactActionIndices: List<Int> = listOf(0, 1, 2)

    private var playbackState: PlaybackState = PlaybackState.unknown
    private var audioMetadata: AudioMetadata? = null

    fun configure() {
        config = NotificationOptions.getData(applicationContext)
        notificationChannelId = if (config?.notificationChannelId != null) {
            config!!.notificationChannelId
        } else {
            application.packageName + ".channel"
        }

        if (config?.activityClassName != null) {
            val intent = Intent(null as String?)
            intent.component = ComponentName(applicationContext, config!!.activityClassName!!)
            intent.action = NOTIFICATION_CLICK_ACTION
            var flags: Int = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            contentIntent = PendingIntent.getActivity(applicationContext,
                    REQUEST_CONTENT_INTENT, intent, flags)
        } else {
            contentIntent = null
        }

        if (config?.resumeOnClick == false) {
            mediaSession?.setMediaButtonReceiver(null)
        }
    }

//    @Synchronized
    fun setMetadata(metadata: AudioMetadata) {
        audioMetadata = metadata
        Log.d("tqts", "$metadata")
        val imageUrl = "https://i.ytimg.com/vi/${metadata.id}/hqdefault.jpg"
        imageBitmap = loadImageBitmap(imageUrl)
        mediaMetadata = MediaMetadataCompat.Builder()
                .putString(MediaMetadataCompat.METADATA_KEY_MEDIA_ID, metadata.id)
                .putString(MediaMetadataCompat.METADATA_KEY_TITLE, metadata.title)
                .putString(MediaMetadataCompat.METADATA_KEY_ARTIST, metadata.artist)
                .putLong(MediaMetadataCompat.METADATA_KEY_DURATION, metadata.duration.toLong())
                .putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_ICON_URI, imageUrl)
                .putBitmap(MediaMetadataCompat.METADATA_KEY_ALBUM_ART, imageBitmap)
                .putBitmap(MediaMetadataCompat.METADATA_KEY_DISPLAY_ICON, imageBitmap)
                .putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_TITLE, metadata.title)
                .putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_SUBTITLE, metadata.artist)
                .build()
        mediaSession?.setMetadata(mediaMetadata)
        handler.removeCallbacksAndMessages(null)
        handler.post(this::updateNotification)
    }

    private fun loadImageBitmap(url: String): Bitmap? {
        return try {
            val connection = URL(url).openConnection() as HttpURLConnection
            connection.doInput = true
            connection.connect()
            var input = connection.inputStream
            BitmapFactory.decodeStream(input)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun createAction(icon: String, label: String, code: Long): NotificationCompat.Action {
        val iconId = getResourceId(icon)
        val actionCode = (1 shl code.toInt()).toLong()
        return NotificationCompat.Action(iconId, label, buildMediaButtonPendingIntent(actionCode))
    }

    private fun getPlaybackState(): Int {
        return when (playbackState) {
            PlaybackState.playing -> PlaybackStateCompat.STATE_PLAYING
            PlaybackState.buffering -> PlaybackStateCompat.STATE_BUFFERING
            PlaybackState.paused,
            PlaybackState.ended -> PlaybackStateCompat.STATE_PAUSED
            else -> PlaybackStateCompat.STATE_NONE
        }
    }



    fun setState(state: AudioState, updateTime: Long) {
        var notificationChanged: Boolean = false
        var actions = arrayListOf(
                MediaControl("drawable/to_previous", "Previous",  4),
                if (state.playbackState == PlaybackState.playing)
                    MediaControl("drawable/pause", "Pause", 1)
                else
                    MediaControl("drawable/play", "Play", 2),
                MediaControl("drawable/to_next", "Next", 5),
                MediaControl("drawable/stop", "Stop", 0)
        )
        if (actions != this.actions) {
            notificationChanged = true
        }
        this.actions = actions
        this.nativeActions.clear()
        var actionBits: Long = 0
        for (action in actions) {
            nativeActions.add(createAction(action.icon, action.label, action.actionCode))
            actionBits = actionBits or action.actionCode
        }
        var previousState = playbackState
        playbackState = state.playbackState

        var stateBuilder = PlaybackStateCompat.Builder()
                .setActions(AUTO_ENABLED_ACTIONS or actionBits)
                .setState(getPlaybackState(), state.position.toLong(), 1F, updateTime)
                .setBufferedPosition(min(
                        state.position + 10000,
                        audioMetadata?.duration ?: Int.MAX_VALUE
                ).toLong())

        if (mediaMetadata != null) {
            val extras = Bundle()
            extras.putString(MediaConstants.PLAYBACK_STATE_EXTRAS_KEY_MEDIA_ID, mediaMetadata!!.description.mediaId)
            stateBuilder.setExtras(extras)
        }

        mediaSession?.setPlaybackState(stateBuilder.build())

        if (previousState != PlaybackState.playing
                && playbackState == PlaybackState.playing) {
            enterPlayingState()
        } else if (previousState == PlaybackState.playing
                && playbackState != PlaybackState.playing) {
            exitPlayingState()
        }

        if (previousState.isPlaying() && playbackState.isNotPlaying()) {
            stop()
        } else /*if (playbackState.isPlaying() && notificationChanged)*/ {
            updateNotification()
        }
    }

    fun stop() {
        Log.d("tqzzz", "tlqkf")
        deactivateMediaSession()
        stopSelf()
    }

    override fun onCreate() {
        super.onCreate()
        Log.d("tqtzzv", "onCreate")
        instance = this
        notificationCreated = false
        mediaSession = MediaSessionCompat(this, "media-session")

        configure()

        val stateBuilder = PlaybackStateCompat.Builder()
                .setActions(AUTO_ENABLED_ACTIONS)
        mediaSession?.setPlaybackState(stateBuilder.build())
        mediaSession?.setCallback(MediaSessionCallback(audioHandler))
        sessionToken = mediaSession?.sessionToken

        val pm: PowerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, AudioService::class.java.name)

        val wm: WifiManager = getSystemService(Context.WIFI_SERVICE) as WifiManager
        wifiLock = wm.createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, AudioService::class.java.name)
        flutterEngine = AudioServicePlugin.getFlutterEngine(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("tqpppl", "onStartCommand called")
        androidx.media.session.MediaButtonReceiver.handleIntent(mediaSession, intent)
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("tqppzl", "onDestroy called")
//        audioHandler?.onDestroy()
        audioHandler = null
        mediaMetadata = null
        imageBitmap = null
        actions.clear()
        releaseMediaSession()
        stopForeground(if (config!!.resumeOnClick) STOP_FOREGROUND_DETACH else STOP_FOREGROUND_REMOVE)
        releaseWakeLock()
        instance = null
        notificationCreated = false
    }

    private fun getResourceId(resource: String): Int {
        val parts = resource.split("/")
        val resourceType = parts[0]
        val resourceName = parts[1]
        return resources.getIdentifier(resourceName, resourceType, applicationContext.packageName)
    }

    private fun toKeyCode(action: Long): Int {
        return when (action) {
            PlaybackStateCompat.ACTION_PLAY -> KEYCODE_BYPASS_PLAY
            PlaybackStateCompat.ACTION_PAUSE -> KEYCODE_BYPASS_PAUSE
            else -> PlaybackStateCompat.toKeyCode(action)
        }
    }

    private fun buildMediaButtonPendingIntent(action: Long): PendingIntent? {
        val keyCode: Int = toKeyCode(action)
        if (keyCode == KeyEvent.KEYCODE_UNKNOWN) return null
        val intent = Intent(this, MediaButtonReceiver::class.java)
        intent.action = Intent.ACTION_MEDIA_BUTTON
        intent.putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
        var flags = PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(this, keyCode, intent, flags)
    }

//    private fun buildDeletePendingIntent(): PendingIntent? {
//        val intent = Intent(this, MediaButtonReceiver::class.java)
//        intent.action = MediaButtonReceiver.ACTION_NOTIFICATION_DELETE
//
//        return PendingIntent.getBroadcast(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
//    }

    private fun buildNotification(): Notification {
        var builder = getNotificationBuilder()
        if (mediaMetadata != null) {
            var description = mediaMetadata?.description
            if (description?.title != null) builder.setContentTitle(description.title)
            if (description?.subtitle != null) builder.setContentText(description.subtitle)
            if (description?.description != null) builder.setSubText(description.description)
            synchronized (this) {
                if (imageBitmap != null) {
                    builder.setLargeIcon(imageBitmap)
                }
            }
        }
        if (config?.notificationClickStartsActivity == true) {
            builder.setContentIntent(mediaSession?.controller?.sessionActivity)
        }
//        if (config?.notificationColor != -1) {
//            builder.color = config?.notificationColor ?: 16777216
//        }
        for (action in nativeActions) {
            builder.addAction(action)
        }
        val style = MediaStyle()
                .setMediaSession(mediaSession?.sessionToken)
                .setShowActionsInCompactView(*compactActionIndices.toIntArray())
        if (config?.notificationOngoing == true) {
            style.setShowCancelButton(true)
            style.setCancelButtonIntent(buildMediaButtonPendingIntent(PlaybackStateCompat.ACTION_STOP))
        }
        builder.setStyle(style)
        return builder.build()
    }

    private fun getNotificationManager(): NotificationManager {
        return getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    private fun getNotificationBuilder(): NotificationCompat.Builder {
        var notificationBuilder: NotificationCompat.Builder? = null
        if (notificationBuilder == null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                createChannel()
            }
            notificationBuilder = NotificationCompat.Builder(this, notificationChannelId!!)
                    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                    .setShowWhen(false)
//                    .setDeleteIntent(buildDeletePendingIntent())
        }
        val iconId: Int = getResourceId(config?.notificationIcon ?: "")
        notificationBuilder.setSmallIcon(iconId)
        return notificationBuilder
    }

    fun activateMediaSession() {
        if (mediaSession?.isActive == false) {
            mediaSession?.isActive = true
        }
    }

    private fun deactivateMediaSession() {
        if (mediaSession?.isActive == true) {
            mediaSession?.isActive = false
        }
        getNotificationManager().cancel(NOTIFICATION_ID)
    }

    private fun updateNotification() {
        if (notificationCreated) {
            getNotificationManager().notify(NOTIFICATION_ID, buildNotification())
        }
    }

    private fun enterPlayingState() {
        ContextCompat.startForegroundService(
                this, Intent(this@AudioService, AudioService::class.java))
        if (mediaSession?.isActive == false) {
            mediaSession?.isActive = true
        }

        acquireWakeLock()
        mediaSession?.setSessionActivity(contentIntent)
        internalStartForeground()
    }

    private fun exitPlayingState() {
        if (config?.stopForegroundOnPause == true) {
            exitForegroundState()
        }
    }

    private fun exitForegroundState() {
        stopForeground(STOP_FOREGROUND_DETACH)
        releaseWakeLock()
    }

    private fun internalStartForeground() {
        startForeground(NOTIFICATION_ID, buildNotification())
        notificationCreated = true
    }

    private fun acquireWakeLock() {
        if (wakeLock?.isHeld == false) wakeLock?.acquire()
        if (wifiLock?.isHeld == false) wifiLock?.acquire()
    }

    private fun releaseWakeLock() {
        if (wakeLock?.isHeld == true) wakeLock?.release()
        if (wifiLock?.isHeld == true) wifiLock?.release()
    }

    private fun releaseMediaSession() {
        if (mediaSession == null) return
        deactivateMediaSession()
        mediaSession?.release()
        mediaSession = null
    }

    fun handleDeleteNotification() {
        audioHandler?.onNotiDeleted()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun createChannel() {
        val nm = getNotificationManager()
        var channel = nm.getNotificationChannel(notificationChannelId)
        if (channel == null) {
            channel = NotificationChannel(notificationChannelId,
                    config?.notificationChannelName,
                    NotificationManager.IMPORTANCE_LOW)
            channel.setShowBadge(config?.showNotificationBadge ?: false)
            channel.description = config?.notificationChannelDescription
            nm.createNotificationChannel(channel)
        }
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        audioHandler?.onTaskRemoved()
        super.onTaskRemoved(rootIntent)
    }

    override fun onGetRoot(clientPackageName: String, clientUid: Int, rootHints: Bundle?): BrowserRoot? {
        val isRecentRequest = rootHints?.getBoolean(BrowserRoot.EXTRA_RECENT) ?: false
        return BrowserRoot(if (isRecentRequest) RECENT_ROOT_ID else BROWSABLE_ROOT_ID, null)
    }

    override fun onLoadChildren(parentId: String, result: Result<MutableList<MediaBrowserCompat.MediaItem>>) {
        result.sendResult(mutableListOf())
    }
}