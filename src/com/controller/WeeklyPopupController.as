package com.controller
{

import com.Constants;
import com.model.DataService;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

import org.osflash.signals.DeluxeSignal;
	
	
/**
 * This controller checks sqlite epoch date and compares it to current
 * If it has expired, new data is requested from server
 */


public class WeeklyPopupController
{
	private var service:DataService;
	private var queryType:int // 0 = query returning data, 1 = update table
	private var loader:URLLoader;
	private var validChallengeCode:String;
	private var validEpoch:int;
	private var difficultyLevel:String;
	
	private var _topView:MovieClip = new MovieClip();
	
	public var weeklyPopupDataReturned:DeluxeSignal = new DeluxeSignal();
	
	public function WeeklyPopupController(topView)
	{
		trace("WeeklyPopupController()");
		
		_topView = topView;
		
		getLocalData();
	}
	
	
	//1 Check local data
	private function getLocalData():void
	{
		//now get local data to compare
		queryType = 0;
		service = new DataService();		
		var stmtText:String = "SELECT * FROM "+Constants.WEEKLY_CHALLENGE_TABLE+" ORDER BY Id DESC LIMIT 1;";
		service.userDataReturnedSignal.addOnce(localDataReturned);
		service.queryDatabase(stmtText, queryType);
	}
	
	private function localDataReturned(dataObj:Object):void
	{
		trace("WeeklyPopupController.localDataReturned() - data : " + dataObj);
		
		//parse data for stored epoch time... and passcode
		for each(var row:Object in dataObj.data)
		{			
			var challengeCode:String="";
			if(row.Passcode != null)
				challengeCode = row.Passcode;
			
			var difficulty:String="";
			if(row.Difficulty != null)
				difficulty = row.Difficulty;
			
			var savedEpoch:int = 0;
			if(row.Epoch != null)
				savedEpoch = row.Epoch;
		}
		
		//current epoch
		var now:Date = new Date();
		var currentEpoch:Number = Math.round(now.valueOf()/1000);
		
		trace("WeeklyPopupController.localDataReturned() - challengeCode : " + challengeCode);
		trace("WeeklyPopupController.localDataReturned() - difficulty : " + difficulty);
		trace("WeeklyPopupController.localDataReturned() - savedEpoch : " + savedEpoch);	
		trace("WeeklyPopupController.localDataReturned() - currentEpoch : " + currentEpoch);
		
		//LOCAL DATA IS STILL VALID
		if(savedEpoch > currentEpoch)
		{
			trace("		- LOCAL CHALLENGE CODE DATA IS STILL VALID");
			
			weeklyPopupDataReturned.dispatch("useCurrentData", null, null, null);
		}
		// ... OR GET NEW DATA
		else  
		{
			trace("		- LOCAL CHALLENGE CODE HAS EXPIRED, GET NEW DATA");
			requestServerData();
		}		
	}	
	
	// 2 GET REMOTE DATA IF NEEDED
	private function requestServerData():void
	{
		trace("WeeklyPopupController.requestServerData()");	
		
		var req:URLRequest = new URLRequest();
		req.url = Constants.BASE_URL + Constants.WEEKLY_CHALLENGE_REQUEST;
		
		loader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.TEXT;
		loader.addEventListener(Event.COMPLETE, serverDataReturned);
		loader.addEventListener(IOErrorEvent.IO_ERROR, request_ioFault);
		loader.load(req);
	}
	
	private function serverDataReturned(e:Event):void
	{
		trace("WeeklyPopupController.serverDataReturned() - loader.data : " + loader.data);	
		
		if(loader.data == null)
		{
			trace("Challenge Data Returned is null!!");
			weeklyPopupDataReturned.dispatch("useCurrentData", null, null, null);
			return;
		}
		
		
		var jsonObj:Object = JSON.parse(loader.data);
		
		trace("jsonObj : " + jsonObj);
		trace("jsonObj.data : " + jsonObj.data);
		
		var newChallengeCode:String = String(jsonObj.data.passcode);
		var newEpoch:int = int(jsonObj.data.epoch);	
		
		if(!newChallengeCode.length || newEpoch<0)
		{
			trace("JSON is not good!");
			return;
		}
		trace("jsonObj.data.passcode : " + jsonObj.data.passcode);
		trace("jsonObj.data.epoch : " + jsonObj.data.epoch);
		trace("jsonObj.data.difficulty : " + jsonObj.data.difficulty);
		
		validEpoch = newEpoch;
		validChallengeCode = newChallengeCode;
		difficultyLevel = jsonObj.data.difficulty;
		
		updateLocalDatabase();
	}
	
	private function updateLocalDatabase():void
	{
		trace("WeeklyPopupController.updateLocalDatabase()");
		
		//upate sqlite database with new data
		queryType = 1;
		service = new DataService();		
		var stmtText:String = "INSERT INTO "+Constants.WEEKLY_CHALLENGE_TABLE+" (Passcode, Difficulty, Epoch)VALUES ('"
								+validChallengeCode+"',"+"'"+difficultyLevel+"',"+validEpoch+");";
		service.userTableUpdatedSignal.addOnce(getCurrentEmail);
		service.queryDatabase(stmtText, queryType);
	}
	
	
	//3 GET CURRENT EMAIL ADDRESS IF EXISTS
	
	private function getCurrentEmail()
	{
		var email:String = null;
		if(_topView.userVO.currentEmail)
			email = _topView.userVO.currentEmail;
		
		trace("WeeklyPopupController.getCurrentEmail() - email : " + email);
		
		//3 Dispatch updated data
		weeklyPopupDataReturned.dispatch(validChallengeCode, email, difficultyLevel, validEpoch);
	}
	
	
	//TODO: Program what to do in case of error - return to main menu
	
	private function request_ioFault(e:IOErrorEvent):void
	{
		trace("Data request failure! : " + e.target.data);
		
		weeklyPopupDataReturned.dispatch("dataerror", null, null, null);
	}
}	
}