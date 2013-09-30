package net.azyobuzi.azyotter.timelines

import android.os.Bundle
import twitter4j.Status
import android.support.v4.app.LoaderManager
import android.database.Cursor
import android.support.v4.content.Loader
import android.content.ContentValues
import net.azyobuzi.azyotter.TweetParser
import android.support.v4.content.AsyncTaskLoader
import android.content.Context
import net.azyobuzi.azyotter.database.CachedTweetsSQLite
import android.database.SQLException
import net.azyobuzi.azyotter.configuration.Tab
import net.azyobuzi.azyotter.configuration.Tabs
import static net.azyobuzi.azyotter.database.TweetItem.*
import org.msgpack.MessagePack
import net.azyobuzi.azyotter.database.TweetEntities

abstract class TabFragment extends TimelineFragment implements LoaderManager.LoaderCallbacks<Cursor> {
	protected var Tab tab
	protected var TweetAdapter adapter
	static val CACHED_TWEETS_LOADER_ID = 0
		
	override onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState)
		
		if (savedInstanceState != null){
			if (savedInstanceState.containsKey("tab_id")){
				tab = Tabs.list.filter[it.id == savedInstanceState.getLong("tab_id")].head
			}
		}
				
		adapter = new TweetAdapter(activity)
		setListAdapter(adapter)
		loaderManager.initLoader(CACHED_TWEETS_LOADER_ID, null, this)
	}
	
	override onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState)
		outState.putLong("tab_id", tab.id)
	}
	
	override onDestroyView() {
		super.onDestroyView()
		loaderManager.destroyLoader(CACHED_TWEETS_LOADER_ID)
	}
	
	def void reload()
	
	@Property Runnable onCompleteReload
	
	def completedReload(){
		onCompleteReload?.run()
	}
	
	protected def completeReload(Iterable<Status> newTweets) {
		val tweetsList = newTweets.toList()
		val table = "tab_" + tab.id
		val db = CachedTweetsSQLite.instance.createTableIfNotExists(table)
		try {
			val cursor = db.query(table, #["_id"],
				tweetsList.map["_id = ?"].join(" OR "),
				tweetsList.map[String.valueOf(it.id)].toArray(#[]),
				null, null, null
			)
			if (!cursor.moveToFirst()) {
				cursor.close()
				db.delete(table, null, null)
			} else cursor.close()
			
			val msgpack = new MessagePack()
			tweetsList.forEach[tweet |
				val baseTweet = if (tweet.retweet) tweet.retweetedStatus else tweet
				db.replace(table, null, new ContentValues() => [
					put(ID, tweet.id)
					if (tweet.retweet) put(RETWEETED_ID, tweet.retweetedStatus.id)
					put(IN_REPLY_TO_USER_ID, baseTweet.inReplyToUserId)
					put(IN_REPLY_TO_SCREEN_NAME, baseTweet.inReplyToScreenName)
					put(IN_REPLY_TO_STATUS_ID, baseTweet.inReplyToStatusId)
					put(CREATED_AT, tweet.createdAt.time)
					if (tweet.retweet) put(RETWEETED_CREATED_AT, tweet.retweetedStatus.createdAt.time)
					put(TEXT, tweet.text)
					if (tweet.retweet) put(RETWEETED_TEXT, tweet.retweetedStatus.text)
					put(DISPLAY_TEXT, TweetParser.createDisplayText(tweet))
					put(SOURCE_NAME, TweetParser.getSourceName(tweet))
					put(SOURCE_URI, TweetParser.getSourceUri(tweet))
					if (tweet.retweet) {
						put(RETWEETED_SOURCE_NAME, TweetParser.getSourceName(tweet.retweetedStatus))
						put(RETWEETED_SOURCE_URI, TweetParser.getSourceUri(tweet.retweetedStatus))
					}
					put(FAVORITE_COUNT, baseTweet.favoriteCount)
					put(RETWEET_COUNT, baseTweet.retweetCount)
					val geo = baseTweet.geoLocation
					if (geo != null) {
						put(LATITUDE, geo.latitude)
						put(LONGITUDE, geo.longitude)
					}
					val place = baseTweet.place
					if (place != null) {
						put(PLACE_ID, place.id)
						put(PLACE_NAME, place.name)
						put(PLACE_FULL_NAME, place.fullName)
						put(PLACE_COUNTRY, place.country)
					}
					put(ENTITIES, msgpack.write(new TweetEntities(baseTweet)))
					put(USER_ID, tweet.user.id)
					put(USER_SCREEN_NAME, tweet.user.screenName)
					put(USER_NAME, tweet.user.name)
					put(USER_PROFILE_IMAGE, tweet.user.profileImageUrlHttps.toString())
					put(USER_PROTECTED, tweet.user.protected)
					put(USER_VERIFIED, tweet.user.verified)
					if (tweet.retweet) {
						put(RETWEETED_USER_ID, tweet.retweetedStatus.user.id)
						put(RETWEETED_USER_SCREEN_NAME, tweet.retweetedStatus.user.screenName)
						put(RETWEETED_USER_NAME, tweet.retweetedStatus.user.name)
						put(RETWEETED_USER_PROFILE_IMAGE, tweet.retweetedStatus.user.profileImageUrlHttps.toString())
						put(RETWEETED_USER_VERIFIED, tweet.retweetedStatus.user.verified)
					}
				])
			]
			db.setTransactionSuccessful()
		} finally {
			db.endTransaction()
		}
		handler.post[|
			loaderManager.restartLoader(CACHED_TWEETS_LOADER_ID, null, this)
			completedReload()
		]
	}
		
	override onCreateLoader(int id, Bundle args) {
		new CachedTweetsLoader(activity, tab.id)
	}
	
	override onLoadFinished(Loader<Cursor> loader, Cursor data) {
		adapter.swapCursor(data)
	}
	
	override onLoaderReset(Loader<Cursor> loader) {
		adapter.swapCursor(null)
	}
}

class CachedTweetsLoader extends AsyncTaskLoader<Cursor> {
	new(Context context, long tabId) {
		super(context)
		this.tabId = tabId
	}
	
	val long tabId
	Cursor cache
	
	override loadInBackground() {
		try {
			val db = CachedTweetsSQLite.instance.readableDatabase
			db.query("tab_" + tabId, null, null, null, null, null, "created_at desc, _id desc")
				=> [count]
		} catch (SQLException e) {
			e.printStackTrace()
			null
		}
	}
	
	override deliverResult(Cursor data) {
		if (!isReset()) {
			cache = data
			super.deliverResult(data)
		}
	}
	
	override protected onStartLoading() {
		if (cache != null)
			deliverResult(cache)
		else
			forceLoad()
	}
	
	override protected onStopLoading() {
		cancelLoad()
	}
	
	override protected onReset() {
		super.onReset()
		onStopLoading()
		if (cache != null) {
			cache.close()
			cache = null
		}
	}
	
}
