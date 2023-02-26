package com.waktaverse.music.audio_service

import android.content.Intent
import android.os.Build
import android.support.v4.media.session.MediaSessionCompat
import android.util.Log
import android.view.KeyEvent
import com.waktaverse.music.audio_service.models.MediaButton

class MediaSessionCallback(private val audioHandler: AudioHandler?): MediaSessionCompat.Callback() {
    override fun onPlay() {
        audioHandler?.onPlay()
    }

    override fun onPause() {
        audioHandler?.onPause()
    }

    override fun onStop() {
        audioHandler?.onStop()
    }

    override fun onSkipToNext() {
        audioHandler?.onToNext()
    }

    override fun onSkipToPrevious() {
        audioHandler?.onToPrevious()
    }

    override fun onSeekTo(pos: Long) {
        audioHandler?.onSeek(pos)
    }

    override fun onMediaButtonEvent(mediaButtonEvent: Intent?): Boolean {
        if (audioHandler == null) return false

        val event: KeyEvent? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            mediaButtonEvent?.extras?.getParcelable(Intent.EXTRA_KEY_EVENT, KeyEvent::class.java)
        } else {
            mediaButtonEvent?.extras?.getParcelable(Intent.EXTRA_KEY_EVENT)
        }
        Log.d("tqmedbev", "zzz ${event?.keyCode}")

        if (event?.action == KeyEvent.ACTION_DOWN) {
            when (event.keyCode) {
                AudioService.KEYCODE_BYPASS_PLAY -> onPlay()
                AudioService.KEYCODE_BYPASS_PAUSE -> onPause()
                KeyEvent.KEYCODE_MEDIA_STOP -> onStop()
                KeyEvent.KEYCODE_MEDIA_NEXT -> onSkipToNext()
                KeyEvent.KEYCODE_MEDIA_PREVIOUS -> onSkipToPrevious()
                KeyEvent.KEYCODE_MEDIA_PLAY,
                KeyEvent.KEYCODE_MEDIA_PAUSE,
                KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE -> {
                    audioHandler.onButtonClicked(eventToButton(event))
                }
            }
        }
        return true
    }

    private fun eventToButton(event: KeyEvent): MediaButton {
        return when (event.keyCode) {
            KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE,
            KeyEvent.KEYCODE_HEADSETHOOK -> MediaButton.media
            KeyEvent.KEYCODE_MEDIA_NEXT -> MediaButton.next
            KeyEvent.KEYCODE_MEDIA_PREVIOUS -> MediaButton.prev
            else -> MediaButton.media
        }
    }
}