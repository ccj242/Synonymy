package com.controller
{

import com.Constants;
import com.model.DataService;

import flash.events.IOErrorEvent;
import flash.net.URLLoader;

import org.osflash.signals.DeluxeSignal;
	
	
/**
 * 
 * Controller handles the update of sqlite database email table
 */


public class EmailUpdateController
{
	private var service:DataService;
	private var queryType:int // 0 = query returning data, 1 = update table
	private var loader:URLLoader;
	private var validChallengeCode;
	private var validEpoch;
	private var _newEmailAddress:String;
	
	public var emailAddressUpdated:DeluxeSignal = new DeluxeSignal();
	
	public function EmailUpdateController()
	{
		//trace("EmailUpdateController()");
	}
	
	public function updateEmail(newEmailAddress:String):void
	{		
		if(!isValidEmail(newEmailAddress))
		{
			trace("EmailUpdateController.updateEmail() - NOT A VALID EMAIL ADDRESS : " + newEmailAddress);
			
			emailAddressUpdated.dispatch("error");
			return;
		}
		else
		{
			_newEmailAddress = newEmailAddress;
			updateEmailTable(newEmailAddress);
		}
	}
	
	private function isValidEmail(email:String):Boolean {
		var emailExpression:RegExp = /([a-z0-9._-]+?)@([a-z0-9.-]+)\.([a-z]{2,4})/;
		return emailExpression.test(email);
	}
	
	private function updateEmailTable(validEmailAddress:String):void
	{
		//trace("EmailUpdateController.updateEmailTable()");
		
		//upate sqlite database with new data
		queryType = 1;
		service = new DataService();		
		var stmtText:String = "INSERT INTO "+Constants.CURRENT_EMAIL+" (Email)VALUES ('"+validEmailAddress+"');";
		service.userTableUpdatedSignal.addOnce(emailTableUpdated);
		service.queryDatabase(stmtText, queryType);
	}
	
	private function emailTableUpdated():void
	{
		trace("EmailUpdateController.emailTableUpdated() - EMAIL TABLE SUCCESSFULLY UPDATED");
		emailAddressUpdated.dispatch(_newEmailAddress);
	}
	
	//TODO: Program what to do in case of error - return to main menu
	
	private function request_ioFault(e:IOErrorEvent):void
	{
		trace("EmailUpdateController.request_ioFault() - Failure to update email table! : " + e.target.data);		
		emailAddressUpdated.dispatch("error");
	}
}	
}