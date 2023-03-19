package com.waktaverse.music.audio_service

import com.waktaverse.music.audio_service.models.MediaButton

interface AudioHandler {
    fun onPlay()
    fun onPause()
    fun onStop()
    fun onToNext()
    fun onToPrevious()
    fun onSeek(pos: Long)
    fun onButtonClicked(button: MediaButton)
    fun onNotiClicked()
    fun onNotiDeleted()
    fun onTaskRemoved()
}