package net.azyobuzi.azyotter.database

import org.msgpack.annotation.Message
import java.util.List
import twitter4j.EntitySupport

@Message
class TweetEntities {
	new() { }
	
	new(EntitySupport entities) {
		hashtags = entities.hashtagEntities.map[it.text]
		userMentions = entities.userMentionEntities.map[e | new UserMentionEntity() => [
			id = e.id
			screenName = e.screenName
			name = e.name
		]]
		urls = entities.URLEntities.map[e | new UrlEntity() => [
			url = e.URL
			displayUrl = e.displayURL
			expandedUrl = e.expandedURL
		]]
		media = entities.mediaEntities.map[e | new MediaEntity() => [
			url = e.URL
			displayUrl = e.displayURL
			expandedUrl = e.expandedURL
			mediaUrl = e.mediaURLHttps
		]]
	}
	
	public List<String> hashtags
	public List<UserMentionEntity> userMentions
	public List<UrlEntity> urls
	public List<MediaEntity> media
}

@Message
class UserMentionEntity {
	public long id
	public String screenName
	public String name
}

@Message
class UrlEntity {
	public String url
	public String displayUrl
	public String expandedUrl
}

@Message
class MediaEntity extends UrlEntity {
	public String mediaUrl
}