package com.waktaverse.music.audio_service

object PrefsKey {
    private const val prefix = "com.waktaverse.music.audio_service.prefs"

    const val NOTIFICATION_OPTIONS_PREFS = prefix + "NOTIFICATION_OPTIONS"

    const val RESUME_ON_CLICK = "resumeOnClick"
    const val NOTIFICATION_CHANNEL_ID = "notificationChannelId"
    const val NOTIFICATION_CHANNEL_NAME = "notificationChannelName"
    const val NOTIFICATION_CHANNEL_DESCRIPTION = "notificationChannelDescription"
    const val NOTIFICATION_COLOR = "notificationColor"
    const val NOTIFICATION_ICON = "notificationIcon"
    const val SHOW_NOTIFICATION_BADGE = "showNotificationBadge"
    const val NOTIFICATION_CLICK_STARTS_ACTIVITY = "notificationClickStartsActivity"
    const val NOTIFICATION_ONGOING = "notificationOngoing"
    const val STOP_FOREGROUND_ON_PAUSE = "stopForegroundOnPause"
    const val ACTIVITY_CLASS_NAME = "activityClassName"
    const val BROWSABLE_ROOT_EXTRAS = "browsableRootExtras"
}