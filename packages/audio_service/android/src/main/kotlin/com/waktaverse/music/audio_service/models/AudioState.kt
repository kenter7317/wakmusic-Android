package com.waktaverse.music.audio_service.models

data class AudioState(
        val playbackState: PlaybackState,
        val position: Int,
        val nextPlayable: Boolean,
        val prevPlayable: Boolean,
)
