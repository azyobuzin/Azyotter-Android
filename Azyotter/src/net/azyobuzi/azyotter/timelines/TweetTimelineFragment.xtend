package net.azyobuzi.azyotter.timelines

import android.os.Bundle
import java.util.TreeSet
import twitter4j.Status
import android.support.v4.app.LoaderManager
import android.database.Cursor
import android.support.v4.content.Loader
import android.support.v4.content.CursorLoader
import android.net.Uri
import net.azyobuzi.azyotter.providers.CachedTweetsProvider
import com.google.common.base.Joiner
import android.content.ContentValues
import java.io.ObjectOutputStream.PutField
import net.azyobuzi.azyotter.TweetParser
import android.support.v4.content.AsyncTaskLoader
import android.content.Context
import java.util.ArrayList
import net.azyobuzi.azyotter.database.CachedTweetsSQLite
import android.database.SQLException
import twitter4j.internal.async.Dispatcher

abstract class TweetTimelineFragment extends TimelineFragment implements LoaderManager.LoaderCallbacks<Cursor> {
	protected var TweetAdapter adapter
	val CURSOR_LOADER_ID = 0
	
	override onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState)
		
		adapter = new TweetAdapter(activity)
		
		/*if (savedInstanceState != null){
			if (savedInstanceState.containsKey("tweets")){
				adapter.tweetsSet  = savedInstanceState.getSerializable("tweets") as TreeSet<TweetViewModel>
			}
		}*/
		
		setListAdapter(adapter)
		loaderManager.initLoader(CURSOR_LOADER_ID, null, this)
	}
	
	override onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState)
		//outState.putSerializable("tweets", adapter.tweetsSet)
	}
	
	override onDestroyView() {
		super.onDestroyView()
		loaderManager.destroyLoader(CURSOR_LOADER_ID)
	}
	
	protected def completeReload(Iterable<Status> newTweets){
		/*adapter.tweetsSet.clear()
		adapter.tweetsSet.addAll(newTweets.map[new TweetViewModel(it)])
		handler.post([|
			adapter.notifyDataSetChanged()
			completedReload()
		])*/
		val tweetsList = newTweets.toList()
		val providerUri = CachedTweetsProvider.createUri(tab.id)
		val contentResolver = activity.contentResolver
		/*val cursor = contentResolver.query(
			providerUri,
			#["_id"],
			tweetsList.map["_id = ?"].join(" OR "),
			tweetsList.map[String.valueOf(it.id)].toArray(#[]),
			null
		)*/
		/*val exists = tweetsList.exists[
			val cursor = contentResolver.query(CachedTweetsProvider.createUri(tab.id, it.id), #["_id"], null, null, null)
			if (cursor == null) false
			else cursor.moveToFirst()
		]
		if (!exists) {
			contentResolver.delete(providerUri, null, null)
		}*/
		tweetsList.forEach[tweet |
			contentResolver.insert(providerUri, new ContentValues() => [
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
		handler.post[|
			loaderManager.restartLoader(CURSOR_LOADER_ID, null, this)
			completedReload()
		]
	}
		
	override onCreateLoader(int id, Bundle args) {
		new CursorLoader(activity,
			CachedTweetsProvider.createUri(tab.id),
			null, null, null, "created_at desc, _id desc"
		)
	}
	
	override onLoadFinished(Loader<Cursor> loader, Cursor data) {
		adapter.swapCursor(data)
	}
	
	override onLoaderReset(Loader<Cursor> loader) {
		adapter.swapCursor(null)
	}
	
}

/*class CachedTweetsLoader extends AsyncTaskLoader<ArrayList<TweetViewModel>> {
	new(Context context) {
		super(context)
	}
	
	override loadInBackground() {
		
	}
}*/