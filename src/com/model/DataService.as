/**
 *  Database service handles SQLite requests  
 * 
 **/

package com.model
{
	import com.Constants;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	
	import org.osflash.signals.DeluxeSignal;
	import org.osflash.signals.Signal;
	
	public class DataService
	{
		private const DB_NAME:String = Constants.DATABASE_NAME;
		private var bundledDB:File;
		private var writableDB:File;
		private var setMusicOn:Boolean; // new database has no music data therefore defaults to off - we want the default to be on
		
		private var connection:SQLConnection;
		private var statement:SQLStatement;
		private var _stmtText:String;	
		private var _queryType:int=-1;
		
		public var dataReturnedSignal:DeluxeSignal = new DeluxeSignal(); // this signal is used both for Synonyms data request and KeywordDefinitionModel request 
		public var userDataReturnedSignal:DeluxeSignal = new DeluxeSignal();
		
		public var databaseSetupSignal:DeluxeSignal = new DeluxeSignal();
		public var userTableUpdatedSignal:Signal = new Signal();		
		
		public function DataService()
		{
			//trace("DataService");
		}
		
		/**
		 * Update writableDB with bundleDB. This is done only when installing or updating app
		 * Doing this will destroy any User table data. User data will return to default settings
		 **/
		public function setupDatabase():void
		{
			bundledDB = File.applicationDirectory.resolvePath(DB_NAME);
			writableDB = File.applicationStorageDirectory.resolvePath(DB_NAME);
			
			
			//trace("bundledDB.creationDate : " + bundledDB.creationDate);
			//trace("writableDB.modificationDate : " + writableDB.modificationDate);
			
			//var bundledIsNewer:Boolean = bundledDB.creationDate > writableDB.modificationDate ? true : false;
			//trace("bundledIsNewer : " + bundledIsNewer);
			
			if(!writableDB.exists)
			{
				bundledDB.copyTo(writableDB); //save new database when app installs
				setMusicOn = true
			}
			
			//if(Capabilities.os.indexOf("iPhone") >= 0 || Capabilities.os.indexOf("iPad") >= 0)
			//{
			writableDB.preventBackup = true;
			//}
			
			databaseSetupSignal.dispatch(setMusicOn);
		}
		
		public function queryDatabase(stmtText:String, queryType:int=-1):void
		{
			_queryType = queryType;
			_stmtText = stmtText;

			trace("DataService		- stmtText : " + _stmtText);
			
			writableDB = File.applicationStorageDirectory.resolvePath(DB_NAME);
			connection = new SQLConnection;
			connection.addEventListener(SQLEvent.OPEN, dbOpen);
			connection.addEventListener(SQLErrorEvent.ERROR, dbError);
			connection.openAsync(writableDB);
		}
		
		protected function dbOpen(sqlEvt:SQLEvent):void
		{
			if (writableDB==null || !writableDB.exists)
			{
				throw new Error("error NO DATABASE");
			}
			else
			{
				//trace("Database opened : " + writableDB.name);
				//trace("Database size : " + writableDB.size);
			}
			query(null);
		}
		
		protected function query(e:TimerEvent = null):void
		{			
			if(!statement)
			{				
				statement = new SQLStatement;
				statement.addEventListener(SQLEvent.RESULT, stmtResult);
				statement.addEventListener(SQLErrorEvent.ERROR, stmtError);
				//trace("** Create new Statement");
			}		
			if(!statement.executing)
			{
				try
				{
					statement.sqlConnection = connection;
					statement.text = _stmtText;
					statement.execute();
					//trace("**Statement is executing");
				}
				catch(error:Error)
				{
					trace('error executing query : ' + error);
				}
			}
			else
			{
				var timer:Timer = new Timer(10,1);
				timer.addEventListener(TimerEvent.TIMER, query, false, 0, true);
				timer.start();
			}
		}
		
		protected function stmtResult(sqlEvt:SQLEvent):void
		{			
			removeListeners();
			
			var result:SQLResult = statement.getResult();			
			if(!result)
			{
				trace("NO DATABASE QUERY RESULTS!!")
				return;	
			}			
			var dataObj:Object = new Object;
			dataObj.data = result.data;
						
			if(_queryType >= 0)
			{
				if(_queryType == 0)
					userDataReturnedSignal.dispatch(dataObj);
				else
					userTableUpdatedSignal.dispatch();
			}
			else
				dataReturnedSignal.dispatch(dataObj);
			
			statement = null;
		}
		
		protected function dbError(sqlErrorEvt:SQLErrorEvent):void
		{
			trace('Database Error message (Unable To Open) : ' + sqlErrorEvt.error.message);
		}
		
		protected function stmtError(sqlErrorEvt:SQLErrorEvent):void
		{
			trace('SQL Query Error : ' + sqlErrorEvt.error.message);
		}	
		
		// REMOVE LISTENERS  -----------------------------------------
		
		private function removeListeners():void
		{		
			if(connection)
			{
				connection.removeEventListener(SQLEvent.OPEN, dbOpen);
				connection.removeEventListener(SQLErrorEvent.ERROR, dbError);
			}
			if(statement)
			{
				statement.removeEventListener(SQLEvent.RESULT, stmtResult);
				statement.removeEventListener(SQLErrorEvent.ERROR, stmtError);
			}
			connection.close();
			
			//trace("** DataService - connection is closed");
		}
	}
}