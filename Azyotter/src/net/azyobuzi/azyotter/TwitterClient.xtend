package net.azyobuzi.azyotter

import twitter4j.AsyncTwitterFactory
import net.azyobuzi.azyotter.configuration.Account
import twitter4j.TwitterListener
import twitter4j.User
import twitter4j.Status
import twitter4j.Place
import twitter4j.SavedSearch
import twitter4j.UserList
import twitter4j.DirectMessage
import twitter4j.TwitterAPIConfiguration
import twitter4j.AccountSettings
import twitter4j.ResponseList
import twitter4j.Location
import twitter4j.IDs
import twitter4j.PagableResponseList
import twitter4j.api.HelpResources.Language
import twitter4j.auth.AccessToken
import twitter4j.auth.RequestToken
import twitter4j.OEmbed
import twitter4j.Trends
import java.util.Map
import twitter4j.RateLimitStatus
import twitter4j.Relationship
import twitter4j.SimilarPlaces
import twitter4j.Category
import twitter4j.Friendship
import twitter4j.TwitterException
import twitter4j.TwitterMethod
import twitter4j.QueryResult
import twitter4j.Paging
import twitter4j.StatusUpdate

class TwitterClient {
	static val factory = new AsyncTwitterFactory()
	
	new(Account account){
		this.account = account
	}
	
	Account account
	
	private def getTwitterInstance(){
		factory.getInstance(account.toAccessToken())
	}
	
	def getHomeTimeline(Paging paging, TwitterCallback<ResponseList<Status>> callback, TwitterExceptionListener onException){
		val twitter = twitterInstance
		twitter.addListener(new AnonymousTwitterListener() => [
			onGotHomeTimeline = callback
			onExceptionListener = onException
		])
		twitter.getHomeTimeline(paging)
	}
	
	def getMentions(Paging paging, TwitterCallback<ResponseList<Status>> callback, TwitterExceptionListener onException){
		val twitter = twitterInstance
		twitter.addListener(new AnonymousTwitterListener() => [
			onGotMentions = callback
			onExceptionListener = onException
		])
		twitter.getMentions(paging)
	}
	
	def updateStatus(StatusUpdate statusUpdate, TwitterCallback<Status> callback, TwitterExceptionListener onException){
		var twitter = twitterInstance
		twitter.addListener(new AnonymousTwitterListener() => [
			onUpdatedStatus = callback
			onExceptionListener = onException
		])
		twitter.updateStatus(statusUpdate)
	}
	
	def createFavorite(long id, TwitterCallback<Status> callback, TwitterExceptionListener onException) {
		val twitter = twitterInstance
		twitter.addListener(new AnonymousTwitterListener() => [
			onCreatedFavorite = callback
			onExceptionListener = onException
		])
		twitter.createFavorite(id)
	}
	
	def destroyFavorite(long id, TwitterCallback<Status> callback, TwitterExceptionListener onException) {
		val twitter = twitterInstance
		twitter.addListener(new AnonymousTwitterListener() => [
			onDestroyedFavorite = callback
			onExceptionListener = onException
		])
		twitter.destroyFavorite(id)
	}
}

interface TwitterCallback<T>{
	def void callback(T response)
}

interface TwitterExceptionListener{
	def void onException(TwitterException te, TwitterMethod method)
}

class AnonymousTwitterListener implements TwitterListener{
	@Property TwitterCallback<User> onCheckedUserListMembership
	override checkedUserListMembership(User arg0) {
		onCheckedUserListMembership?.callback(arg0)
	}
	
	@Property TwitterCallback<User> onCheckedUserListSubscription
	override checkedUserListSubscription(User arg0) {
		onCheckedUserListSubscription?.callback(arg0)
	}
	
	@Property TwitterCallback<User> onCreatedBlock
	override createdBlock(User arg0) {
		onCreatedBlock?.callback(arg0)
	}
	
	@Property TwitterCallback<Status> onCreatedFavorite
	override createdFavorite(Status arg0) {
		onCreatedFavorite?.callback(arg0)
	}
	
	@Property TwitterCallback<User> onCreatedFriendship
	override createdFriendship(User arg0) {
		onCreatedFriendship?.callback(arg0)
	}
	
	@Property TwitterCallback<Place> onCreatedPlace
	override createdPlace(Place arg0) {
		onCreatedPlace?.callback(arg0)
	}
	
	@Property TwitterCallback<SavedSearch> onCreatedSavedSearch
	override createdSavedSearch(SavedSearch arg0) {
		onCreatedSavedSearch?.callback(arg0)
	}
	
	@Property TwitterCallback<UserList> onCreatedUserList
	override createdUserList(UserList arg0) {
		onCreatedUserList?.callback(arg0)
	}
	
	@Property TwitterCallback<UserList> onCreatedUserListMember
	override createdUserListMember(UserList arg0) {
		onCreatedUserListMember?.callback(arg0)
	}
	
	@Property TwitterCallback<UserList> onCreatedUserListMembers
	override createdUserListMembers(UserList arg0) {
		onCreatedUserListMembers?.callback(arg0)
	}
	
	@Property TwitterCallback<User> onDestroyedBlock
	override destroyedBlock(User arg0) {
		onDestroyedBlock?.callback(arg0)
	}
	
	@Property TwitterCallback<DirectMessage> onDestroyedDirectMessage
	override destroyedDirectMessage(DirectMessage arg0) {
		onDestroyedDirectMessage?.callback(arg0)
	}
	
	@Property TwitterCallback<Status> onDestroyedFavorite
	override destroyedFavorite(Status arg0) {
		onDestroyedFavorite?.callback(arg0)
	}
	
	@Property TwitterCallback<User> onDestroyedFriendship
	override destroyedFriendship(User arg0) {
		onDestroyedFriendship?.callback(arg0)
	}
	
	@Property TwitterCallback<SavedSearch> onDestroyedSavedSearch
	override destroyedSavedSearch(SavedSearch arg0) {
		onDestroyedSavedSearch?.callback(arg0)
	}
	
	@Property TwitterCallback<Status> onDestroyedStatus
	override destroyedStatus(Status arg0) {
		onDestroyedStatus?.callback(arg0)
	}
	
	@Property TwitterCallback<UserList> onDestroyedUserList
	override destroyedUserList(UserList arg0) {
		onDestroyedUserList?.callback(arg0)
	}
	
	@Property TwitterCallback<UserList> onDestroyedUserListMember
	override destroyedUserListMember(UserList arg0) {
		onDestroyedUserListMember?.callback(arg0)
	}
	
	@Property TwitterCallback<TwitterAPIConfiguration> onGotAPIConfiguration
	override gotAPIConfiguration(TwitterAPIConfiguration arg0) {
		onGotAPIConfiguration?.callback(arg0)
	}
	
	@Property TwitterCallback<AccountSettings> onGotAccountSettings
	override gotAccountSettings(AccountSettings arg0) {
		onGotAccountSettings?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Location>> onGotAvailableTrends
	override gotAvailableTrends(ResponseList<Location> arg0) {
		onGotAvailableTrends?.callback(arg0)
	}
	
	@Property TwitterCallback<IDs> onGotBlockIDs
	override gotBlockIDs(IDs arg0) {
		onGotBlockIDs?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<User>> onGotBlocksList
	override gotBlocksList(ResponseList<User> arg0) {
		onGotBlocksList?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Location>> onGotClosestTrends
	override gotClosestTrends(ResponseList<Location> arg0) {
		onGotClosestTrends?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<User>> onGotContributees
	override gotContributees(ResponseList<User> arg0) {
		onGotContributees?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<User>> onGotContributors
	override gotContributors(ResponseList<User> arg0) {
		onGotContributors?.callback(arg0)
	}
	
	@Property TwitterCallback<DirectMessage> onGotDirectMessage
	override gotDirectMessage(DirectMessage arg0) {
		onGotDirectMessage?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<DirectMessage>> onGotDirectMessages
	override gotDirectMessages(ResponseList<DirectMessage> arg0) {
		onGotDirectMessages?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Status>> onGotFavorites
	override gotFavorites(ResponseList<Status> arg0) {
		onGotFavorites?.callback(arg0)
	}
	
	@Property TwitterCallback<IDs> onGotFollowersIDs
	override gotFollowersIDs(IDs arg0) {
		onGotFollowersIDs?.callback(arg0)
	}
	
	@Property TwitterCallback<PagableResponseList<User>> onGotFollowersList
	override gotFollowersList(PagableResponseList<User> arg0) {
		onGotFollowersList?.callback(arg0)
	}
	
	@Property TwitterCallback<IDs> onGotFriendsIDs
	override gotFriendsIDs(IDs arg0) {
		onGotFriendsIDs?.callback(arg0)
	}
	
	@Property TwitterCallback<PagableResponseList<User>> onGotFriendsList
	override gotFriendsList(PagableResponseList<User> arg0) {
		onGotFriendsList?.callback(arg0)
	}
	
	@Property TwitterCallback<Place> onGotGeoDetails
	override gotGeoDetails(Place arg0) {
		onGotGeoDetails?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Status>> onGotHomeTimeline
	override gotHomeTimeline(ResponseList<Status> arg0) {
		onGotHomeTimeline?.callback(arg0)
	}
	
	@Property TwitterCallback<IDs> onGotIncomingFriendships
	override gotIncomingFriendships(IDs arg0) {
		onGotIncomingFriendships?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Language>> onGotLanguages
	override gotLanguages(ResponseList<Language> arg0) {
		onGotLanguages?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<User>> onGotMemberSuggestions
	override gotMemberSuggestions(ResponseList<User> arg0) {
		onGotMemberSuggestions?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Status>> onGotMentions
	override gotMentions(ResponseList<Status> arg0) {
		onGotMentions?.callback(arg0)
	}
	
	@Property TwitterCallback<AccessToken> onGotOAuthAccessToken
	override gotOAuthAccessToken(AccessToken arg0) {
		onGotOAuthAccessToken?.callback(arg0)
	}
	
	@Property TwitterCallback<RequestToken> onGotOAuthRequestToken
	override gotOAuthRequestToken(RequestToken arg0) {
		onGotOAuthRequestToken?.callback(arg0)
	}
	
	@Property TwitterCallback<OEmbed> onGotOEmbed
	override gotOEmbed(OEmbed arg0) {
		onGotOEmbed?.callback(arg0)
	}
	
	@Property TwitterCallback<IDs> onGotOutgoingFriendships
	override gotOutgoingFriendships(IDs arg0) {
		onGotOutgoingFriendships?.callback(arg0)
	}
	
	@Property TwitterCallback<Trends> onGotPlaceTrends
	override gotPlaceTrends(Trends arg0) {
		onGotPlaceTrends?.callback(arg0)
	}
	
	@Property TwitterCallback<String> onGotPrivacyPolicy
	override gotPrivacyPolicy(String arg0) {
		onGotPrivacyPolicy?.callback(arg0)
	}
	
	@Property TwitterCallback<Map<String,RateLimitStatus>> onGotRateLimitStatus
	override gotRateLimitStatus(Map<String,RateLimitStatus> arg0) {
		onGotRateLimitStatus?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Status>> onGotRetweets
	override gotRetweets(ResponseList<Status> arg0) {
		onGotRetweets?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Status>> onGotRetweetsOfMe
	override gotRetweetsOfMe(ResponseList<Status> arg0) {
		onGotRetweetsOfMe?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Place>> onGotReverseGeoCode
	override gotReverseGeoCode(ResponseList<Place> arg0) {
		onGotReverseGeoCode?.callback(arg0)
	}
	
	@Property TwitterCallback<SavedSearch> onGotSavedSearch
	override gotSavedSearch(SavedSearch arg0) {
		onGotSavedSearch?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<SavedSearch>> onGotSavedSearches
	override gotSavedSearches(ResponseList<SavedSearch> arg0) {
		onGotSavedSearches?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<DirectMessage>> onGotSentDirectMessages
	override gotSentDirectMessages(ResponseList<DirectMessage> arg0) {
		onGotSentDirectMessages?.callback(arg0)
	}
	
	@Property TwitterCallback<Relationship> onGotShowFriendship
	override gotShowFriendship(Relationship arg0) {
		onGotShowFriendship?.callback(arg0)
	}
	
	@Property TwitterCallback<Status> onGotShowStatus
	override gotShowStatus(Status arg0) {
		onGotShowStatus?.callback(arg0)
	}
	
	@Property TwitterCallback<UserList> onGotShowUserList
	override gotShowUserList(UserList arg0) {
		onGotShowUserList?.callback(arg0)
	}
	
	@Property TwitterCallback<SimilarPlaces> onGotSimilarPlaces
	override gotSimilarPlaces(SimilarPlaces arg0) {
		onGotSimilarPlaces?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Category>> onGotSuggestedUserCategories
	override gotSuggestedUserCategories(ResponseList<Category> arg0) {
		onGotSuggestedUserCategories?.callback(arg0)
	}
	
	@Property TwitterCallback<String> onGotTermsOfService
	override gotTermsOfService(String arg0) {
		onGotTermsOfService?.callback(arg0)
	}
	
	@Property TwitterCallback<User> onGotUserDetail
	override gotUserDetail(User arg0) {
		onGotUserDetail?.callback(arg0)
	}
	
	@Property TwitterCallback<PagableResponseList<User>> onGotUserListMembers
	override gotUserListMembers(PagableResponseList<User> arg0) {
		onGotUserListMembers?.callback(arg0)
	}
	
	@Property TwitterCallback<PagableResponseList<UserList>> onGotUserListMemberships
	override gotUserListMemberships(PagableResponseList<UserList> arg0) {
		onGotUserListMemberships?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Status>> onGotUserListStatuses
	override gotUserListStatuses(ResponseList<Status> arg0) {
		onGotUserListStatuses?.callback(arg0)
	}
	
	@Property TwitterCallback<PagableResponseList<User>> onGotUserListSubscribers
	override gotUserListSubscribers(PagableResponseList<User> arg0) {
		onGotUserListSubscribers?.callback(arg0)
	}
	
	@Property TwitterCallback<PagableResponseList<UserList>> onGotUserListSubscriptions
	override gotUserListSubscriptions(PagableResponseList<UserList> arg0) {
		onGotUserListSubscriptions?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<UserList>> onGotUserLists
	override gotUserLists(ResponseList<UserList> arg0) {
		onGotUserLists?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<User>> onGotUserSuggestions
	override gotUserSuggestions(ResponseList<User> arg0) {
		onGotUserSuggestions?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Status>> onGotUserTimeline
	override gotUserTimeline(ResponseList<Status> arg0) {
		onGotUserTimeline?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Friendship>> onLookedUpFriendships
	override lookedUpFriendships(ResponseList<Friendship> arg0) {
		onLookedUpFriendships?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<User>> onLookedupUsers
	override lookedupUsers(ResponseList<User> arg0) {
		onLookedupUsers?.callback(arg0)
	}
	
	@Property TwitterExceptionListener onExceptionListener
	override onException(TwitterException arg0, TwitterMethod arg1) {
		onExceptionListener?.onException(arg0, arg1)
	}
	
	@Property Runnable onRemovedProfileBanner
	override removedProfileBanner() {
		onRemovedProfileBanner?.run()
	}
	
	@Property TwitterCallback<User> onReportedSpam
	override reportedSpam(User arg0) {
		onReportedSpam?.callback(arg0)
	}
	
	@Property TwitterCallback<Status> onRetweetedStatus
	override retweetedStatus(Status arg0) {
		onRetweetedStatus?.callback(arg0)
	}
	
	@Property TwitterCallback<QueryResult> onSearched
	override searched(QueryResult arg0) {
		onSearched?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<Place>> onSearchedPlaces
	override searchedPlaces(ResponseList<Place> arg0) {
		onSearchedPlaces?.callback(arg0)
	}
	
	@Property TwitterCallback<ResponseList<User>> onSearchedUser
	override searchedUser(ResponseList<User> arg0) {
		onSearchedUser?.callback(arg0)
	}
	
	@Property TwitterCallback<DirectMessage> onSentDirectMessage
	override sentDirectMessage(DirectMessage arg0) {
		onSentDirectMessage?.callback(arg0)
	}
	
	@Property TwitterCallback<UserList> onSubscribedUserList
	override subscribedUserList(UserList arg0) {
		onSubscribedUserList?.callback(arg0)
	}
	
	@Property TwitterCallback<UserList> onUnsubscribedUserList
	override unsubscribedUserList(UserList arg0) {
		onUnsubscribedUserList?.callback(arg0)
	}
	
	@Property TwitterCallback<AccountSettings> onUpdatedAccountSettings
	override updatedAccountSettings(AccountSettings arg0) {
		onUpdatedAccountSettings?.callback(arg0)
	}
	
	@Property TwitterCallback<Relationship> onUpdatedFriendship
	override updatedFriendship(Relationship arg0) {
		onUpdatedFriendship?.callback(arg0)
	}
	
	@Property TwitterCallback<User> onUpdatedProfile
	override updatedProfile(User arg0) {
		onUpdatedProfile?.callback(arg0)
	}
	
	@Property TwitterCallback<User> onUpdatedProfileBackgroundImage
	override updatedProfileBackgroundImage(User arg0) {
		onUpdatedProfileBackgroundImage?.callback(arg0)
	}
	
	@Property Runnable onUpdatedProfileBanner
	override updatedProfileBanner() {
		onUpdatedProfileBanner?.run()
	}
	
	@Property TwitterCallback<User> onUpdatedProfileColors
	override updatedProfileColors(User arg0) {
		onUpdatedProfileColors?.callback(arg0)
	}
	
	@Property TwitterCallback<User> onUpdatedProfileImage
	override updatedProfileImage(User arg0) {
		onUpdatedProfileImage?.callback(arg0)
	}
	
	@Property TwitterCallback<Status> onUpdatedStatus
	override updatedStatus(Status arg0) {
		onUpdatedStatus?.callback(arg0)
	}
	
	@Property TwitterCallback<UserList> onUpdatedUserList
	override updatedUserList(UserList arg0) {
		onUpdatedUserList?.callback(arg0)
	}
	
	@Property TwitterCallback<User> onVerifiedCredentials
	override verifiedCredentials(User arg0) {
		onVerifiedCredentials?.callback(arg0)
	}
	
}