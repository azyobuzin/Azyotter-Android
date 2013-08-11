package net.azyobuzi.azyotter.timelines

import net.azyobuzi.azyotter.timelines.TimelineFragment
import net.azyobuzi.azyotter.configuration.Tab
import android.os.Bundle
import java.util.TreeSet
import twitter4j.Status
import net.azyobuzi.azyotter.configuration.Tabs
import net.azyobuzi.azyotter.configuration.Accounts
import net.azyobuzi.azyotter.TwitterClient
import twitter4j.Paging
import java.util.ArrayList
import android.os.Handler

class HomeTimelineFragment extends TimelineFragment {
	static def createInstance(Tab tab){
		val instance = new HomeTimelineFragment()
		instance.tab = tab
		instance
	}
	
	var Tab tab
	var TweetAdapter adapter
	var Handler handler
	
	override onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState)
		
		adapter = new TweetAdapter(activity)
		handler = new Handler()
		
		if (savedInstanceState != null){
			if (savedInstanceState.containsKey("tab_id")){
				tab = Tabs.list.filter[it.id == savedInstanceState.getLong("tab_id")].head
			}
			
			if (savedInstanceState.containsKey("tweets")){
				adapter.tweetsSet  = savedInstanceState.getSerializable("tweets") as TreeSet<Status>
			}
		}
		
		setListAdapter(adapter)
	}
	
	override onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState)
		
		outState.putLong("tab_id", tab.id)
		outState.putSerializable("tweets", adapter.tweetsSet)
	}
	
	var loadedAccounts = 0
	
	override reload() {
		val accounts = (if (tab.allUsers) Accounts.list else Accounts.list.filter[tab.users.contains(it.id)]).toList()
		loadedAccounts = 0
		val newTweets = new ArrayList<Status>()
		accounts.forEach[new TwitterClient(it).getHomeTimeline(new Paging(1, 50), [
			newTweets.addAll(it)
			loadedAccounts = loadedAccounts + 1
			if (loadedAccounts == accounts.size()){
				completeReload(newTweets)
			}
		], [te, method |
			loadedAccounts = loadedAccounts + 1
			if (loadedAccounts == accounts.size()){
				completeReload(newTweets)
			}
		])]
	}
	
	private def completeReload(Iterable<Status> newTweets){
		adapter.tweetsSet.clear()
		adapter.tweetsSet.addAll(newTweets)
		handler.post([|
			adapter.notifyDataSetChanged()
			completedReload()
		])
	}
	
}