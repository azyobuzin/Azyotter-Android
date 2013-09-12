package net.azyobuzi.azyotter

import android.app.NotificationManager
import android.app.Notification

class Notifications {	
	static var NotificationManager m_manager
	
	static def initialize(NotificationManager manager){
		m_manager = manager
	}
	
	static def notify(int id, Notification notification){
		m_manager.notify(id, notification)
	}
	
	public static val TWEET_FAILED = 0
}