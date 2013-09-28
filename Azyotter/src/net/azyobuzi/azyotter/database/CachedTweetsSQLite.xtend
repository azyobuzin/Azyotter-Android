package net.azyobuzi.azyotter.database

import android.database.sqlite.SQLiteOpenHelper
import android.database.sqlite.SQLiteDatabase
import net.azyobuzi.azyotter.AzyotterApplication
import static net.azyobuzi.azyotter.database.TweetItem.*

class CachedTweetsSQLite extends SQLiteOpenHelper {
	static val DATABASE_FILENAME = "tweets.sqlite"
	static val DATABASE_VERSION = 1
	
	private new() {
		super(AzyotterApplication.instance, DATABASE_FILENAME, null, DATABASE_VERSION)
	}
	
	static var CachedTweetsSQLite instance
	static def getInstance() {
		instance = instance ?: new CachedTweetsSQLite()
	}
	
	override onCreate(SQLiteDatabase db) {
		// Nothing to do?
	}
	
	override onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		// Nothing to do
	}
	
	def createTableIfNotExists(String table) {
		val db = writableDatabase
		db.beginTransaction()
		db.execSQL("CREATE TABLE IF NOT EXISTS " + table + "("
			+ #[
				ID + " integer primary key",
				RETWEETED_ID,
				IN_REPLY_TO_USER_ID,
				IN_REPLY_TO_SCREEN_NAME,
				IN_REPLY_TO_STATUS_ID,
				CREATED_AT,
				RETWEETED_CREATED_AT,
				TEXT,
				RETWEETED_TEXT,
				DISPLAY_TEXT,
				SOURCE_NAME,
				SOURCE_URI,
				RETWEETED_SOURCE_NAME,
				RETWEETED_SOURCE_URI,
				FAVORITE_COUNT,
				RETWEET_COUNT,
				LATITUDE,
				LONGITUDE,
				PLACE_ID,
				PLACE_NAME,
				PLACE_FULL_NAME,
				PLACE_COUNTRY,
				USER_ID,
				USER_SCREEN_NAME,
				USER_NAME,
				USER_PROFILE_IMAGE,
				USER_PROTECTED,
				USER_VERIFIED,
				RETWEETED_USER_ID,
				RETWEETED_USER_SCREEN_NAME,
				RETWEETED_USER_NAME,
				RETWEETED_USER_PROFILE_IMAGE,
				RETWEETED_USER_VERIFIED
			].join(", ")
			+ ")"
		)
		db
	}
}