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
import android.net.Uri

class UpdateStatusActivity extends ActionBarActivity {
	public static val singletonValidator = new Validator()
	public static val PICK_PICTRUE = 0
		
	var MenuItem counter
	var MenuItem postMenu
	var EditText status
	var MenuItem attachPicture
	
	Uri pictureUri
	
	override onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState)
		setContentView(R.layout.activity_update_status)
		supportActionBar.displayHomeAsUpEnabled = true
				
		status = findViewById(R.id.status) as EditText
		status.addTextChangedListener(new StatusTextWatcher(this))
		
		if (intent.hasExtra(Intent.EXTRA_STREAM))
			pictureUri = intent.getParcelableExtra(Intent.EXTRA_STREAM) as Uri
		if (intent.hasExtra(Intent.EXTRA_SUBJECT))
			status.append(intent.getStringExtra(Intent.EXTRA_SUBJECT) + " ")
		if (intent.hasExtra(Intent.EXTRA_TEXT))
			status.append(intent.getStringExtra(Intent.EXTRA_TEXT))
	}
	
	override onCreateOptionsMenu(Menu menu) {
		menuInflater.inflate(R.menu.update_status, menu)
		counter = menu.findItem(R.id.action_counter)
		postMenu = menu.findItem(R.id.action_post)
		attachPicture = menu.findItem(R.id.action_attach_picture)
		changeCounter()
		attachPicture.checked = pictureUri != null
		true
	}
	
	def changeCounter(){
		var text = status.text.toString()
		if (pictureUri != null)
			text = text + " http://t.co/xxxxxxxxxx"
		if (counter != null) counter.title = String.valueOf(
			Validator.MAX_TWEET_LENGTH - singletonValidator.getTweetLength(text))
		if (postMenu != null) postMenu.enabled = singletonValidator.isValidTweet(text)
	}
	
	override onOptionsItemSelected(MenuItem item) {
		switch item.itemId{
			case android.R.id.home:{
				if (!intent.getBooleanExtra("internal", false))
					startActivity(new Intent(this, MainActivity).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
				finish()
				true
			}
			case R.id.action_post:{
				val statusText = status.text.toString()
				val statusUpdate = new StatusUpdate(statusText)
				
				if (pictureUri != null) {
					try {
						statusUpdate.setMedia("media", contentResolver.openInputStream(pictureUri))
					} catch (Exception e) {
						e.printStackTrace()
					}
				}
				
				new TwitterClient(Accounts.activeAccount).updateStatus(statusUpdate, [
					//やることない
				], [te, method |
					Notifications.notify(Notifications.TWEET_FAILED,
						new NotificationCompat.Builder(this)
							.setSmallIcon(android.R.drawable.stat_notify_error)
							.setContentTitle(getText(R.string.tweet_failed))
							.setContentText(te.errorMessage)
							.setContentIntent(PendingIntent.getActivity(this, 0,
								new Intent(this, class)
									.putExtra(Intent.EXTRA_TEXT, statusText)
									.putExtra(Intent.EXTRA_STREAM, pictureUri),
								0
							))
							.setAutoCancel(true)
							.build()
						)
				])
				finish()
				true
			}
			case R.id.action_attach_picture:{
				if (pictureUri == null) {
					startActivityForResult(
						new Intent(Intent.ACTION_GET_CONTENT).setType("image/*"),
						PICK_PICTRUE
					)
				} else {
					pictureUri = null
					attachPicture.checked = false
					changeCounter()
				}
				true
			}
			default: super.onOptionsItemSelected(item)
		}
	}
	
	override protected onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode == RESULT_OK) {
			if (requestCode == PICK_PICTRUE) {
				pictureUri = data.data
				attachPicture.checked = true
				changeCounter()
			}
		}
		
		super.onActivityResult(requestCode, resultCode, data)
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