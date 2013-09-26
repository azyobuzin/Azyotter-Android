package net.azyobuzi.azyotter.timelines

import net.azyobuzi.azyotter.configuration.Tab
import net.azyobuzi.azyotter.configuration.Accounts
import java.util.ArrayList
import twitter4j.Status
import net.azyobuzi.azyotter.TwitterClient
import twitter4j.Paging
import net.azyobuzi.azyotter.FavoriteMarker

class MentionsTimelineFragment extends TimelineFragment {
	static def createInstance(Tab tab){
		val instance = new MentionsTimelineFragment()
		instance.tab = tab
		instance
	}
	
	var loadedAccounts = 0
	
	override reload() {
		val accounts = (if (tab.allUsers) Accounts.list else Accounts.list.filter[tab.users.contains(it.id)]).toList()
		loadedAccounts = 0
		val newTweets = new ArrayList<Status>()
		accounts.forEach[account | new TwitterClient(account).getMentions(new Paging(1, 50), [
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