package net.azyobuzi.azyotter.timelines

import android.os.Bundle
import java.util.TreeSet
import twitter4j.Status

abstract class TweetTimelineFragment extends TimelineFragment {
	protected var TweetAdapter adapter
	
	override onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState)
		
		adapter = new TweetAdapter(activity)
		
		if (savedInstanceState != null){
			if (savedInstanceState.containsKey("tweets")){
				adapter.tweetsSet  = savedInstanceState.getSerializable("tweets") as TreeSet<TweetViewModel>
			}
		}
		
		setListAdapter(adapter)
	}
	
	override onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState)
		outState.putSerializable("tweets", adapter.tweetsSet)
	}
	
	protected def completeReload(Iterable<Status> newTweets){
		adapter.tweetsSet.clear()
		adapter.tweetsSet.addAll(newTweets.map[new TweetViewModel(it)])
		handler.post([|
			adapter.notifyDataSetChanged()
			completedReload()
		])
	}
}