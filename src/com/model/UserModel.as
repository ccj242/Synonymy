package com.model
{
	
import com.Constants;

import org.osflash.signals.Signal;

public class UserModel
{	
	public var service:DataService;	
	private var queryType:int // 0 = query returning data, 1 = update table
	private var _topView:Object;
	
	public var setUserVariablesCompleteSignal:Signal = new Signal();
	
	public function UserModel(topView:Object)
	{
		//trace("--UserModel()");
		
		_topView = topView;
		service = new DataService();
	}	
	
	//this is only called once to copy db to write folder
	public function setUpDatabase():void
	{		
		service.setupDatabase();
	}
	
	public function queryUserTable():void
	{
		queryType = 0;
		var stmtText:String = "SELECT * FROM "+Constants.USERS_TABLE+" ORDER BY Id DESC LIMIT 1;";
		service.userDataReturnedSignal.addOnce(userVariablesReturned);
		service.queryDatabase(stmtText, queryType);
	}
	
	private function userVariablesReturned(dataObj:Object):void
	{
		trace("UserModel.setUserVariables() - dataObj.data : " + dataObj.data);
		
		for each(var row:Object in dataObj.data)
		{
			trace("row.Music : " + row.Music);
		
			_topView.userVO.difficultyNum = int(row.Difficulty);
			_topView.userVO.audioStatus = int(row.Music);
			
			var user:String="";
			if(row.UserName != null)
				user = row.UserName;
			
			var pw:String="";
			if(row.Password != null)
				pw = row.Password;
			
			_topView.userVO.userName = user;
			_topView.userVO.password = pw;
			_topView.userVO.challengeMode = int(row.ChallengeMode);
		}
		
		//query Color Table
		
		queryType = 0;
		var stmtText:String = "SELECT * FROM "+Constants.COLOR_TABLE+";";
		service.userDataReturnedSignal.addOnce(colorsDataReturned);
		service.queryDatabase(stmtText, queryType);
	}
	
	public function updateUserTable():void
	{
		//trace("UserModel.updateUserTable()");
		
		queryType = 1;
		
		if(!_topView.userVO.userName)
		{
			_topView.userVO.userName = "AAA";
		}		
		
		var stmtText:String = "INSERT INTO "+Constants.USERS_TABLE+" (Difficulty, Music, UserName, Password, ChallengeMode)VALUES ("
			+_topView.userVO.difficultyNum+","+_topView.userVO.audioStatus+",'"+_topView.userVO.userName+"','"
			+_topView.userVO.password+"',"+_topView.userVO.challengeMode+");";
		
		service.queryDatabase(stmtText, queryType);
		service.userTableUpdatedSignal.add(userTableUpdated);
	}
	
	private function userTableUpdated():void
	{
		trace("USER TABLE UPDATED :: ");
		
		/*trace("		DIFFICULTY_NUM : " + _topView.userVO.difficultyNum);
		trace("		MUSIC_ON : " + _topView.userVO.audioStatus);
		trace("		USER_NAME : " + _topView.userVO.userName);
		trace("		PASSWORD : " + _topView.userVO.password);
		trace("		CHALLENGE_MODE : " + _topView.userVO.challengeMode);*/
	}
	
	private function colorsDataReturned(dataObj:Object):void
	{
		var arr1:Array=[];
		for each(var row:Object in dataObj.data)
		{
			var arr2:Array=[];
			for each(var item:String in row)
			{				
				arr2.push(item);
			}
			arr2.sort(randomSort);
			arr1.push(arr2);
		}
		
		arr1.sort(randomSort);
		_topView.userVO.colorsArray = arr1;
		
		//trace("_topView.userVO.colorsArray[4][0] : " + _topView.userVO.colorsArray[4][0]);
		
		setUserVariablesCompleteSignal.dispatch();
	}
	
	public function randomiseColorsArray():void
	{
		var arr:Array = _topView.userVO.colorsArray;
		_topView.userVO.colorsArray = arr.sort(randomSort);
		
	}
	
	private function randomSort(a:*, b:*):Number
	{
		if (Math.random() < 0.5) return -1;
		else return 1;
	}
	
}//
}//