package net.azyobuzi.azyotter.database

import java.util.Date

@Data
class TwitterStatus {
	long id
	long retweetedId
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
	double latitude
	double longitude
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
	long retweetedUserId
	String retweetedUserScreenName
	String retweetedUserName
	String retweetedUserProfileImage
	boolean retweetedUserVerified
}