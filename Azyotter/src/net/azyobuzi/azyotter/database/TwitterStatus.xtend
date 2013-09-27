package net.azyobuzi.azyotter.database

import java.util.Date
import android.database.Cursor

@Data
class TwitterStatus {
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
	
	static def fromCursor(Cursor cursor) {
		new TwitterStatus(
			cursor.getLong(0),
			if (cursor.isNull(1)) null else cursor.getLong(1),
			cursor.getLong(2),
			cursor.getString(3),
			cursor.getLong(4),
			new Date(cursor.getLong(5)),
			if (cursor.isNull(6)) null else new Date(cursor.getLong(6)),
			cursor.getString(7),
			cursor.getString(8),
			cursor.getString(9),
			cursor.getString(10),
			cursor.getString(11),
			cursor.getString(12),
			cursor.getString(13),
			cursor.getLong(14),
			cursor.getLong(15),
			if (cursor.isNull(16)) null else cursor.getDouble(16),
			if (cursor.isNull(17)) null else cursor.getDouble(17),
			cursor.getString(18),
			cursor.getString(19),
			cursor.getString(20),
			cursor.getString(21),
			cursor.getLong(22),
			cursor.getString(23),
			cursor.getString(24),
			cursor.getString(25),
			cursor.getInt(26) > 0,
			cursor.getInt(27) > 0,
			if (cursor.isNull(28)) null else cursor.getLong(28),
			cursor.getString(29),
			cursor.getString(30),
			cursor.getString(31),
			if (cursor.isNull(32)) null else cursor.getInt(32) > 0
		)
	}
}