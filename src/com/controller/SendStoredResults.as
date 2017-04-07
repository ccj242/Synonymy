package com.controller
{
	import com.Constants;
	import com.model.DataService;
	import com.model.UrlLoad;

public class SendStoredResults
{
	public function SendStoredResults()
	{
	}
	
	public function init():void
	{	
		var service:DataService = new DataService();
		service.dataReturnedSignal.addOnce(lastRowDataReturned);
		service.queryDatabase("SELECT * FROM "+Constants.RESULTS_STORAGE+" ORDER BY Id DESC LIMIT 1;");
	}
	
	private function lastRowDataReturned(dataObj:Object)
	{
		var resultString:String="";
		for each(var row:Object in dataObj.data)
		{
			trace("SendStoredResults.lastRowDataReturned() - row.Result : " + row.Result);
						
			resultString = row.Result;
		}
		
		if(!resultString.length)
		{
			trace("NO DATA LEFT IN RESULTS STORAGE TABLE!!!!");
			return;
		}
		
		var url:String = Constants.PHP_SEND;
		var urlLoad:UrlLoad = new UrlLoad(resultString, url, callbackHandler, faultbackHandler);
	}
	
	private function callbackHandler(str:String):void
	{
		trace("DATA SEND SUCCEEDED - callback : " + str);
		
		var service:DataService = new DataService();
		service.userTableUpdatedSignal.addOnce(lastRowDataDeleted);
		service.queryDatabase("DELETE FROM "+Constants.RESULTS_STORAGE+" WHERE ID = (SELECT MAX(ID) FROM "+Constants.RESULTS_STORAGE+");", 1);
	}
	
	private function faultbackHandler(str:String):void
	{
		trace("DATA SEND FAILED - faultback : " + str);
	}
	
	private function lastRowDataDeleted()
	{
		trace("DATA DELETED");
		
		init();
	}
}
}