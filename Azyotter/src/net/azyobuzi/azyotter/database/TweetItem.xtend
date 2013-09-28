package net.azyobuzi.azyotter.database

import java.util.Date
import android.database.Cursor

@Data
class TweetItem {
	long id
	Long retweetedId
	long inReplyToUserId
	String inReplyToScreenName
	long inReplyToStatusId
	Date createdAt
	Date retweetedCreatedAt
	String text
	String retweetedText
	String displayText
	String sourceName
	String sourceUri
	String retweetedSourceName
	String retweetedSourceUri
	long favoriteCount
	long retweetCount
	Double latitude
	Double longitude
	String placeId
	String placeName
	String placeFullName
	String placeCountry
	
	//User
	long userId
	String userScreenName
	String userName
	String userProfileImage
	boolean userProtected
	boolean userVerified
	
	//Retweeted User
	Long retweetedUserId
	String retweetedUserScreenName
	String retweetedUserName
	String retweetedUserProfileImage
	Boolean retweetedUserVerified
	
	//Columns
	public static val ID = "_id"
	public static val RETWEETED_ID = "retweeted_id"
	public static val IN_REPLY_TO_USER_ID = "in_reply_to_user_id"
	public static val IN_REPLY_TO_SCREEN_NAME = "in_reply_to_screen_name"
	public static val IN_REPLY_TO_STATUS_ID = "in_reply_to_status_id"
	public static val CREATED_AT = "created_at"
	public static val RETWEETED_CREATED_AT = "retweeted_created_at"
	public static val TEXT = "text"
	public static val RETWEETED_TEXT = "retweeted_text"
	public static val DISPLAY_TEXT = "display_text"
	public static val SOURCE_NAME = "source_name"
	public static val SOURCE_URI = "source_uri"
	public static val RETWEETED_SOURCE_NAME = "retweeted_source_name"
	public static val RETWEETED_SOURCE_URI = "retweeted_source_uri"
	public static val FAVORITE_COUNT = "favorite_count"
	public static val RETWEET_COUNT = "retweet_count"
	public static val LATITUDE = "latitude"
	public static val LONGITUDE = "longitude"
	public static val PLACE_ID = "place_id"
	public static val PLACE_NAME = "place_name"
	public static val PLACE_FULL_NAME = "place_full_name"
	public static val PLACE_COUNTRY = "place_country"
	public static val USER_ID = "user_id"
	public static val USER_SCREEN_NAME = "user_screen_name"
	public static val USER_NAME = "user_name"
	public static val USER_PROFILE_IMAGE = "user_profile_image"
	public static val USER_PROTECTED = "user_protected"
	public static val USER_VERIFIED = "user_verified"
	public static val RETWEETED_USER_ID = "retweeted_user_id"
	public static val RETWEETED_USER_SCREEN_NAME = "retweeted_user_screen_name"
	public static val RETWEETED_USER_NAME = "retweeted_user_name"
	public static val RETWEETED_USER_PROFILE_IMAGE = "retweeted_user_profile_image"
	public static val RETWEETED_USER_VERIFIED = "retweeted_user_verified"
	
	static def fromCursor(Cursor cursor) {
		new TweetItem(
			cursor.getLong(cursor.getColumnIndex(ID)),
			if (cursor.isNull(cursor.getColumnIndex(RETWEETED_ID))) null
			else cursor.getLong(cursor.getColumnIndex(RETWEETED_ID)),
			cursor.getLong(cursor.getColumnIndex(IN_REPLY_TO_USER_ID)),
			cursor.getString(cursor.getColumnIndex(IN_REPLY_TO_SCREEN_NAME)),
			cursor.getLong(cursor.getColumnIndex(IN_REPLY_TO_STATUS_ID)),
			new Date(cursor.getLong(cursor.getColumnIndex(CREATED_AT))),
			if (cursor.isNull(cursor.getColumnIndex(RETWEETED_CREATED_AT))) null
			else new Date(cursor.getLong(cursor.getColumnIndex(RETWEETED_CREATED_AT))),
			cursor.getString(cursor.getColumnIndex(TEXT)),
			cursor.getString(cursor.getColumnIndex(RETWEETED_TEXT)),
			cursor.getString(cursor.getColumnIndex(DISPLAY_TEXT)),
			cursor.getString(cursor.getColumnIndex(SOURCE_NAME)),
			cursor.getString(cursor.getColumnIndex(SOURCE_URI)),
			cursor.getString(cursor.getColumnIndex(RETWEETED_SOURCE_NAME)),
			cursor.getString(cursor.getColumnIndex(RETWEETED_SOURCE_URI)),
			cursor.getLong(cursor.getColumnIndex(FAVORITE_COUNT)),
			cursor.getLong(cursor.getColumnIndex(RETWEET_COUNT)),
			if (cursor.isNull(cursor.getColumnIndex(LATITUDE))) null
			else cursor.getDouble(cursor.getColumnIndex(LATITUDE)),
			if (cursor.isNull(cursor.getColumnIndex(LONGITUDE))) null
			else cursor.getDouble(cursor.getColumnIndex(LONGITUDE)),
			cursor.getString(cursor.getColumnIndex(PLACE_ID)),
			cursor.getString(cursor.getColumnIndex(PLACE_NAME)),
			cursor.getString(cursor.getColumnIndex(PLACE_FULL_NAME)),
			cursor.getString(cursor.getColumnIndex(PLACE_COUNTRY)),
			cursor.getLong(cursor.getColumnIndex(USER_ID)),
			cursor.getString(cursor.getColumnIndex(USER_SCREEN_NAME)),
			cursor.getString(cursor.getColumnIndex(USER_NAME)),
			cursor.getString(cursor.getColumnIndex(USER_PROFILE_IMAGE)),
			cursor.getInt(cursor.getColumnIndex(USER_PROTECTED)) > 0,
			cursor.getInt(cursor.getColumnIndex(USER_VERIFIED)) > 0,
			if (cursor.isNull(cursor.getColumnIndex(RETWEETED_USER_ID))) null
			else cursor.getLong(cursor.getColumnIndex(RETWEETED_USER_ID)),
			cursor.getString(cursor.getColumnIndex(RETWEETED_USER_SCREEN_NAME)),
			cursor.getString(cursor.getColumnIndex(RETWEETED_USER_NAME)),
			cursor.getString(cursor.getColumnIndex(RETWEETED_USER_PROFILE_IMAGE)),
			if (cursor.isNull(cursor.getColumnIndex(RETWEETED_USER_VERIFIED))) null
			else cursor.getInt(cursor.getColumnIndex(RETWEETED_USER_VERIFIED)) > 0
		)
	}
}