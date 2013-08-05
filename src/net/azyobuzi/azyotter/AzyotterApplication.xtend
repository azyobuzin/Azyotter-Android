package net.azyobuzi.azyotter

import android.app.Application
import net.azyobuzi.azyotter.configuration.Accounts

class AzyotterApplication extends Application {
	public static AzyotterApplication instance
	
	new(){
		instance = this
	}
	
	override onCreate(){
		super.onCreate()
		System.setProperty("twitter4j.http.useSSL", "true")
		System.setProperty("twitter4j.oauth.consumerKey", "OAiCAi6MuqLp11WvbnvaQ")
		System.setProperty("twitter4j.oauth.consumerSecret", "IDMOATndLC4P7Jd4paEcYm1aVZUxTcZc0wWMS5UQ")
		
		Accounts.load()
	}
}