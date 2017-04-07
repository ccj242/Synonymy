package com.model
{
	

public class UserVO
{
	private var _userName:String;
	private var _password:String;
	
	private var _colorsArray:Array;
	
	private var _difficultyNum:int;
	private var _challengeMode:int;		// 0 (false) or 1 (true)
	private var _audioStatus:int; 		// 1 (on) or 0 (off)
	
	private var _currentEmail:String;
	
	
	public function UserVO()
	{
	}
		
	public function set userName(str:String):void
	{
		_userName = str;
	}
	
	public function get userName():String
	{
		return _userName;
	}
	
	public function set password(str:String):void
	{		
		_password = str;
	}
	
	public function get password():String
	{
		return _password;
	}
	
	public function set colorsArray(arr:Array):void
	{
		_colorsArray = arr;
	}
	
	public function get colorsArray():Array
	{
		return _colorsArray;
	}
	
	public function set difficultyNum(num:int):void
	{
		_difficultyNum = num;
	}
	
	public function get difficultyNum():int
	{
		return _difficultyNum;
	}
	
	public function set challengeMode(num:int):void
	{
		_challengeMode = num;
	}
	
	public function get challengeMode():int
	{
		return _challengeMode;
	}
	
	public function set audioStatus(num:int):void
	{		
		_audioStatus = num;
	}
	
	public function get audioStatus():int
	{
		return _audioStatus;
	}
	
	public function set currentEmail(str:String):void
	{
		_currentEmail = str;	
	}
	
	public function get currentEmail():String
	{
		return _currentEmail;
	}
}
}