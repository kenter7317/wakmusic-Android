package com.waktaverse.music.audio_service

import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.KeyEvent

class MediaButtonReceiver : androidx.media.session.MediaButtonReceiver() {
    companion object {
        const val ACTION_NOTIFICATION_DELETE: String = "com.waktaverse.music.audio_service.intent.action.ACTION_NOTIFICATION_DELETE"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent != null
                && ACTION_NOTIFICATION_DELETE == intent.action
                && AudioService.instance != null) {
            AudioService.instance!!.handleDeleteNotification()
            return
        }
        super.onReceive(context, intent)
    }
}