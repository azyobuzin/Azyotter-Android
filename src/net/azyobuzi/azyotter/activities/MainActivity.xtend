package net.azyobuzi.azyotter.activities

import android.app.Activity
import android.os.Bundle
import android.view.Menu
import net.azyobuzi.azyotter.R
import net.azyobuzi.azyotter.configuration.Accounts
import android.content.Intent
import android.view.MenuItem

class MainActivity extends Activity {
	override onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState)
		
		if (Accounts.list.empty){
			startActivity(new Intent(this, AccountsActivity).putExtra("first_run", true))
			finish()
			return
		}
		
		setContentView(R.layout.activity_main)
	}
	
	override onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.main, menu)
		true
	}
	
	override onOptionsItemSelected(MenuItem item){
		switch item.itemId {
			case R.id.action_accounts:{
				startActivity(new Intent(this, AccountsActivity))
				true
			}
			default: super.onOptionsItemSelected(item)
		}
	}
}