package net.azyobuzi.azyotter.timelines

import android.widget.BaseAdapter
import android.view.View
import android.view.ViewGroup
import twitter4j.Status
import java.util.TreeSet
import java.util.Comparator
import net.azyobuzi.azyotter.ProfileImageView
import android.widget.TextView
import android.app.Activity
import net.azyobuzi.azyotter.R
import android.widget.LinearLayout
import java.text.DateFormat
import java.io.Serializable

class TweetAdapter extends BaseAdapter {
	new(Activity activity){
		this.activity = activity
	}
	
	val Activity activity
	
	@Property TreeSet<Status> tweetsSet = new TreeSet<Status>(new TweetComparator())
	
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
		val tweet = getItem(position) as Status
		val view = (convertView ?: activity.layoutInflater.inflate(R.layout.tweet, parent, false)) as LinearLayout
		val viewHolder = (view.tag as TweetViewHolder) ?: new TweetViewHolder() => [
			profileImage = view.findViewById(R.id.profile_image) as ProfileImageView
			name = view.findViewById(R.id.name) as TextView
			text = view.findViewById(R.id.text) as TextView
			dateAndSource = view.findViewById(R.id.date_source) as TextView
		]
		view.tag = viewHolder
		
		//TODO:ProfileImage
		viewHolder.name.text = tweet.user.screenName + " / " + tweet.user.name
		viewHolder.text.text = tweet.text //TODO:Entities の処理
		viewHolder.dateAndSource.text =
			DateFormat.getDateTimeInstance().format(tweet.createdAt) + " / via " + tweet.source //TODO:source の処理
		
		view
	}
	
}

class TweetComparator implements Comparator<Status>, Serializable {
	override compare(Status lhs, Status rhs) {
		val x = lhs.createdAt.compareTo(rhs.createdAt)
		if (x != 0) - x else - lhs.compareTo(rhs)
	}
}

class TweetViewHolder{
	@Property ProfileImageView profileImage
	@Property TextView name
	@Property TextView text
	@Property TextView dateAndSource
}