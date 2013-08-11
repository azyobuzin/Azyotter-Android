package net.azyobuzi.azyotter.timelines

import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import net.azyobuzi.azyotter.R
import android.support.v4.app.ListFragment

abstract class TimelineFragment extends ListFragment {
		
	override onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		inflater.inflate(R.layout.timeline, container, false)
	}
	
	def void reload()
	
	@Property Runnable onCompleteReload
	
	def completedReload(){
		onCompleteReload?.run()
	}
	
}