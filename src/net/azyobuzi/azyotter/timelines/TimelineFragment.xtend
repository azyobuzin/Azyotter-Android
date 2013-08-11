package net.azyobuzi.azyotter.timelines

import android.app.ListFragment
import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import net.azyobuzi.azyotter.R

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