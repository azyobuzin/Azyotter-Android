package net.azyobuzi.azyotter.database

import android.database.sqlite.SQLiteOpenHelper
import android.database.sqlite.SQLiteDatabase
import net.azyobuzi.azyotter.AzyotterApplication

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
				"_id integer primary key",
				"retweeted_id",
				"in_reply_to_user_id",
				"in_reply_to_screen_name",
				"in_reply_to_status_id",
				"created_at",
				"retweeted_created_at",
				"text",
				"retweeted_text",
				"display_text",
				"source_name",
				"source_uri",
				"retweeted_source_name",
				"retweeted_source_uri",
				"favorite_count",
				"retweet_count",
				"latitude",
				"longitude",
				"place_id",
				"place_name",
				"place_full_name",
				"place_country",
				"user_id",
				"user_screen_name",
				"user_name",
				"user_profile_image",
				"user_protected",
				"user_verified",
				"retweeted_user_id",
				"retweeted_user_screen_name",
				"retweeted_user_name",
				"retweeted_user_profile_image",
				"retweeted_user_verified"
			].join(", ")
			+ ")"
		)
		db
	}
}