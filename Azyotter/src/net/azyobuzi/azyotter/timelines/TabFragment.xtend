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
import static net.azyobuzi.azyotter.database.TweetItem.*
import org.msgpack.MessagePack
import net.azyobuzi.azyotter.database.TweetEntities
import android.net.Uri

abstract class TabFragment extends ListFragment implements LoaderManager.LoaderCallbacks<Cursor> {
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
					addAll(tweet.entities.urls.map[new ActionItem(it.expandedUrl, [|
						startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(it.url)))
					])])
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
	new(TabFragment fragment) {
		this.fragment = fragment
		this.listView = fragment.listView
	}
	
	val TabFragment fragment
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