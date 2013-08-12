package net.azyobuzi.azyotter.configuration

import java.util.ArrayList
import android.preference.PreferenceManager
import net.azyobuzi.azyotter.AzyotterApplication
import com.google.common.base.Strings
import com.google.common.base.Joiner

class Tabs {
	static ArrayList<Tab> list
	
	static def load(){
		list = new ArrayList<Tab>()
		PreferenceManager.getDefaultSharedPreferences(AzyotterApplication.instance)
			.getString("tabs", "").split(",")
			.filter[!Strings.isNullOrEmpty(it)]
			.forEach[list.add(new Tab(Long.valueOf(it)))]
		
		if (list.empty){
			val idBase = System.currentTimeMillis
			list.add(new Tab(idBase) => [
				type = TabType.HOME
				title = "Home"
			])
			list.add(new Tab(idBase + 1) => [
				type = TabType.MENTIONS
				title = "Mentions"
			])
			/*list.add(new Tab(idBase + 2) => [
				type = TabType.DIRECT_MESSAGES
				title = "DirectMessages"
			])*/
		}
	}
	
	static def getList(){
		list
	}
	
	public static var boolean modified = false
	
	static def save(){
		PreferenceManager.getDefaultSharedPreferences(AzyotterApplication.instance)
			.edit().putString("tabs", Joiner.on(",").join(list.map[it.id])).apply()
	}
}