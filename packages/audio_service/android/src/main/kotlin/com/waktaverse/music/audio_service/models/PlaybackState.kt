package com.waktaverse.music.audio_service.models

enum class PlaybackState(val code: Int) {
    unknown(-2),
    unStarted(-1),
    ended(0),
    playing(1),
    paused(2),
    buffering(3),
    cued(5);

    companion object {
        fun byCode(code: Int): PlaybackState {
            val state = PlaybackState.values().find { it.code == code }
            return state ?: unknown
        }

    }

    fun isPlaying(): Boolean {
        return listOf(ended, playing, paused, buffering).contains(this)
    }

    fun isNotPlaying(): Boolean {
        return listOf(unknown, unStarted, cued).contains(this)
    }
}