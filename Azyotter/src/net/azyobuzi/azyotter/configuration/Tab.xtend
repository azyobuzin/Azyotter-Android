package net.azyobuzi.azyotter.configuration

import android.content.SharedPreferences
import android.content.Context
import net.azyobuzi.azyotter.AzyotterApplication
import com.google.common.base.Joiner
import com.google.common.collect.Iterables
import com.google.common.base.Strings

class Tab {
	new(long id){
		this.id = id
		sp = AzyotterApplication.instance.getSharedPreferences("tab_" + id, Context.MODE_PRIVATE)
		type = TabType.valueOf(sp.getString("type", TabType.HOME.name()))
		_isAllUsers = sp.getBoolean("isAllUsers", true)
		users = Iterables.toArray(sp.getString("users", "").split(",")
			.filter[!Strings.isNullOrEmpty(it)]
			.map[Long.valueOf(it)], Long)
	}
	
	val SharedPreferences sp
	
	val long id
	def getId(){
		id
	}
	
	var TabType type
	def getType(){
		type
	}
	def setType(TabType value){
		type = value
		sp.edit().putString("type", value.name()).apply()
	}
	
	var boolean _isAllUsers
	def isAllUsers(){
		_isAllUsers
	}
	def setAllUsers(boolean value){
		_isAllUsers = value
		sp.edit().putBoolean("isAllUsers", value).apply()
	}
	
	var Long[] users
	def getUsers(){
		users
	}
	def setUsers(Long[] value){
		users = value
		sp.edit().putString("users", Joiner.on(",").join(value))
	}
	
	def clear(){
		sp.edit().clear().apply()
	}
}