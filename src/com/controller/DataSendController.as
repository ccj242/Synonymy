package com.controller
{

import com.Constants;
import com.model.DataService;
import com.model.UrlLoad;

import flash.display.MovieClip;

import org.osflash.signals.DeluxeSignal;
	
	
/**
 * This class is used to send data to server when successfully completing a game
 */


public class DataSendController
{
	private var _topView:MovieClip;	
	private var jsonString:String;
	public var dataSent:DeluxeSignal = new DeluxeSignal();
	
	public function DataSendController(topView:MovieClip)
	{	
		_topView = topView;
	}
	
	public function init():void
	{
		var dataObject:Object			= new Object();
		dataObject["userName"] 			= _topView.userVO.userName;
		dataObject["passcode"] 			= _topView.userVO.password;
		dataObject["difficulty"] 		= Constants.DIFFICULTY_ARRAY[_topView.userVO.difficultyNum];
		dataObject["challengeMode"] 	= _topView.userVO.challengeMode;
		dataObject["email"]				= _topView.userVO.currentEmail;
		
		dataObject["wordArray"] 		= _topView.gameDataVO.allWordsArray;
		dataObject["totalMoves"] 		= _topView.gameDataVO.allWordsArray.length;
		dataObject["duration"] 			= _topView.DURATION;
		dataObject["score"] 			= _topView.SCORE;
		
		//trace("DataSendController() - _topView.userVO.password : " + _topView.userVO.password);
				
		jsonString = JSON.stringify(dataObject);
		var url:String = Constants.PHP_SEND;
		var urlLoad:UrlLoad = new UrlLoad(jsonString, url, callbackHandler, faultbackHandler);
	}
	
	private function callbackHandler(str:String):void
	{
		//trace("DATA SEND SUCCEEDED - callback : " + str);
		
		dataSent.dispatch(true);
	}
	
	private function faultbackHandler(str:String):void
	{
		trace("DATA SEND FAILED - faultback : " + str);
		
		//Save results data to table as a JSON string
		var queryType:int = 1;
		var service:DataService = new DataService();		
		var stmtText:String = "INSERT INTO "+Constants.RESULTS_STORAGE+" (Result)VALUES ('"+jsonString+"');";
		service.userTableUpdatedSignal.addOnce(localResultsTableUpdated);
		service.queryDatabase(stmtText, queryType);	
	}
	
	private function localResultsTableUpdated():void
	{
		trace("DataSendController.localResultsTableUpdated()");
		
		dataSent.dispatch(false);
	}
}	
}