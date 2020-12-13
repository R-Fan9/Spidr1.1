package com.Brane.Spidr

import io.flutter.embedding.android.FlutterActivity

import android.content.Context
import android.app.NotificationManager


open class MainActivity: FlutterActivity() {

  override protected fun onResume() {
    super.onResume()

    // Removing All Notifications
    cancelAllNotifications()
  }

  private fun cancelAllNotifications() {
    val notificationManager: NotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    notificationManager.cancelAll()
  }
}
