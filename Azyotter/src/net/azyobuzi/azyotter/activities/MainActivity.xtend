package net.azyobuzi.azyotter.activities

import android.os.Bundle
import android.view.Menu
import net.azyobuzi.azyotter.R
import net.azyobuzi.azyotter.configuration.Accounts
import android.content.Intent
import android.view.MenuItem
import android.support.v7.app.ActionBarActivity
import android.support.v4.view.ViewPager
import net.azyobuzi.azyotter.configuration.Tabs
import net.azyobuzi.azyotter.timelines.TimelineFragment
import java.util.ArrayList
import net.azyobuzi.azyotter.configuration.TabType
import net.azyobuzi.azyotter.timelines.HomeTimelineFragment
import android.support.v4.app.FragmentStatePagerAdapter
import net.azyobuzi.azyotter.timelines.MentionsTimelineFragment
import android.net.Uri
import android.support.v4.view.MenuItemCompat

class MainActivity extends ActionBarActivity {
	var ViewPager viewPager
	var TimelinePagerAdapter adapter
	var MenuItem refreshMenu
	
	var reloadingCount = 0
	
	override onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState)
		
		if (Accounts.list.empty){
			startActivity(new Intent(this, AccountsActivity).putExtra("first_run", true))
			finish()
			return
		}
		
		setContentView(R.layout.activity_main)
		supportActionBar.displayShowTitleEnabled = false
		
		viewPager = findViewById(R.id.pager) as ViewPager
		adapter = new TimelinePagerAdapter(this)
		viewPager.adapter = adapter
		/*adapter.fragments.forEach[
			startedReload()
			it.reload()
		]*/
	}
	
	override onCreateOptionsMenu(Menu menu) {
		menuInflater.inflate(R.menu.main, menu)
		refreshMenu = menu.findItem(R.id.action_refresh)
		if (reloadingCount > 0){
			MenuItemCompat.setActionView(refreshMenu, R.layout.actionbar_indeterminate_progress)
		}
		true
	}
	
	override onOptionsItemSelected(MenuItem item){
		switch item.itemId {
			case R.id.action_twitter:{
				startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://twitter.com/")))
				true
			}
			case R.id.action_refresh:{
				startedReload()
				adapter.fragments.get(viewPager.currentItem).reload()
				true
			}
			case R.id.action_post:{
				startActivity(new Intent(this, UpdateStatusActivity).putExtra("internal", true))
				true
			}
			case R.id.action_accounts:{
				startActivity(new Intent(this, AccountsActivity))
				true
			}
			default: super.onOptionsItemSelected(item)
		}
	}
	
	override protected onResume() {
		super.onResume()
		
		if (Tabs.modified){
			adapter.notifyDataSetChanged()
		}
	}
	
	def startedReload(){
		reloadingCount = reloadingCount + 1
		if (reloadingCount == 1 && refreshMenu != null){
			MenuItemCompat.setActionView(refreshMenu, R.layout.actionbar_indeterminate_progress)
		}
	}
	
	def completedReload(){
		reloadingCount = reloadingCount - 1
		if (reloadingCount <= 0){
			MenuItemCompat.setActionView(refreshMenu, null)
		}
	}
	
}

class TimelinePagerAdapter extends FragmentStatePagerAdapter{
	public val fragments = new ArrayList<TimelineFragment>()
	val MainActivity activity
	
	new(MainActivity activity) {
		super(activity.supportFragmentManager)
		this.activity = activity
		refreshFragments()
	}
	
	override getItem(int position) {
		fragments.get(position)
	}
	
	override getCount() {
		fragments.size()
	}
	
	override getPageTitle(int position) {
		Tabs.list.get(position).title
	}
	
	override notifyDataSetChanged() {
		refreshFragments()
		super.notifyDataSetChanged()
	}
	
	private def refreshFragments(){
		fragments.clear()
		Tabs.list.forEach[
			val fragment = switch it.type{
				case TabType.HOME: HomeTimelineFragment.createInstance(it)
				case TabType.MENTIONS: MentionsTimelineFragment.createInstance(it)
				default: null
			}
			fragment.onCompleteReload = [| activity.completedReload()]
			fragments.add(fragment)
		]
	}
}