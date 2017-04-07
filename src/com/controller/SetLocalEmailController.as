package com.controller
{
import com.Constants;
import com.model.DataService;

import flash.events.IOErrorEvent;

import org.osflash.signals.DeluxeSignal;

public class SetLocalEmailController
{
	public var localEmailUpdatedSignal:DeluxeSignal = new DeluxeSignal();
	
	public function SetLocalEmailController()
	{		
	}
	
	
	public function getCurrentEmailAddress()
	{		
		trace("SetLocalEmailController.getCurrentEmailAddress()");
		
		//now get local data to compare
		var queryType:int = 0;
		var service:DataService = new DataService();		
		var stmtText:String = "SELECT * FROM "+Constants.CURRENT_EMAIL+" ORDER BY Id DESC LIMIT 1;";
		service.userDataReturnedSignal.addOnce(emailDataReturned);
		service.queryDatabase(stmtText, queryType);		
	}
	
	private function emailDataReturned(dataObj:Object):void
	{
		trace("SetLocalEmailController.emailDataReturned() - emailData : " + dataObj);
		
		//parse data for stored epoch time... and passcode
		for each(var row:Object in dataObj.data)
		{			
			var currentEmail:String="";
			if(row.Email != null)
				currentEmail = row.Email;
		}	
		
		trace("SetLocalEmailController.serverDataReturned() - currentEmail: " + currentEmail);		
		
		localEmailUpdatedSignal.dispatch(currentEmail);
	}	
	
	//TODO: Program what to do in case of error - return to main menu
	
	private function request_ioFault(e:IOErrorEvent):void
	{
		trace("Data request failure! : " + e.target.data);
		
		//localEmailUpdatedSignal.dispatch("dataerror", null, null);		
	}
	
}
}