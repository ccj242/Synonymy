package com.controller
{	
	import com.Constants;
	import com.model.DataService;
	import com.signals.ErrorSignal;
	
	import org.osflash.signals.DeluxeSignal;
	
	
	/**
	 * This handles updating the GameDataVO
	 */

public class GameDataController
{
	private var _topView:Object;
	private var service:DataService = new DataService();
	private var synonymsArray:Array = new Array;
	
	private var isNewKeyword:Boolean;
	
	public var errorSignal:ErrorSignal = new ErrorSignal;
	public var gameDataVoCreatedSignal:DeluxeSignal = new DeluxeSignal();
		
	public function GameDataController(topView:Object)
	{		
		_topView = topView;
		_topView.gameNextWordSignal.add(getWordData);
	}
	
	/**
	 * This code block executed by NewGameController 
	*/
	
	public function createNewGameDataVO(startWd:String, endWd:String, startWdVector:String, endWdVector:String, endWdSynsArr:Array):void
	{
		//trace("GameDataController.createNewGameDataVO() - startWd : " + startWd);
		//trace("GameDataController.createNewGameDataVO() - endWd : " + endWd);
				
		_topView.gameDataVO.currentWord = startWd;
		_topView.gameDataVO.endWord = endWd;
		_topView.gameDataVO.endWordVector = endWdVector;
		_topView.gameDataVO.endWordSynsArray = endWdSynsArr;
		
		if(!_topView.gameDataVO.endWordDefn.length)
		{			
			service.dataReturnedSignal.addOnce(definitionsQueryResult);
			service.queryDatabase("SELECT * FROM "+Constants.DEFINITIONS_TABLE+" WHERE KeyWord LIKE '"+endWd+"';");
		}
		else
		{
			gameDataVoCreatedSignal.dispatch();
		}
	}
	
	private function definitionsQueryResult(dataObj:Object)
	{
		var defString:String="";
		for each(var row:Object in dataObj.data)
		{		
			for each(var item:String in row)
			{				
				if(item != null && item != row.KeyWord && item != row.Syllab)
				{
					defString += item + " \n";
				}
				else if(item == row.Syllab)
				{
					_topView.gameDataVO.endWordSyllables = item;
				}
			}
		}		
		//trace("GameDataController.definitionsQueryResult() - gameDataVO.syllab : " + _topView.gameDataVO.endWordSyllables);
		
		_topView.gameDataVO.endWordDefn = defString;
		
		gameDataVoCreatedSignal.dispatch();
	}
	
	
	/**
	 * Executed by GameView 
	 */
	
	public function checkCurrentData():void
	{
		//trace("GameDataController.checkCurrentData()");
		
		getWordData();
	}
	
	
	private function getWordData(selectedWord:String=null):void
	{		
		trace("GAME DATA CONTROLLER	 - getWordData() - selectedWord : " + selectedWord);
		
		var keywd:String;
		if(selectedWord)
		{
			isNewKeyword = true;
			
			// update words
			_topView.gameDataVO.previousWord = _topView.gameDataVO.currentWord;
			_topView.gameDataVO.currentWord = selectedWord;
		}
		keywd = _topView.gameDataVO.currentWord;
		
		// update all words array
		if(keywd && _topView.gameDataVO.currentWord != _topView.gameDataVO.allWordsArray[_topView.gameDataVO.allWordsArray.length-1])
		{			
			_topView.gameDataVO.allWordsArray.push(keywd);
		}
				
		// game won
		if(_topView.gameDataVO.currentWord == _topView.gameDataVO.endWord)
		{
			_topView.gameDataVO.gameIsWon = true;
			
			var sfxController:SFXController = new SFXController(_topView);
			sfxController.specialEffectsControllerUpdated.add(gameVOUpdated);
			sfxController.calculateVectorDistance();
			
			//_topView.gameWonSignal.dispatch();
			return;	
		}		
		
		service.dataReturnedSignal.addOnce(onResultsReturned);
		service.queryDatabase("SELECT * FROM "+Constants.SYNONYMS_TABLE+" WHERE KeyWord LIKE '"+keywd+"';");
	}
	
	private function onResultsReturned(dataObj:Object):void
	{
		//trace("GAME_VIEW - onResultsReturned()");
		
		if(!dataObj)
		{
			errorSignal.dispatchNotice("Error: There is no data for the word you have selected");				
			return;
		}
		
		// build new synonymsArray
		var array:Array = [];		
		for each(var row:Object in dataObj.data)
		{			
			for each(var word:* in row)
			{
				//trace("		- word : " + word);
				
				if(word == null || word == row.KeyWord)
				{
					//trace("		- null or keyword : " + word);
				}
				else if(word == row.KeyWordVector)
				{
					if(isNewKeyword)
						_topView.gameDataVO.previousWordVector = _topView.gameDataVO.currentWordVector;
					
					_topView.gameDataVO.currentWordVector = row.KeyWordVector;
				}
				else if(word == row.Size)
				{
					if(isNewKeyword)
						_topView.gameDataVO.previousWordSize = _topView.gameDataVO.currentWordSize;
					
					_topView.gameDataVO.currentWordSize = int(row.Size);
				}				
				else
				{
					var arr:Array = word.split("$");
					
					array.push(arr);
				}
			}
		}
		
		// 1) randomize - no longer randomizing
		//synonymsArray = array.sortOn(0, randomOrder);
		synonymsArray = array;
		
		// 2) if any synonyms are also found in the synonyms of the end word array, move them to the beginning of the array 
		for(var k:int=0; k<synonymsArray.length; k++)
		{
			//trace("******	- index num : " + _topView.gameDataVO.endWordSynsArray.indexOf(synonymsArray[k][0]));
			
			if(_topView.gameDataVO.endWordSynsArray.indexOf(synonymsArray[k][0]) >= 0)
			{
				trace("	- SYNS WORD MATCH  : " + synonymsArray[k][0]);
				synonymsArray = relocateToStartOfArray(synonymsArray, k);
			}
		}
		trace("ENDWORD SYNS ARRAY??  : " + _topView.gameDataVO.endWordSynsArray);		
		
		// 3) if array contains gameDataVO.endWord, move it to beginning of array	
		//    set boolean if endWord is in Synonyms
		
		_topView.gameDataVO.endWordIsSynonym = false;
		for(var j:int=0; j<synonymsArray.length; j++)
		{
			if(synonymsArray[j][0] == _topView.gameDataVO.endWord)
			{
				_topView.gameDataVO.endWordIsSynonym = true;
				synonymsArray = relocateToStartOfArray(synonymsArray, j);
				break;
			}
		}		

		// 4) move previousWord to beginning of array if exists (i.e. not start of new game)
		
		if(_topView.gameDataVO.previousWord.length && _topView.gameDataVO.previousWord.length != synonymsArray[0][0])
		{
			synonymsArray.unshift([_topView.gameDataVO.previousWord, _topView.gameDataVO.previousWordVector, _topView.gameDataVO.previousWordSize]);
		}
		else
		{
			//trace("NEW GAME! - DONT UPDATE SYNONYMS ARRAY!!!!");
		}
		
		// 5) check for any duplicate synonyms and remove them
		
		_topView.gameDataVO.synonymsArray = removeDuplicates(synonymsArray);
		synonymsArray = null;
		
		
		//SOUND AND BLUR EFFECTS
		if(isNewKeyword)
		{
			var sfxController:SFXController = new SFXController(_topView);
			sfxController.specialEffectsControllerUpdated.add(gameVOUpdated);
			sfxController.calculateVectorDistance();
		}
		else
			_topView.gameDataUpdated.dispatch(null);
		
		isNewKeyword = false;
	}
	
	private function gameVOUpdated(nextBlur:int, pianoTrack:String):void
	{		
		//trace("		- _notification : " + _notification);
		//trace("		- pianoTrack : " + pianoTrack);
		
		/*trace("-----GameDataController - UPDATE GAME VO : ");
		trace("		- selectedWord : " + _topView.gameDataVO.currentWord);
		trace("		- previousWord : " + _topView.gameDataVO.previousWord);
		
		trace("		- currentWordVector : " + _topView.gameDataVO.currentWordVector);
		trace("		- previousWordVector : " + _topView.gameDataVO.previousWordVector);
		
		trace("		- currentWordSize : " + _topView.gameDataVO.currentWordSize);
		trace("		- previousWordSize : " + _topView.gameDataVO.previousWordSize);
		trace("		- allWordsArray : " + _topView.gameDataVO.allWordsArray.toString());
		
		trace("-------");*/
		
		_topView.soundFXPlayer.playSound(Constants.PIANO_SOUND, pianoTrack);
				
		if(_topView.gameDataVO.gameIsWon)
			_topView.gameWonSignal.dispatch(pianoTrack);
		else
			_topView.gameDataUpdated.dispatch(nextBlur);
	}
	
	
	private function randomOrder(a:*, b:*):Number
	{
		if (Math.random() < 0.5) return -1;
		else return 1;
	}
	
	private function removeDuplicates(arr:Array):Array
	{
		var i:int, j:int;
		for (i = 0; i < arr.length - 1; i++)
		{
			for (j = i + 1; j < arr.length; j++)
			{
				if (arr[i][0] === arr[j][0])
				{
					arr.splice(j,1);
				}
			}
		}
		return arr;
	}
	
	private function relocateToStartOfArray(array:Array, index:int):Array
	{
		var temp:String = String(array.splice(index, 1));
		var arr:Array = temp.split(",");
		array.unshift(arr);		
		return	array;
	}
	
}
}