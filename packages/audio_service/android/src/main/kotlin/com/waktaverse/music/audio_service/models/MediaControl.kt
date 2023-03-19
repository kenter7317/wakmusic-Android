package com.waktaverse.music.audio_service.models

data class MediaControl(
        val icon: String,
        val label: String,
        val actionCode: Long,
) {
    companion object {
        override fun equals(other: Any?): Boolean {
            return if (other is MediaControl) {
                val (icon, label, actionCode) = other as MediaControl
                icon == icon && label == label && actionCode == actionCode
            } else {
                false
            }
        }
    }
}
