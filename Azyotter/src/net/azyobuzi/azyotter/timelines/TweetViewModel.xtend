package net.azyobuzi.azyotter.timelines

import twitter4j.Status
import java.util.regex.Pattern
import java.io.Serializable
import com.google.common.collect.Iterables
import java.text.DateFormat

class TweetViewModel implements Serializable {
	new(Status model){
		this.model = model
		initDisplayText()
		initCreatedAt()
		initSource()
	}
	
	@Property Status model
	@Property String displayText
	@Property String createdAt
	@Property String sourceName
	@Property String sourceUri
	@Property String retweetedCreatedAt
	@Property String retweetedSourceName
	@Property String retweetedSourceUri
	
	private static val sourcePattern = Pattern.compile("^<a href=\"(https?://[\\w\\d/%#$&?!()~_.=+-]+)\" rel=\"nofollow\">(.+)</a>$")
	
	private def initDisplayText(){
		val entities = (if (model.retweet)
			Iterables.concat(model.retweetedStatus.URLEntities, model.retweetedStatus.mediaEntities)
		else
			Iterables.concat(model.URLEntities, model.mediaEntities)
		).sortBy[it.start]
			
		val text = if (model.retweet) model.retweetedStatus.text else model.text
		
		displayText = if (entities.empty) {
			text
		} else {
			val sb = new StringBuilder()
			entities.forEach[entity, index |
				val prevEnd = if (index > 0) entities.get(index - 1).end else 0
				sb.append(text.substring(prevEnd, entity.start))
				sb.append(entity.displayURL)
			]
			sb.append(text.substring(entities.last.end))
			sb.toString()
		}
	}
	
	private def initCreatedAt(){
		val formatter = DateFormat.getDateTimeInstance()
		createdAt = formatter.format(model.createdAt)
		if (model.retweet) retweetedCreatedAt = formatter.format(model.retweetedStatus.createdAt)
	}
	
	private def initSource(){
		val defaultUri = "https://twitter.com/"
		var matcher = sourcePattern.matcher(model.source)
		if (matcher.find()){
			sourceName = matcher.group(2)
			sourceUri = matcher.group(1)
		} else {
			sourceName = model.source
			sourceUri = defaultUri
		}
		if (model.retweet) {
			matcher = sourcePattern.matcher(model.retweetedStatus.source)
			if (matcher.find()){
				retweetedSourceName = matcher.group(2)
				retweetedSourceUri = matcher.group(1)
			} else {
				retweetedSourceName = model.source
				retweetedSourceUri = defaultUri
			}
		}
	}
}