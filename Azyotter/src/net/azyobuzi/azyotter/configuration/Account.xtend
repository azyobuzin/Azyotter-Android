package net.azyobuzi.azyotter.configuration

import android.content.SharedPreferences
import twitter4j.auth.AccessToken
import net.azyobuzi.azyotter.AzyotterApplication
import android.content.Context

class Account {
	new(long id){
		this.id = id
		sp = AzyotterApplication.instance.getSharedPreferences("account_" + id, Context.MODE_PRIVATE)
		screenName = sp.getString("screenName", "")
		oauthToken = sp.getString("oauthToken", "")
		oauthTokenSecret = sp.getString("oauthTokenSecret", "")
	}
	
	val SharedPreferences sp
	
	val long id
	def getId(){
		id
	}
	
	var String screenName
	def getScreenName(){
		screenName
	}
	def setScreenName(String value){
		screenName = value
		sp.edit().putString("screenName", value).apply()
	}
	
	var String oauthToken
	def getOAuthToken(){
		oauthToken
	}
	def setOAuthToken(String value){
		oauthToken = value
		sp.edit().putString("oauthToken", value).apply()
	}
	
	var String oauthTokenSecret
	def getOAuthTokenSecret(){
		oauthTokenSecret
	}
	def setOAuthTokenSecret(String value){
		oauthTokenSecret = value
		sp.edit().putString("oauthTokenSecret", value).apply()
	}
	
	def toAccessToken(){
		new AccessToken(OAuthToken, OAuthTokenSecret)
	}
	
	def clear(){
		sp.edit().clear().apply()
	}
}