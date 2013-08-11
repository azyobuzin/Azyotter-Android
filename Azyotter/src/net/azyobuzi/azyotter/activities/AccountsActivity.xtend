package net.azyobuzi.azyotter.activities

import android.os.Bundle
import net.azyobuzi.azyotter.R
import android.view.Menu
import android.view.MenuItem
import android.content.Intent
import twitter4j.AsyncTwitterFactory
import twitter4j.TwitterAdapter
import android.app.ProgressDialog
import twitter4j.AsyncTwitter
import twitter4j.auth.RequestToken
import android.os.Handler
import android.net.Uri
import twitter4j.auth.AccessToken
import android.widget.BaseAdapter
import android.view.View
import android.view.ViewGroup
import net.azyobuzi.azyotter.configuration.Accounts
import android.widget.CheckedTextView
import net.azyobuzi.azyotter.configuration.Account
import android.widget.ListView
import android.view.ContextMenu
import android.widget.AdapterView
import android.support.v7.app.ActionBarActivity

class AccountsActivity extends ActionBarActivity {
	var Authorization authorization
	val adapter = new AccountAdapter(this)
	
	public var ListView listView
	
	override onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState)
		setContentView(R.layout.activity_accounts)
		listView = findViewById(android.R.id.list) as ListView
		listView.adapter = adapter
		listView.choiceMode = ListView.CHOICE_MODE_SINGLE
		listView.onItemClickListener = [parent, view, position, id | Accounts.setActiveAccountIndex(position)]
		onAccountsChanged()
		registerForContextMenu(listView)
	}
	
	override onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.accounts, menu)
		true
	}

	override onOptionsItemSelected(MenuItem item){
		switch item.itemId {
			case android.R.id.home:{
				if (intent.getBooleanExtra("first_run", false))
					startActivity(new Intent(this, MainActivity).addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP))
				finish()
				true
			}
			case R.id.action_add_account:{
				authorization = new Authorization(this)
				authorization.startAuthorization()
				true
			}
			default:
				super.onOptionsItemSelected(item)
		}
	}
	
	override onNewIntent(Intent intent){
		authorization.callback(intent.data)
	}
	
	def onAccountsChanged(){
		supportActionBar.setDisplayHomeAsUpEnabled(!Accounts.list.empty)
		adapter.notifyDataSetChanged()
		val activeAccount = Accounts.activeAccountIndex
		if (activeAccount != -1)
			listView.setItemChecked(activeAccount, true)
	}
	
	override onCreateContextMenu(ContextMenu menu, View v, ContextMenu.ContextMenuInfo menuInfo){
		val position = (menuInfo as AdapterView.AdapterContextMenuInfo).position
		val account = Accounts.list.get(position)
		
		menu.setHeaderTitle(account.screenName)
		
		val upMenu = menu.add(R.string.up).setOnMenuItemClickListener([
			val item = Accounts.list.remove(position)
			Accounts.list.add(position - 1, item)
			Accounts.save()
			onAccountsChanged()
			true
		])
		if (position == 0) upMenu.setEnabled(false)
		
		val downMenu = menu.add(R.string.down).setOnMenuItemClickListener([
			val item = Accounts.list.remove(position)
			Accounts.list.add(position + 1, item)
			Accounts.save()
			onAccountsChanged()
			true
		])
		if (position == Accounts.list.size() - 1) downMenu.setEnabled(false)
		
		val removeMenu = menu.add(R.string.remove).setOnMenuItemClickListener([
			Accounts.list.remove(position).clear()
			Accounts.save()
			onAccountsChanged()
			true
		])
		if (Accounts.list.size() <= 1) removeMenu.setEnabled(false)
	}
}

class Authorization extends TwitterAdapter {
	new(AccountsActivity activity){
		this.activity = activity
		twitter = new AsyncTwitterFactory().instance
		twitter.addListener(this)
	}
	
	val AccountsActivity activity
	val AsyncTwitter twitter
	val handler = new Handler()
	var ProgressDialog dialog
	var canceled = false
	var RequestToken requestToken
	
	private def showDialog(){
		dialog = new ProgressDialog(activity) => [
			message = activity.getText(R.string.getting_token)
			indeterminate = true
			cancelable = true
			onCancelListener = [canceled = true]
		]
		dialog.show()
	}
	
	def startAuthorization(){
		canceled = false
		showDialog()
		twitter.OAuthRequestTokenAsync
	}
	
	override gotOAuthRequestToken(RequestToken token) {
		if (!canceled) {
			handler.post[|
				requestToken = token
				activity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(token.authorizationURL)))
				dialog.dismiss()
				dialog = null
			]
		}
	}
	
	def callback(Uri uri){
		val verifier = uri?.getQueryParameter("oauth_verifier")
		if (verifier != null) {
			showDialog()
			twitter.getOAuthAccessTokenAsync(requestToken, verifier)
		}
	}
	
	override gotOAuthAccessToken(AccessToken token) {
		if (!canceled) {
			handler.post[|
				dialog.dismiss()
				dialog = null
				if (!Accounts.list.exists[it.id == token.userId]){
					Accounts.list.add(new Account(token.userId) => [
						screenName = token.screenName
						OAuthToken = token.token
						OAuthTokenSecret = token.tokenSecret
					])
					Accounts.save()
					activity.onAccountsChanged()
				}
			]
		}
	}
}

class AccountAdapter extends BaseAdapter{
	new(AccountsActivity activity){
		this.activity = activity
	}
	
	val AccountsActivity activity
	
	override getCount() {
		Accounts.list.size()
	}
	
	override getItem(int position) {
		Accounts.list.get(position)
	}
	
	override getItemId(int position) {
		return position
	}
	
	override getView(int position, View convertView, ViewGroup parent) {
		val view = (convertView ?: activity.layoutInflater.inflate(android.R.layout.simple_list_item_single_choice, parent, false)) as CheckedTextView
		view.setText((getItem(position) as Account).screenName)
		view
	}
}