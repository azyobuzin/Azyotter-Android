package net.azyobuzi.azyotter.activities

import android.support.v7.app.ActionBarActivity
import android.os.Bundle
import net.azyobuzi.azyotter.R
import android.view.MenuItem
import android.view.Menu
import android.widget.EditText
import android.text.TextWatcher
import android.text.Editable
import com.twitter.Validator
import android.content.Intent
import net.azyobuzi.azyotter.configuration.Accounts
import twitter4j.StatusUpdate
import net.azyobuzi.azyotter.TwitterClient
import android.support.v4.app.NotificationCompat
import android.app.PendingIntent
import net.azyobuzi.azyotter.Notifications

class UpdateStatusActivity extends ActionBarActivity {
	public static val singletonValidator = new Validator()
		
	var MenuItem counter
	var MenuItem postMenu
	var EditText status
	
	override onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState)
		setContentView(R.layout.activity_update_status)
		supportActionBar.displayHomeAsUpEnabled = true
				
		status = findViewById(R.id.status) as EditText
		status.addTextChangedListener(new StatusTextWatcher(this))
		
		status.setText(intent.getStringExtra("text"))
	}
	
	override onCreateOptionsMenu(Menu menu) {
		menuInflater.inflate(R.menu.update_status, menu)
		counter = menu.findItem(R.id.action_counter)
		postMenu = menu.findItem(R.id.action_post)
		changeCounter()
		true
	}
	
	def changeCounter(){
		val text = status.text.toString()
		if (counter != null) counter.title = String.valueOf(
			Validator.MAX_TWEET_LENGTH - singletonValidator.getTweetLength(text))
		if (postMenu != null) postMenu.enabled = singletonValidator.isValidTweet(text)
	}
	
	override onOptionsItemSelected(MenuItem item) {
		switch item.itemId{
			case android.R.id.home:{
				if (intent.getBooleanExtra("internal", false))
					startActivity(new Intent(this, MainActivity))
				finish()
				true
			}
			case R.id.action_post:{
				val statusText = status.text.toString()
				val statusUpdate = new StatusUpdate(statusText)
				new TwitterClient(Accounts.activeAccount).updateStatus(statusUpdate, [
					//やることない
				], [te, method |
					Notifications.notify(Notifications.TWEET_FAILED,
						new NotificationCompat.Builder(this)
							.setSmallIcon(android.R.drawable.stat_notify_error)
							.setContentTitle(getText(R.string.tweet_failed))
							.setContentText(te.errorMessage)
							.setContentIntent(PendingIntent.getActivity(this, 0,
								new Intent(this, class).putExtra("text", statusText),
								0
							))
							.setAutoCancel(true)
							.build()
						)
				])
				finish()
				true
			}
			default: super.onOptionsItemSelected(item)
		}
	}
	
}

class StatusTextWatcher implements TextWatcher{
	new(UpdateStatusActivity activity){
		this.activity = activity
	}
	
	val UpdateStatusActivity activity
	
	override afterTextChanged(Editable s) {
		activity.changeCounter()
	}
	
	override beforeTextChanged(CharSequence s, int start, int count, int after) {}
	
	override onTextChanged(CharSequence s, int start, int before, int count) {}
	
}