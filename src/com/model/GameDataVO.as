package com.model
{
	

public class GameDataVO
{
	private var _endWord:String="";
	private var _endWordDefn:String="";
	private var _endWordSyllables:String="";
	private var _endWordVector:String="";	
	
	private var _currentWord:String="";
	private var _currentWordVector:String="";
	private var _currentWordSize:int=-1;
	
	private var _previousWord:String="";	
	private var _previousWordVector:String="";
	private var _previousWordSize:int=-1;
	
	private var _endWordSynsArray:Array=[];
	private var _synonymsArray:Array=[];
	private var _allWordsArray:Array=[];
	
	private var _endWordIsSynonym:Boolean;
	private var _gameIsWon:Boolean;
	
	private var _previousX:Number=50;
	
	
		
	
	public function GameDataVO()
	{
	}
	
		
	public function set endWord(str:String):void
	{
		_endWord = str;
	}
	
	public function get endWord():String
	{
		return _endWord;
	}
	
	public function set endWordDefn(str:String):void
	{
		_endWordDefn = str;
	}
	
	public function get endWordDefn():String
	{
		return _endWordDefn;
	}
	
	public function set endWordSyllables(str:String):void
	{
		_endWordSyllables = str;
	}
	
	public function get endWordSyllables():String
	{
		return _endWordSyllables;
	}
	
	public function set endWordVector(str:String):void
	{
		_endWordVector = str;
	}
	
	public function get endWordVector():String
	{
		return _endWordVector;
	}		
		
	public function set currentWord(str:String):void
	{
		_currentWord = str;
	}
	
	public function get currentWord():String
	{
		return _currentWord;
	}
	
	public function set currentWordVector(str:String):void
	{
		_currentWordVector = str;
	}
	
	public function get currentWordVector():String
	{
		return _currentWordVector;
	}
	
	// only used to hold size value to be passed to previousWordSize 
	public function set currentWordSize(num:int):void  
	{
		_currentWordSize = num;
	}
	
	public function get currentWordSize():int
	{
		return _currentWordSize;
	}	
	
	// previous values are unshifted onto synonymsArray
	public function set previousWord(str:String):void
	{
		_previousWord = str;
	}
	
	public function get previousWord():String
	{
		return _previousWord;
	}
	
	public function set previousWordVector(str:String):void
	{
		_previousWordVector = str;
	}
	
	public function get previousWordVector():String
	{
		return _previousWordVector;
	}
	
	public function set previousWordSize(num:int):void
	{
		_previousWordSize = num;
	}
	
	public function get previousWordSize():int
	{
		return _previousWordSize;
	}	
	
	public function set endWordSynsArray(array:Array):void
	{
		_endWordSynsArray = array;
	}
	
	public function get endWordSynsArray():Array
	{
		return _endWordSynsArray;
	}
	
	public function set synonymsArray(array:Array):void
	{
		_synonymsArray = array;
	}
	
	public function get synonymsArray():Array
	{
		return _synonymsArray;
	}
	
	public function set allWordsArray(arr:Array):void
	{
		_allWordsArray = arr;
	}
	
	public function get allWordsArray():Array
	{
		return _allWordsArray;
	}
	
	public function set endWordIsSynonym(bool:Boolean):void
	{
		_endWordIsSynonym = bool;
	}
	
	public function get endWordIsSynonym():Boolean
	{
		return _endWordIsSynonym;
	}
	
	public function set gameIsWon(bool:Boolean):void
	{
		_gameIsWon = bool;
	}
	
	public function get gameIsWon():Boolean
	{
		return _gameIsWon;
	}
	
	
	// getting and setting from SFX Controller
	public function set previousX(num:Number):void
	{
		_previousX = num;
	}
	
	public function get previousX():Number
	{
		return _previousX;
	}
	
}
}