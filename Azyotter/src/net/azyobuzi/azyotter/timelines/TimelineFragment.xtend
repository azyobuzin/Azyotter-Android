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
import android.view.GestureDetector
import android.widget.ListView
import android.support.v4.view.GestureDetectorCompat
import android.view.MotionEvent
import android.widget.AdapterView
import net.azyobuzi.azyotter.configuration.ActionType
import net.azyobuzi.azyotter.configuration.Setting
import net.azyobuzi.azyotter.activities.AnonymousDialogFragment
import android.app.AlertDialog
import java.util.ArrayList
import net.azyobuzi.azyotter.TwitterClient
import net.azyobuzi.azyotter.configuration.Accounts
import android.widget.Toast
import net.azyobuzi.azyotter.FavoriteMarker
import net.azyobuzi.azyotter.database.TweetItem
import android.content.Intent
import net.azyobuzi.azyotter.activities.UpdateStatusActivity

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
		
		val gestureListener = new TimelineGestureListener(this)
		val gestureDetector = new GestureDetectorCompat(activity, gestureListener)
			=> [onDoubleTapListener = gestureListener]
		listView.onTouchListener = [v, event |
			gestureDetector.onTouchEvent(event)
			false
		]
		
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
	
	def void doAction(TweetItem tweet, ActionType action) {
		val isRetweet = tweet.retweetedId != null
		val baseId = if (isRetweet) tweet.retweetedId else tweet.id
		val baseScreenName = if (isRetweet) tweet.retweetedUserScreenName else tweet.userScreenName
		val account = Accounts.activeAccount
		
		switch action {
			case ActionType.OPEN_MENU: {
				val actions = new ArrayList<ActionItem>() => [
					add(new ActionItem(getText(R.string.reply), [| doAction(tweet, ActionType.REPLY)]))
					add(new ActionItem(getText(
						if (FavoriteMarker.isFavorited(Accounts.activeAccount, baseId)) R.string.remove_from_favorite
						else R.string.add_to_favorite
					), [| doAction(tweet, ActionType.FAVORITE)]))
					add(new ActionItem(getText(R.string.retweet), [| doAction(tweet, ActionType.RETWEET)]))
				]
				new AnonymousDialogFragment([f, b |
					new AlertDialog.Builder(f.activity)
						.setTitle("@" + baseScreenName + ": " + tweet.displayText)
						.setItems(actions.map[it.name].toArray(#[]), [d, which |
							actions.get(which).action.run()
						])
						.create()
				], null).show(fragmentManager, "tweetMenu")
			}
			case ActionType.REPLY: {
				startActivity(new Intent(activity, UpdateStatusActivity)
					.putExtra("internal", true)
					.putExtra("in_reply_to_status_id", baseId)
					.putExtra("in_reply_to_screen_name", baseScreenName)
					.putExtra(Intent.EXTRA_TEXT, "@" + baseScreenName + " ")
				)
			}
			case ActionType.FAVORITE: {
				val client = new TwitterClient(account)
				if (FavoriteMarker.isFavorited(Accounts.activeAccount, baseId))
					client.destroyFavorite(baseId, [
						FavoriteMarker.unmark(account, baseId)
						FavoriteMarker.save()
						handler.post([| adapter.notifyDataSetChanged()])
					], [te, method |
						handler.post([|
							Toast.makeText(activity,
								getText(R.string.unfavorite_failed) + ":\n" + te.message,
								Toast.LENGTH_SHORT
							).show()
						])
					])
				else client.createFavorite(baseId, [
						FavoriteMarker.mark(account, baseId)
						FavoriteMarker.save()
						handler.post([| adapter.notifyDataSetChanged()])
					], [te, method |
						handler.post([|
							Toast.makeText(activity,
								getText(R.string.favorite_failed) + ":\n" + te.message,
								Toast.LENGTH_SHORT
							).show()
						])
					])
			}
			case ActionType.RETWEET: {
				new TwitterClient(account).retweetStatus(baseId, [], [te, method |
					handler.post([|
						Toast.makeText(activity,
							getText(R.string.retweet_failed) + ":\n" + te.message,
							Toast.LENGTH_SHORT
						).show()
					])
				])
			}
		}
	}
}

@Data
class ActionItem {
	CharSequence name
	Runnable action
}

class CachedTweetsLoader extends AsyncTaskLoader<Cursor> {
	new(Context context, long tabId) {
		super(context)
		this.tabId = tabId
	}
	
	val long tabId
	
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
}

class TimelineGestureListener extends GestureDetector.SimpleOnGestureListener {
	new(TimelineFragment fragment) {
		this.fragment = fragment
		this.listView = fragment.listView
	}
	
	val TimelineFragment fragment
	val ListView listView
	
	private def getTweetFromEvent(MotionEvent e) {
		val pos = listView.pointToPosition(e.x as int, e.y as int)
		if (pos == AdapterView.INVALID_POSITION) null
		else TweetItem.fromCursor(listView.getItemAtPosition(pos) as Cursor)
	}
	
	override onSingleTapConfirmed(MotionEvent e) {
		val tweet = getTweetFromEvent(e)
		if (tweet != null) {
			fragment.doAction(tweet, Setting.singleTapAction)
			true
		} else false
	}
	
	override onDoubleTap(MotionEvent e) {
		val tweet = getTweetFromEvent(e)
		if (tweet != null) {
			fragment.doAction(tweet, Setting.doubleTapAction)
			true
		} else false
	}
	
}