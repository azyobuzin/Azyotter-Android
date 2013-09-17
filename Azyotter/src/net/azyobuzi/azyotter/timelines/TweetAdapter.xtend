package net.azyobuzi.azyotter.timelines

import android.widget.BaseAdapter
import android.view.View
import android.view.ViewGroup
import java.util.TreeSet
import java.util.Comparator
import android.widget.TextView
import android.app.Activity
import net.azyobuzi.azyotter.R
import android.widget.LinearLayout
import java.io.Serializable
import jp.sharakova.android.urlimageview.UrlImageView
import android.support.v4.widget.CursorAdapter
import android.content.Context
import android.database.Cursor
import android.view.LayoutInflater
import java.util.Date
import java.text.DateFormat

/*class TweetAdapter extends BaseAdapter {
	new(Activity activity){
		this.activity = activity
	}
	
	val Activity activity
	
	@Property TreeSet<TweetViewModel> tweetsSet = new TreeSet<TweetViewModel>(new TweetComparator())
	
	override getCount() {
		tweetsSet.size()
	}
	
	override getItem(int position) {
		tweetsSet.toArray().get(position)
	}
	
	override getItemId(int position) {
		position
	}
	
	override getView(int position, View convertView, ViewGroup parent) {
		val tweet = getItem(position) as TweetViewModel
		val view = (convertView ?: activity.layoutInflater.inflate(R.layout.tweet, parent, false)) as LinearLayout
		val viewHolder = (view.tag as TweetViewHolder) ?: new TweetViewHolder(
			view.findViewById(R.id.profile_image) as UrlImageView,
			view.findViewById(R.id.name) as TextView,
			view.findViewById(R.id.text) as TextView,
			view.findViewById(R.id.date_source) as TextView,
			view.findViewById(R.id.retweeted_by) as TextView
		)
		view.tag = viewHolder
		
		viewHolder.profileImage.imageBitmap = null
		viewHolder.profileImage.imageUrl =
			if (tweet.model.retweet) tweet.model.retweetedStatus.user.profileImageURLHttps
			else tweet.model.user.profileImageURLHttps
		viewHolder.name.text = (if (tweet.model.retweet) tweet.model.retweetedStatus.user.screenName else tweet.model.user.screenName)
			+ " / " + if (tweet.model.retweet) tweet.model.retweetedStatus.user.name else tweet.model.user.name
		viewHolder.text.text = tweet.displayText
		viewHolder.dateAndSource.text = (if (tweet.model.retweet) tweet.retweetedCreatedAt else tweet.createdAt)
			+ " / via " + if (tweet.model.retweet) tweet.retweetedSourceName else tweet.sourceName
		if (tweet.model.retweet){
			viewHolder.retweetedBy.visibility = View.VISIBLE
			viewHolder.retweetedBy.text = "RT by " + tweet.model.user.screenName
		}
		else viewHolder.retweetedBy.visibility = View.GONE
		
		view
	}
	
}

class TweetComparator implements Comparator<TweetViewModel>, Serializable {
	override compare(TweetViewModel lhs, TweetViewModel rhs) {
		val x = lhs.model.createdAt.compareTo(rhs.model.createdAt)
		if (x != 0) - x else - lhs.model.compareTo(rhs.model)
	}
}*/

class TweetAdapter extends CursorAdapter {
	new(Activity activity) {
		super(activity, null, false)
		inflater = activity.layoutInflater
	}
	
	val LayoutInflater inflater
	
	override bindView(View view, Context context, Cursor cursor) {
		val viewHolder = view.tag as TweetViewHolder
		val isRetweet = !cursor.isNull(1)
		viewHolder.profileImage.imageBitmap = null
		viewHolder.profileImage.imageUrl = cursor.getString(if (isRetweet) 31 else 25)
		viewHolder.name.text = cursor.getString(if (isRetweet) 29 else 23)
			+ " / " + cursor.getString(if (isRetweet) 30 else 24)
		viewHolder.text.text = cursor.getString(9)
		val createdAt = new Date(cursor.getLong(if (isRetweet) 6 else 5))
		viewHolder.dateAndSource.text = DateFormat.instance.format(createdAt)
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
	TextView name
	TextView text
	TextView dateAndSource
	TextView retweetedBy
}