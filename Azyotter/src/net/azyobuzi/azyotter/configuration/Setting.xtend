package net.azyobuzi.azyotter.configuration

import android.content.SharedPreferences

class Setting {
	private new() { }
	
	static var SharedPreferences sp
	static def initialize(SharedPreferences sharedPreferences) {
		sp = sharedPreferences
	}
	
	static def getSingleTapAction() {
		ActionType.valueOf(sp.getString("singleTapAction", ActionType.OPEN_MENU.toString()))
	}
}