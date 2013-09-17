package net.azyobuzi.azyotter.providers

import android.content.ContentProvider
import android.net.Uri
import android.content.ContentValues
import net.azyobuzi.azyotter.database.CachedTweetsSQLite
import com.google.common.base.Strings
import com.google.common.collect.Lists
import android.content.ContentUris
import android.database.SQLException

class CachedTweetsProvider extends ContentProvider {
	public static val AUTHORITY = "net.azyobuzi.azyotter.providers.CachedTweetsProvider"
	
	static def createUri(long tabId) {
		Uri.parse("content://" + AUTHORITY + "/" + tabId)
	}
	
	static def createUri(long tabId, long statusId) {
		Uri.parse("content://" + AUTHORITY + "/" + tabId + "/" + statusId)
	}
		
	CachedTweetsSQLite openHelper
	
	override onCreate() {
		openHelper = new CachedTweetsSQLite()
		true
	}
		
	override getType(Uri uri) {
		if (uri.pathSegments.size() == 1) "vnd.android.cursor.dir/vnd.net.azyobuzi.azyotter.tweet"
		else "vnd.android.cursor.item/vnd.net.azyobuzi.azyotter.tweet"
	}
	
	override delete(Uri uri, String selection, String[] selectionArgs) {
		val table = "tab_" + uri.pathSegments.get(0)
		val db = openHelper.createTableIfNotExists(table)
		try {
			var whereClause = selection
			var whereArgs = selectionArgs
			if (uri.pathSegments.size() > 1) {
				whereClause = "_id = ?"
					+ if (Strings.isNullOrEmpty(selection)) "" else " AND (" + selection + ")"
				whereArgs = Lists.asList(uri.pathSegments.get(1), selectionArgs).toArray(#[])
			}
			val count = db.delete(table, whereClause, whereArgs)
			db.setTransactionSuccessful()
			context.contentResolver.notifyChange(uri, null)
			count
		} finally {
			db.endTransaction()
		}
	}
		
	override insert(Uri uri, ContentValues values) {
		val table = "tab_" + uri.pathSegments.get(0)
		val db = openHelper.createTableIfNotExists(table)
		try {
			val rowId = db.replaceOrThrow(table, null, values) //rowId == primary key
			db.setTransactionSuccessful()
			val newUri = ContentUris.withAppendedId(uri, rowId)
			context.contentResolver.notifyChange(uri, null)
			newUri
		} finally {
			db.endTransaction()
		}
	}
	
	override query(Uri uri, String[] projection, String selection, String[] selectionArgs, String sortOrder) {
		try {
			val db = openHelper.readableDatabase
			var _selection = selection
			var _selectionArgs = selectionArgs
			if (uri.pathSegments.size() > 1) {
				_selection = "_id = ?"
					+ if (Strings.isNullOrEmpty(selection)) "" else " AND (" + selection + ")"
				_selectionArgs = Lists.asList(uri.pathSegments.get(1), selectionArgs).toArray(#[])
			}
			val cursor = db.query("tab_" + uri.pathSegments.get(0), projection, _selection, _selectionArgs, null, null, sortOrder)
			cursor.setNotificationUri(context.contentResolver, uri)
			cursor
		} catch (SQLException e) {
			e.printStackTrace()
			null
		}
	}
	
	override update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
		val table = "tab_" + uri.pathSegments.get(0)
		val db = openHelper.createTableIfNotExists(table)
		try {
			var whereClause = selection
			var whereArgs = selectionArgs
			if (uri.pathSegments.size() > 1) {
				whereClause = "_id = ?"
					+ if (Strings.isNullOrEmpty(selection)) "" else " AND (" + selection + ")"
				whereArgs = Lists.asList(uri.pathSegments.get(1), selectionArgs).toArray(#[])
			}
			val count = db.update(table, values, whereClause, whereArgs)
			db.setTransactionSuccessful()
			context.contentResolver.notifyChange(uri, null)
			count
		} finally {
			db.endTransaction()
		}
	}
	
}