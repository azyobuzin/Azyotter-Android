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
			])
			/*list.add(new Tab(idBase + 1) => [
				type = TabType.MENTIONS
			])*/
			/*list.add(new Tab(idBase + 2) => [
				type = TabType.DIRECT_MESSAGES
			])*/
		}
	}
	
	static def getList(){
		list
	}
	
	static def save(){
		PreferenceManager.getDefaultSharedPreferences(AzyotterApplication.instance)
			.edit().putString("tabs", Joiner.on(",").join(list.map[it.id])).apply()
	}
}