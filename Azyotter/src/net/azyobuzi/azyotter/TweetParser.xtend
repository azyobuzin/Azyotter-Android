package net.azyobuzi.azyotter

import twitter4j.Status
import com.google.common.collect.Iterables
import java.util.regex.Pattern

class TweetParser {
	private new() { }
	
	static def createDisplayText(Status status) {
		val entities = (if (status.retweet)
			Iterables.concat(status.retweetedStatus.URLEntities, status.retweetedStatus.mediaEntities)
		else
			Iterables.concat(status.URLEntities, status.mediaEntities)
		).sortBy[it.start]
			
		val text = if (status.retweet) status.retweetedStatus.text else status.text
		
		if (entities.empty) {
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
	
	static val sourcePattern = Pattern.compile("^<a href=\"(https?://[\\w\\d/%#$&?!()~_.=+-]+)\" rel=\"nofollow\">(.+)</a>$")
	
	static def getSourceName(Status status) {
		val matcher = sourcePattern.matcher(status.source)
		if (matcher.find()) matcher.group(2)
		else status.source
	}
	
	static def getSourceUri(Status status) {
		val matcher = sourcePattern.matcher(status.source)
		if (matcher.find()) matcher.group(1)
		else "https://twitter.com/"
	}
}