package net.azyobuzi.azyotter.timelines

import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import net.azyobuzi.azyotter.R
import android.support.v4.app.ListFragment
import android.os.Handler
import net.azyobuzi.azyotter.configuration.Tab
import net.azyobuzi.azyotter.configuration.Tabs

abstract class TimelineFragment extends ListFragment {
	protected var Handler handler
	protected var Tab tab
	
	override onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		inflater.inflate(R.layout.timeline, container, false)
	}
	
	override onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState)
		
		handler = new Handler()
		
		if (savedInstanceState != null){
			if (savedInstanceState.containsKey("tab_id")){
				tab = Tabs.list.filter[it.id == savedInstanceState.getLong("tab_id")].head
			}
		}
	}
	
	override onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState)
		outState.putLong("tab_id", tab.id)
	}
	
	def void reload()
	
	@Property Runnable onCompleteReload
	
	def completedReload(){
		onCompleteReload?.run()
	}
	
}