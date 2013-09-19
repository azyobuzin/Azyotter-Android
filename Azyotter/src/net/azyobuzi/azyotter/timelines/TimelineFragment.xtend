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
import android.support.v4.app.ListFragment
import android.os.Handler
import net.azyobuzi.azyotter.configuration.Tab
import android.view.LayoutInflater
import android.view.ViewGroup
import net.azyobuzi.azyotter.R
import net.azyobuzi.azyotter.configuration.Tabs

abstract class TimelineFragment extends ListFragment implements LoaderManager.LoaderCallbacks<Cursor> {
	protected var Handler handler
	protected var Tab tab
	protected var TweetAdapter adapter
	static val CACHED_TWEETS_LOADER_ID = 0
	
	override onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		inflater.inflate(R.layout.timeline, container, false)
	}
	
	override onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState)
		
		handler = new Handler()
		
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
		val db = new CachedTweetsSQLite().createTableIfNotExists(table)
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
			
			tweetsList.forEach[tweet |
				db.replace(table, null, new ContentValues() => [
					put("_id", tweet.id)
					if (tweet.retweet) put("retweeted_id", tweet.retweetedStatus.id)
					put("in_reply_to_user_id", if (tweet.retweet) tweet.retweetedStatus.inReplyToUserId else tweet.inReplyToUserId)
					put("in_reply_to_screen_name", if (tweet.retweet) tweet.retweetedStatus.inReplyToScreenName else tweet.inReplyToScreenName)
					put("in_reply_to_status_id", if (tweet.retweet) tweet.retweetedStatus.inReplyToStatusId else tweet.inReplyToStatusId)
					put("created_at", tweet.createdAt.time)
					if (tweet.retweet) put("retweeted_created_at", tweet.retweetedStatus.createdAt.time)
					put("text", tweet.text)
					if (tweet.retweet) put("retweeted_text", tweet.retweetedStatus.text)
					put("display_text", TweetParser.createDisplayText(tweet))
					put("source_name", TweetParser.getSourceName(tweet))
					put("source_uri", TweetParser.getSourceUri(tweet))
					if (tweet.retweet) {
						put("retweeted_source_name", TweetParser.getSourceName(tweet.retweetedStatus))
						put("retweeted_source_uri", TweetParser.getSourceUri(tweet.retweetedStatus))
					}
					put("favorite_count", if (tweet.retweet) tweet.retweetedStatus.favoriteCount else tweet.favoriteCount)
					put("retweet_count", if(tweet.retweet) tweet.retweetedStatus.retweetCount else tweet.retweetCount)
					val geo = if (tweet.retweet) tweet.retweetedStatus.geoLocation else tweet.geoLocation
					if (geo != null) {
						put("latitude", geo.latitude)
						put("longitude", geo.longitude)
					}
					val place = if (tweet.retweet) tweet.retweetedStatus.place else tweet.place
					if (place != null) {
						put("place_id", place.id)
						put("place_name", place.name)
						put("place_full_name", place.fullName)
						put("place_country", place.country)
					}
					put("user_id", tweet.user.id)
					put("user_screen_name", tweet.user.screenName)
					put("user_name", tweet.user.name)
					put("user_profile_image", tweet.user.profileImageUrlHttps.toString())
					put("user_protected", tweet.user.protected)
					put("user_verified", tweet.user.verified)
					if (tweet.retweet) {
						put("retweeted_user_id", tweet.retweetedStatus.user.id)
						put("retweeted_user_screen_name", tweet.retweetedStatus.user.screenName)
						put("retweeted_user_name", tweet.retweetedStatus.user.name)
						put("retweeted_user_profile_image", tweet.retweetedStatus.user.profileImageUrlHttps.toString())
						put("retweeted_user_verified", tweet.retweetedStatus.user.verified)
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
		new CachedTweetsLoader(activity, tab.id) => [forceLoad()]
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
	
	override loadInBackground() {
		try {
			val db = new CachedTweetsSQLite().readableDatabase
			db.query("tab_" + tabId, null, null, null, null, null, "created_at desc, _id desc")
				=> [count]
		} catch (SQLException e) {
			e.printStackTrace()
			null
		}
	}
}