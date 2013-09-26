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
import java.util.Date
import java.text.DateFormat
import android.widget.ImageView
import net.azyobuzi.azyotter.FavoriteMarker
import net.azyobuzi.azyotter.configuration.Accounts

class TweetAdapter extends CursorAdapter {
	new(Activity activity) {
		super(activity, null, false)
		inflater = activity.layoutInflater
	}
	
	val LayoutInflater inflater
	static val dateFormatter = DateFormat.instance
	
	override bindView(View view, Context context, Cursor cursor) {
		val viewHolder = view.tag as TweetViewHolder
		val isRetweet = !cursor.isNull(1)
		viewHolder.profileImage.imageBitmap = null
		viewHolder.profileImage.imageUrl = cursor.getString(if (isRetweet) 31 else 25)
		viewHolder.favorited.visibility =
			if (FavoriteMarker.isFavorited(Accounts.activeAccount, cursor.getLong(if (isRetweet) 1 else 0))) View.VISIBLE
			else View.GONE
		viewHolder.name.text = cursor.getString(if (isRetweet) 29 else 23)
			+ " / " + cursor.getString(if (isRetweet) 30 else 24)
		viewHolder.text.text = cursor.getString(9)
		val createdAt = new Date(cursor.getLong(if (isRetweet) 6 else 5))
		viewHolder.dateAndSource.text = dateFormatter.format(createdAt)
			+ " / via " + cursor.getString(if (isRetweet) 12 else 10)
		if (isRetweet) {
			viewHolder.retweetedBy.visibility = View.VISIBLE
			viewHolder.retweetedBy.text = "RT by " + cursor.getString(23)
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