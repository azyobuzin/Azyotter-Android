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

class TweetAdapter extends BaseAdapter {
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
		val viewHolder = (view.tag as TweetViewHolder) ?: new TweetViewHolder() => [
			profileImage = view.findViewById(R.id.profile_image) as UrlImageView
			name = view.findViewById(R.id.name) as TextView
			text = view.findViewById(R.id.text) as TextView
			dateAndSource = view.findViewById(R.id.date_source) as TextView
		]
		view.tag = viewHolder
		
		viewHolder.profileImage.setImageUrl(
			if (tweet.model.retweet) tweet.model.retweetedStatus.user.profileImageURLHttps
			else tweet.model.user.profileImageURLHttps
		)
		viewHolder.name.text = (if (tweet.model.retweet) tweet.model.retweetedStatus.user.screenName else tweet.model.user.screenName)
			+ " / " + if (tweet.model.retweet) tweet.model.retweetedStatus.user.name else tweet.model.user.name
		viewHolder.text.text = tweet.displayText
		viewHolder.dateAndSource.text = (if (tweet.model.retweet) tweet.retweetedCreatedAt else tweet.createdAt)
			+ " / via " + if (tweet.model.retweet) tweet.retweetedSourceName else tweet.sourceName
		//TODO:Retweeted by
		
		view
	}
	
}

class TweetComparator implements Comparator<TweetViewModel>, Serializable {
	override compare(TweetViewModel lhs, TweetViewModel rhs) {
		val x = lhs.model.createdAt.compareTo(rhs.model.createdAt)
		if (x != 0) - x else - lhs.model.compareTo(rhs.model)
	}
}

class TweetViewHolder{
	@Property UrlImageView profileImage
	@Property TextView name
	@Property TextView text
	@Property TextView dateAndSource
}