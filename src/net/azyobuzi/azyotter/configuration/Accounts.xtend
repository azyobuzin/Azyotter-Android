package net.azyobuzi.azyotter.configuration

import java.util.ArrayList
import net.azyobuzi.azyotter.AzyotterApplication
import android.preference.PreferenceManager
import com.google.common.base.Strings
import com.google.common.base.Joiner

class Accounts {
	static ArrayList<Account> list
	
	static def load(){
		list = new ArrayList<Account>()
		val ids = PreferenceManager.getDefaultSharedPreferences(AzyotterApplication.instance)
			.getString("accounts", "").split(",")
		ids.filter[!Strings.isNullOrEmpty(it)].forEach[list.add(new Account(Long.valueOf(it)))]
	}
	
	static def getList(){
		list
	}
	
	static def save(){
		PreferenceManager.getDefaultSharedPreferences(AzyotterApplication.instance)
			.edit().putString("accounts", Joiner.on(",").join(list.map[it.id])).apply()
	}
	
	static def getActiveAccount(){
		val id = PreferenceManager.getDefaultSharedPreferences(AzyotterApplication.instance).getLong("activeAccount", -1)
		list.filter[it.id == id].head ?: list.head
	}
}