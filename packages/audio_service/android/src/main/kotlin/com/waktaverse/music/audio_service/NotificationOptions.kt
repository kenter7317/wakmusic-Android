package com.waktaverse.music.audio_service

import android.content.Context

data class NotificationOptions(
        val resumeOnClick: Boolean,
        val notificationChannelId: String?,
        val notificationChannelName: String?,
        val notificationChannelDescription: String?,
        val notificationColor: Int,
        val notificationIcon: String,
        val showNotificationBadge: Boolean,
        val notificationClickStartsActivity: Boolean,
        val notificationOngoing: Boolean,
        val stopForegroundOnPause: Boolean,
        val activityClassName: String?,
        val browsableRootExtras: String?,
) {
    companion object {
        fun getData(context: Context): NotificationOptions {
            val prefs = context.getSharedPreferences(
                    PrefsKey.NOTIFICATION_OPTIONS_PREFS, Context.MODE_PRIVATE)

            val resumeOnClick = prefs.getBoolean(PrefsKey.RESUME_ON_CLICK, true)
            val notificationChannelId = prefs.getString(PrefsKey.NOTIFICATION_CHANNEL_ID, null)
            val notificationChannelName = prefs.getString(PrefsKey.NOTIFICATION_CHANNEL_NAME, null)
            val notificationChannelDescription = prefs.getString(PrefsKey.NOTIFICATION_CHANNEL_DESCRIPTION, null)
            val notificationColor = prefs.getInt(PrefsKey.NOTIFICATION_COLOR, -1)
            val notificationIcon = prefs.getString(PrefsKey.NOTIFICATION_ICON, "mipmap/ic_launcher") ?: ""
            val showNotificationBadge = prefs.getBoolean(PrefsKey.SHOW_NOTIFICATION_BADGE, false)
            val notificationClickStartsActivity = prefs.getBoolean(PrefsKey.NOTIFICATION_CLICK_STARTS_ACTIVITY, true)
            val notificationOngoing = prefs.getBoolean(PrefsKey.NOTIFICATION_ONGOING, false)
            val stopForegroundOnPause = prefs.getBoolean(PrefsKey.STOP_FOREGROUND_ON_PAUSE, true)
            val activityClassName = prefs.getString(PrefsKey.ACTIVITY_CLASS_NAME, null)
            val browsableRootExtras = prefs.getString(PrefsKey.BROWSABLE_ROOT_EXTRAS, null)

            return NotificationOptions(
                    resumeOnClick,
                    notificationChannelId,
                    notificationChannelName,
                    notificationChannelDescription,
                    notificationColor,
                    notificationIcon,
                    showNotificationBadge,
                    notificationClickStartsActivity,
                    notificationOngoing,
                    stopForegroundOnPause,
                    activityClassName,
                    browsableRootExtras,
            )
        }

        fun putData(context: Context, map: Map<*, *>?) {
            val prefs = context.getSharedPreferences(
                    PrefsKey.NOTIFICATION_OPTIONS_PREFS, Context.MODE_PRIVATE)

            val resumeOnClick = map?.get(PrefsKey.RESUME_ON_CLICK) as? Boolean ?: true
            val notificationChannelId = map?.get(PrefsKey.NOTIFICATION_CHANNEL_ID)
                    as? String ?: "com.waktaverse.music"
            val notificationChannelName = map?.get(PrefsKey.NOTIFICATION_CHANNEL_NAME)
                    as? String ?: "Waktaverse Music"
            val notificationChannelDescription = map?.get(PrefsKey.NOTIFICATION_CHANNEL_DESCRIPTION)
                    as? String ?: ""
            val notificationColor = map?.get(PrefsKey.NOTIFICATION_COLOR) as? Int ?: 16777216
            val notificationIcon = map?.get(PrefsKey.NOTIFICATION_ICON)
                    as? String ?: "mipmap/ic_launcher"
            val showNotificationBadge = map?.get(PrefsKey.SHOW_NOTIFICATION_BADGE)
                    as? Boolean ?: false
            val notificationClickStartsActivity = map?.get(PrefsKey.NOTIFICATION_CLICK_STARTS_ACTIVITY)
                    as? Boolean ?: true
            val notificationOngoing = map?.get(PrefsKey.NOTIFICATION_ONGOING) as? Boolean ?: false
            val stopForegroundOnPause = map?.get(PrefsKey.STOP_FOREGROUND_ON_PAUSE)
                    as? Boolean ?: true
            val activityClassName = map?.get(PrefsKey.ACTIVITY_CLASS_NAME) as? String?
            val browsableRootExtras = map?.get(PrefsKey.BROWSABLE_ROOT_EXTRAS) as? String?

            with(prefs.edit()) {
                putBoolean(PrefsKey.RESUME_ON_CLICK, resumeOnClick)
                putString(PrefsKey.NOTIFICATION_CHANNEL_ID, notificationChannelId)
                putString(PrefsKey.NOTIFICATION_CHANNEL_NAME, notificationChannelName)
                putString(PrefsKey.NOTIFICATION_CHANNEL_DESCRIPTION, notificationChannelDescription)
                putInt(PrefsKey.NOTIFICATION_COLOR, notificationColor)
                putString(PrefsKey.NOTIFICATION_ICON, notificationIcon)
                putBoolean(PrefsKey.SHOW_NOTIFICATION_BADGE, showNotificationBadge)
                putBoolean(PrefsKey.NOTIFICATION_CLICK_STARTS_ACTIVITY, notificationClickStartsActivity)
                putBoolean(PrefsKey.NOTIFICATION_ONGOING, notificationOngoing)
                putBoolean(PrefsKey.STOP_FOREGROUND_ON_PAUSE, stopForegroundOnPause)
                putString(PrefsKey.ACTIVITY_CLASS_NAME, activityClassName)
                putString(PrefsKey.BROWSABLE_ROOT_EXTRAS, browsableRootExtras)
                commit()
            }
        }
    }
}
