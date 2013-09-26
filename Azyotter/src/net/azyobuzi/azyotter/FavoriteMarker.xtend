package net.azyobuzi.azyotter

import java.util.Map
import org.msgpack.MessagePack
import org.msgpack.template.Templates
import java.util.List
import java.util.HashMap
import java.io.IOException
import android.content.Context
import net.azyobuzi.azyotter.configuration.Account
import java.util.ArrayList

class FavoriteMarker {
	private new() { }
	
	private static Map<Long, List<Long>> m_map
	private static val template = Templates.tMap(Templates.TLong, Templates.tList(Templates.TLong))
	private static val FILE_NAME = "favorites.msgpack"
	private static val CAPACITY_PER_ACCOUNT = 10000
	
	static def load() {
		try {
			val unpacker = new MessagePack().createUnpacker(
				AzyotterApplication.instance.openFileInput(FILE_NAME)
			)
			m_map = unpacker.read(template)
			unpacker.close()
		} catch (IOException e) {
			m_map = new HashMap<Long, List<Long>>()
		}
	}
	
	static def save() {
		m_map.values.forEach[list |
			val over = list.size() - CAPACITY_PER_ACCOUNT
			if (over > 0) {
				(1..over).forEach[list.remove(0)]
			}
		]
		
		val packer = new MessagePack().createPacker(
			AzyotterApplication.instance.openFileOutput(FILE_NAME, Context.MODE_PRIVATE)
		)
		packer.write(m_map)
		packer.close()
	}
	
	static def mark(Account account, long statusId) {
		val accountId = account.id
		val list = m_map.get(accountId) ?: new ArrayList<Long>() => [m_map.put(accountId, it)]
		list.remove(statusId)
		list.add(statusId)
	}
	
	static def unmark(Account account, long statusId) {
		val list = m_map.get(account.id)
		if (list != null) list.remove(statusId)
	}
	
	static def isFavorited(Account account, long statusId) {
		val list = m_map.get(account.id)
		list != null && list.contains(statusId)
	}
	
	static def removeAccount(Account account) {
		m_map.remove(account.id)
	}
}