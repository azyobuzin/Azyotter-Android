package net.azyobuzi.azyotter.timelines

import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import android.app.Activity
import net.azyobuzi.azyotter.R
import jp.sharakova.android.urlimageview.UrlImageView
import android.support.v4.widget.CursorAdapter
import android.content.Context
import android.database.Cursor
import android.view.LayoutInflater
import java.text.DateFormat
import android.widget.ImageView
import net.azyobuzi.azyotter.FavoriteMarker
import net.azyobuzi.azyotter.configuration.Accounts
import net.azyobuzi.azyotter.database.TwitterStatus

class TweetAdapter extends CursorAdapter {
	new(Activity activity) {
		super(activity, null, false)
		inflater = activity.layoutInflater
	}
	
	val LayoutInflater inflater
	static val dateFormatter = DateFormat.instance
	
	override bindView(View view, Context context, Cursor cursor) {
		val tweet = TwitterStatus.fromCursor(cursor)
		val viewHolder = view.tag as TweetViewHolder
		val isRetweet = tweet.retweetedId != null
		viewHolder.profileImage.imageBitmap = null
		viewHolder.profileImage.imageUrl = if (isRetweet) tweet.retweetedUserProfileImage else tweet.userProfileImage
		viewHolder.favorited.visibility =
			if (FavoriteMarker.isFavorited(Accounts.activeAccount, if (isRetweet) tweet.retweetedId else tweet.id)) View.VISIBLE
			else View.GONE
		viewHolder.name.text = (if (isRetweet) tweet.retweetedUserScreenName else tweet.userScreenName)
			+ " / " + if (isRetweet) tweet.retweetedUserName else tweet.userName
		viewHolder.text.text = tweet.displayText
		viewHolder.dateAndSource.text = dateFormatter.format(if (isRetweet) tweet.retweetedCreatedAt else tweet.createdAt)
			+ " / via " + if (isRetweet) tweet.retweetedSourceName else tweet.sourceName
		if (isRetweet) {
			viewHolder.retweetedBy.visibility = View.VISIBLE
			viewHolder.retweetedBy.text = "RT by " + tweet.userScreenName
		} else {
			viewHolder.retweetedBy.visibility = View.GONE
		}
	}
	
	override newView(Context context, Cursor cursor, ViewGroup parent) {
		val view = inflater.inflate(R.layout.tweet, parent, false)
		view.setTag(new TweetViewHolder(
			view.findViewById(R.id.profile_image) as UrlImageView,
			view.findViewById(R.id.favorited) as ImageView,
			view.findViewById(R.id.name) as TextView,
			view.findViewById(R.id.text) as TextView,
			view.findViewById(R.id.date_source) as TextView,
			view.findViewById(R.id.retweeted_by) as TextView
		))
		view
	}
	
}

@Data
class TweetViewHolder{
	UrlImageView profileImage
	ImageView favorited
	TextView name
	TextView text
	TextView dateAndSource
	TextView retweetedBy
}