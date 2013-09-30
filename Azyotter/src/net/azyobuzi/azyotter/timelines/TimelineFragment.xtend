package net.azyobuzi.azyotter.timelines

import android.support.v4.app.ListFragment
import android.os.Handler
import android.view.LayoutInflater
import android.view.ViewGroup
import android.os.Bundle
import net.azyobuzi.azyotter.R
import android.view.GestureDetector
import android.widget.ListView
import android.view.MotionEvent
import android.widget.AdapterView
import net.azyobuzi.azyotter.database.TweetItem
import android.database.Cursor
import net.azyobuzi.azyotter.configuration.Setting
import net.azyobuzi.azyotter.configuration.ActionType
import net.azyobuzi.azyotter.configuration.Accounts
import java.util.ArrayList
import net.azyobuzi.azyotter.FavoriteMarker
import android.content.Intent
import net.azyobuzi.azyotter.activities.AnonymousDialogFragment
import android.app.AlertDialog
import android.net.Uri
import net.azyobuzi.azyotter.activities.UpdateStatusActivity
import net.azyobuzi.azyotter.TwitterClient
import android.widget.Toast
import android.widget.BaseAdapter
import android.support.v4.view.GestureDetectorCompat

abstract class TimelineFragment extends ListFragment {
	protected var Handler handler
		
	override onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		inflater.inflate(R.layout.timeline, container, false)
	}
	
	override onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState)
		
		handler = new Handler()
		
		val gestureListener = new TimelineGestureListener(this)
		val gestureDetector = new GestureDetectorCompat(activity, gestureListener)
			=> [onDoubleTapListener = gestureListener]
		listView.onTouchListener = [v, event |
			gestureDetector.onTouchEvent(event)
			false
		]
	}
	
	override onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState)
		
		val first = listView.getChildAt(0)
		if (first != null) {
			outState.putInt("scrollPos", listView.firstVisiblePosition)
			outState.putInt("scrollTop", first.top)
		}
	}
	
	def restoreScrollPosition(Bundle bundle) {
		val pos = bundle.getInt("scrollPos", -1)
		val top = bundle.getInt("scrollTop", -1)
		if (pos != -1 && top != -1) {
			listView.setSelectionFromTop(pos, top)
		}
	}
	
	protected def notifyAdapterDataSetChanged() {
		if (listAdapter instanceof BaseAdapter)
			(listAdapter as BaseAdapter).notifyDataSetChanged()
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
						handler.post([| notifyAdapterDataSetChanged()])
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
						handler.post([| notifyAdapterDataSetChanged()])
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