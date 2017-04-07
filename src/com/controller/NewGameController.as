package com.controller
{
	import com.Constants;
	import com.model.DataService;
	import com.model.NewGameWordGenerator;
	import com.view.ChallengeModeView;
	
	import org.osflash.signals.Signal;

public class NewGameController
{
	private var service:DataService = new DataService();
	
	private var _topView:Object;
	private var challengeModeView:ChallengeModeView;
	private var _password:String;
	private var startwordCount:int;
	private var difficultyRowCount:int;
	private var difficulty:String;
	
	private var charsArray:Array = ["0","1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", 
		"H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];	
	
	
	public var onNewGameGeneratedSignal:Signal = new Signal();
	
	public function NewGameController(topView:Object, weeklyChallengeCode:String=null)
	{
		_topView = topView;
		
		//Get number of rows in startword and difficulty columns
		startwordCount = Constants.GOAL_DIFFICULTY_TABLE_COLUMN_LENGTHS_ARRAY[Constants.GOAL_DIFFICULTY_TABLE_COLUMN_LENGTHS_ARRAY.length-1];
		
		difficultyRowCount = Constants.GOAL_DIFFICULTY_TABLE_COLUMN_LENGTHS_ARRAY[_topView.userVO.difficultyNum];
		
		difficulty = Constants.DIFFICULTY_ARRAY[_topView.userVO.difficultyNum];
		
		trace("*** NewGameController() - startwordCount : "+startwordCount+" / difficultyRowCount : "+difficultyRowCount);

		
		if(weeklyChallengeCode)
		{
			_topView.userVO.challengeMode = true;
			_topView.userVO.password = weeklyChallengeCode;
			textInputComplete(_topView.userVO.password);
		}
		else
		{
			if(_topView.userVO.challengeMode)
			{
				autoGenerateNewPassword();
				showChallengeModeView();
			}
			else
			{
				autoGenerateNewPassword();
				generateNewWordsFromPassword(_topView.userVO.password);
			}
		}
	}

	private function autoGenerateNewPassword():void
	{		
		//ALGORITHM TO GENERATE BASE 10 PASSCODE ::
		
		var diffWdBias:Number = difficultyBias();
		var stWdBias:Number = startBias();
		
		trace("*** NewGameController() - diffWdBias : " + diffWdBias);
		trace("*** NewGameController() - stWdBias : " + stWdBias);
		
		var pw10: int = difficultyRowCount * Math.round(Math.round(Math.random()*difficultyRowCount)/(Math.random()/diffWdBias+1)) +
						Math.round(Math.round(Math.random()*startwordCount)/(Math.random()/stWdBias+1));
		
		var pw36:String = base36Encode(pw10, charsArray); 	//auto generate a 5 digit password (sent to server)
		
		//if zeros are left most digits
		if(pw36.length==1)
			pw36="0000"+pw36;
		else if(pw36.length==2)
			pw36 ="000"+pw36;
		else if(pw36.length==3)
			pw36="00"+pw36;
		else if(pw36.length==4)
			pw36="0"+pw36;
				
		trace("*** NewGameController() - auto-generated(pw10) : " + pw10);
		trace("*** NewGameController() - which is encoded to password(pw36) : " + pw36);
		
		_topView.userVO.password = pw36;		
	}
	
	private function difficultyBias():Number
	{
		switch(_topView.userVO.difficultyNum)
		{			
			case 1: //easy
				return 3;
				break;
			case 2: //medium
				return 5;
				break;
			case 3: //hard
				return 8;
				break;
			case 4: //hardest
				return 100;
				break;
			case 0: //easiest
			default:
				return 2;
				break;
		}
	}
	
	private function startBias():Number
	{		
		switch(_topView.userVO.difficultyNum)
		{			
			case 1: //easy
				return 2;
				break;
			case 2: //medium
				return 4;
				break;
			case 3: //hard
				return 7;
				break;
			case 4: //hardest
				return 100;
				break;
			case 0: //easiest
			default:
				return 1;
				break;
		}
	}
				
	private function showChallengeModeView():void
	{		
		challengeModeView = new ChallengeModeView(1, _topView);
		challengeModeView.textInputAbortSignal.addOnce(returnToMenuView);
		challengeModeView.textInputCompleteSignal.addOnce(textInputComplete);
		
		_topView.addChild(challengeModeView);
		
		_topView.preventSwipe = true;
		_topView.blurContainer();
	}
	
	private function returnToMenuView():void
	{
		if(challengeModeView)
		{
			_topView.removeChild(challengeModeView);
			challengeModeView = null;
		}
		
		trace("NewGameController.returnToMenuView() - PREVENT SWIPE CHANGED TO FALSE ");
		_topView.preventSwipe = false;
		_topView.unBlurContainer();
	}
	
	private function textInputComplete(passcode:String, option:String=null, difficultyNum:int=NaN):void
	{
		trace("NewGameController.textInputComplete() - passcode : " + passcode);
		
		if(challengeModeView)
		{
			_topView.removeChild(challengeModeView);
			challengeModeView = null;
		}
		_topView.unBlurContainer();
		
		if(option)
		{		
			if(option == "jumpToMore1")
			{
				_topView.showNewViewSignal.dispatch(Constants.MORE1_VIEW, Constants.SWIPE_UP);	
				return;
			}
		}
		
		_topView.userVO.password = passcode;
		
		if(difficultyNum)
			_topView.userVO.difficultyNum = difficultyNum;
		
		generateNewWordsFromPassword(_topView.userVO.password);
	}	
	
	private function generateNewWordsFromPassword(passCode:String):void
	{
		var wordGenerator:NewGameWordGenerator = new NewGameWordGenerator(
															Constants.DIFFICULTY_ARRAY[_topView.userVO.difficultyNum], 
															passCode, 
															startwordCount,
															difficultyRowCount);
		
		wordGenerator.newGameWordsGeneratedSignal.addOnce(onWordsGenerated);
	}	
	
	private function onWordsGenerated(startWd:String, endWd:String, password:String, startWdVector:String, endWdVector:String, endWdSynsArr:Array)
	{
		trace("NewGameController.onWordsGenerated() - startWd : " + startWd + " / endWd : " + endWd + " / password : " + password + 
				" / startWdVector : " + startWdVector + " / endWdVector : " + endWdVector);
		
		trace("NewGameController.onWordsGenerated() - endWdSynsArr : " + endWdSynsArr);
		
		_password = password;
		
		var gameDataController:GameDataController = new GameDataController(_topView);
		gameDataController.gameDataVoCreatedSignal.add(gameDataUpdated);
		gameDataController.createNewGameDataVO(startWd, endWd, startWdVector, endWdVector, endWdSynsArr);
	}
	
	private function gameDataUpdated():void
	{
		//trace("NewGameController.gameDataUpdated()");

		if(!_topView.userVO.challengeMode)
			_topView.userVO.password = _password;
		
		// update user table with new PASSWORD
		_topView.userModel.service.userTableUpdatedSignal.addOnce(onUserTableUpdated);
		_topView.userModel.updateUserTable();
	}
	
	private function onUserTableUpdated():void
	{		
		onNewGameGeneratedSignal.dispatch();
	}
	
	
	// int --> hexatridecimal
	private function base36Encode(value:int, arr:Array)
	{
		var result:String = "";
		var targetBase:int = arr.length;
		
		do
		{
			result = arr[value % targetBase] + result;
			value = value / targetBase;
		} 
		while (value > 0);
		
		return result;
	}
}
}