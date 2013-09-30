package net.azyobuzi.azyotter.timelines

import net.azyobuzi.azyotter.configuration.Tab
import twitter4j.Status
import net.azyobuzi.azyotter.configuration.Accounts
import net.azyobuzi.azyotter.TwitterClient
import twitter4j.Paging
import java.util.ArrayList
import net.azyobuzi.azyotter.FavoriteMarker

class HomeTabFragment extends TabFragment {
	static def createInstance(Tab tab){
		val instance = new HomeTabFragment()
		instance.tab = tab
		instance
	}
	
	var loadedAccounts = 0
	
	override reload() {
		val accounts = (if (tab.allUsers) Accounts.list else Accounts.list.filter[tab.users.contains(it.id)]).toList()
		loadedAccounts = 0
		val newTweets = new ArrayList<Status>()
		accounts.forEach[account | new TwitterClient(account).getHomeTimeline(new Paging(1, 50), [
			it.forEach[
				newTweets.add(it)
				val tweet = if (it.retweet) it.retweetedStatus else it
				if (tweet.favorited) FavoriteMarker.mark(account, tweet.id)
				else FavoriteMarker.unmark(account, tweet.id)
			]
			loadedAccounts = loadedAccounts + 1
			if (loadedAccounts == accounts.size()){
				FavoriteMarker.save()
				completeReload(newTweets)
			}
		], [te, method |
			loadedAccounts = loadedAccounts + 1
			if (loadedAccounts == accounts.size()){
				FavoriteMarker.save()
				completeReload(newTweets)
			}
		])]
	}
}