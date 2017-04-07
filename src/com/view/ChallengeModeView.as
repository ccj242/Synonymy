package com.view
{
	
import com.Constants;
import com.clipboard.ClipboardUtility;
import com.controller.EmailUpdateController;
import com.greensock.TweenLite;
import com.model.DataService;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

import org.osflash.signals.DeluxeSignal;
import org.osflash.signals.Signal;


public class ChallengeModeView extends Sprite
{	
	private var charsArray:Array = ["0","1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", 
		"H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
		
	private var bg:Sprite;	
	private var lettersArray:Array=[];
	private var sprite:ChallengeModeSprite;
	private var container:Sprite;
	private var dropList:DropListMC;
	private var _topView:Object;
	private var inputText:TextField;	
	private var password:String;
	
	
	private var weeklyDifficultyNumber:int;
	
	//private var avenirNextFont:AvenirNext;
	
	private var clipboard:ClipboardUtility;
	
	//private var concatString:String="";
	
	public var textInputCompleteSignal:DeluxeSignal = new DeluxeSignal();
	public var textInputAbortSignal:Signal = new Signal();
	
	public function ChallengeModeView(commentNum:int, topView:Object=null)
	{		
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		if(topView)
			_topView = topView;		
		
		// soft keyboard
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;		
		
		//
		password = _topView.userVO.password
		
		trace("TextInputView() - password : " + password);
		
		sprite = new ChallengeModeSprite();
		this.addChild(sprite);
		
		MovieClip(sprite["infoText"]).gotoAndStop(commentNum+1);
		
		//add text field
		
		var myFont:Font = new AvenirNextUltraLight();
		
		var inputFormat:TextFormat = new TextFormat();
		inputFormat.align = TextFormatAlign.CENTER;
		inputFormat.font = myFont.fontName;
		inputFormat.size = 300;
		
		inputText = new TextField();
		inputText.needsSoftKeyboard = true;
		inputText.type = TextFieldType.INPUT;
		inputText.restrict = "A-Z0-9";
		inputText.maxChars = 5;
		inputText.defaultTextFormat = inputFormat;
		inputText.embedFonts = true;
		//inputText.border = true;
		//inputText.background = true;
		inputText.x = 255;
		inputText.y = 200;
		inputText.width = 1410;
		inputText.height = 360;
		inputText.addEventListener(FocusEvent.FOCUS_IN, inputTextFocusEvent);
		inputText.addEventListener(FocusEvent.FOCUS_OUT, inputTextLoseFocusEvent);		
		
		inputText.text = password;
		this.addChild(inputText);
		
		inputText.textColor = Constants.DIFFICULTY_COLOR_ARRAY[_topView.userVO.difficultyNum];
		
		addEventHandlers();
	}
	
	private function inputTextFocusEvent(e:FocusEvent):void
	{
		trace("INPUT TEXT FOCUS EVENT");
		_topView.keyboardForTextField = true;
	}
	
	private function inputTextLoseFocusEvent(e:FocusEvent):void
	{
		trace("LOSE FOCUS EVENT");
		_topView.keyboardForTextField = false;
	}
	
	private function addEventHandlers():void
	{
		for(var i:int = 0; i<3; i++)
		{
			if(i==0)
				MovieClip(sprite["btn"+i]).width *= _topView.SCREEN_RATIO_FACTOR;
			
			MovieClip(sprite["btn"+i]).addEventListener(MouseEvent.CLICK, btnClickEventHandler);				
		}
		
		sprite.hotspot.addEventListener(MouseEvent.CLICK, returnToMenu);
	}
	
	private function btnClickEventHandler(e:MouseEvent):void
	{
		//trace(e.target.name as String);
		
		switch(e.target.name as String)
		{
			case "btn0":
			{
				// closes this view
				//starts new game				
				TweenLite.to(this, 0.5, {alpha:0, onComplete:onFadeOutComplete});
				break;
			}
			case "btn1":
			{
				if(!dropList)
				{
					dropList = new DropListMC;
					sprite.addChild(dropList);
					MovieClip(dropList).gotoAndStop(2);
					sprite.addChild(sprite["btn1"]);
					MovieClip(dropList["transClip"]).addEventListener(MouseEvent.CLICK, closeDropList);
					dropList.x = 340;
					TweenLite.to(dropList, 0.35, {x:0});
					
					addDropListEventHandlers();
				}
				else
				{
					TweenLite.to(dropList, 0.35, {x:340, onComplete:removeDropList});
				}
				break;
			}
			case "btn2":
			{
				// jumpToMore1 is called from a button in text at bottom of view
				//trace("GO TO MORE 1 VIEW _topView : " + _topView);	
									
				textInputCompleteSignal.dispatch( null, "jumpToMore1" );
				
				break;
			}
			default:
			{
				break;
			}
		}	
	}
	
	private function returnToMenu(e:MouseEvent):void
	{
		textInputAbortSignal.dispatch();
	}
	
	private function onFadeOutComplete():void
	{		
		textInputCompleteSignal.dispatch( inputText.text, null, weeklyDifficultyNumber);
	}	
	
	private function addDropListEventHandlers():void
	{
		if(dropList)
		{
			for(var i:int=0; i<3; i++)
			{
				MovieClip(dropList["bt"+i]).width *= _topView.SCREEN_RATIO_FACTOR;
				MovieClip(dropList["bt"+i]).addEventListener(MouseEvent.CLICK, dropListButtonHandler);
			}
		}
	}
	
	private function dropListButtonHandler(e:MouseEvent):void
	{
		switch(e.target.name)
		{
			case "bt0":
			{
				//hide text so it doesn't bleed through
				inputText.visible = false;
				MovieClip(sprite["infoText"]).visible = false;
				dropList["emailMC"]["closeBtn"].addEventListener(MouseEvent.CLICK, closeDropList);
				
				dropList["emailMC"]["txtEmail"].addEventListener(FocusEvent.FOCUS_IN, inputTextFocusEvent);
				dropList["emailMC"]["txtEmail"].addEventListener(FocusEvent.FOCUS_OUT, inputTextLoseFocusEvent);
				
				if(_topView.userVO.currentEmail && _topView.userVO.currentEmail.length > 0)
				{
					dropList["emailMC"]["txtEmail"].text = _topView.userVO.currentEmail;
					//trace("ChallengeModeView() - email : " + _topView.userVO.currentEmail);
				}				
				dropList.addChild(dropList["emailMC"]);
				dropList["emailMC"].y = 250;				
				
				break;
			}
			case "bt1":
			{
				// copy to clipboard
				clipboard = new ClipboardUtility();
				clipboard.copyText( inputText.text );
				
				break;
			}
			case "bt2":
			{				
				getWeeklyChallengeData();
				
				break;
			}
			default:
			{
				break
			}
		}
	}
	
	private function closeDropList(e:MouseEvent):void
	{
		//trace("ChallengeModeView.closeDropList()!!");
		
		dropList["emailMC"]["txtEmail"].removeEventListener(FocusEvent.FOCUS_IN, inputTextFocusEvent);
		dropList["emailMC"]["txtEmail"].removeEventListener(FocusEvent.FOCUS_OUT, inputTextLoseFocusEvent);
		dropList["emailMC"]["closeBtn"].removeEventListener(MouseEvent.CLICK, closeDropList);
		
		updateEmail();
		
		TweenLite.to(dropList, 0.35, {x:340, onComplete:removeDropList});
		MovieClip(dropList["transClip"]).removeEventListener(MouseEvent.CLICK, closeDropList);		
	}
	
	private function removeDropList():void
	{
		inputText.visible = true;
		MovieClip(sprite["infoText"]).visible = true;
		
		if(!sprite || !dropList)
			return;
		
		dropList["emailMC"]["txtEmail"].removeEventListener(FocusEvent.FOCUS_IN, inputTextFocusEvent);
		dropList["emailMC"]["txtEmail"].removeEventListener(FocusEvent.FOCUS_OUT, inputTextLoseFocusEvent);
		dropList["emailMC"]["closeBtn"].removeEventListener(MouseEvent.CLICK, closeDropList);
		
		for(var i:int=0; i<2; i++)			
		{
			MovieClip(dropList["bt"+i]).removeEventListener(MouseEvent.CLICK, dropListButtonHandler);
		}
		MovieClip(dropList["transClip"]).removeEventListener(MouseEvent.CLICK, closeDropList);
		
		sprite.removeChild(dropList);
		dropList = null;
	}
	
	private function updateEmail():void
	{
		var email:String = dropList["emailMC"]["txtEmail"].text;
		
		//trace("ChallengeModeView.updateEmail() - email : " + email);
		
		var emailUpdate:EmailUpdateController = new EmailUpdateController();
		emailUpdate.emailAddressUpdated.add(emailUpdateHandler);
		emailUpdate.updateEmail(email);
	}
	
	private function emailUpdateHandler(result:String):void
	{
		trace("ChallengeModeView.emailUpdateHandler() - result : " + result);
		
		if(result != "error")
			_topView.userVO.currentEmail = result;
	}
	
	private function getWeeklyChallengeData():void
	{
		//now get local data to compare
		var queryType:int = 0;
		var service:DataService = new DataService();		
		var stmtText:String = "SELECT * FROM "+Constants.WEEKLY_CHALLENGE_TABLE+" ORDER BY Id DESC LIMIT 1;";
		service.userDataReturnedSignal.addOnce(localDataReturned);
		service.queryDatabase(stmtText, queryType);
	}
		
	private function localDataReturned(dataObj:Object):void
	{
		//trace("ChallengeModeView.localDataReturned() - data : " + dataObj);
		
		//parse data for stored epoch time... and passcode
		for each(var row:Object in dataObj.data)
		{			
			var challengeCode:String="";
			if(row.Passcode != null)
				challengeCode = row.Passcode;
			
			var difficulty:String="";
			if(row.Difficulty != null)
				difficulty = row.Difficulty;
		}
		
		//trace("ChallengeModeView.localDataReturned() - challengeCode : " + challengeCode);
		//trace("ChallengeModeView.localDataReturned() - difficulty : " + difficulty);
		
		if(challengeCode.length)
		{
			inputText.text = challengeCode;
			//trace("ChallengeModeView.localDataReturned() - challengeCode : " + challengeCode);
		}
		
		if(difficulty.length)
		{
			weeklyDifficultyNumber = getDifficultyNumber(difficulty);
			
			inputText.textColor = Constants.DIFFICULTY_COLOR_ARRAY[weeklyDifficultyNumber];
			
			trace("ChallengeModeView.localDataReturned() - weeklyDifficultyNumber : " + weeklyDifficultyNumber);
		}
		removeDropList();
	}
	
	private function getDifficultyNumber(difficulty:String):int
	{
		for(var i:int=0; i<Constants.DIFFICULTY_ARRAY.length; i++)
		{
			if(Constants.DIFFICULTY_ARRAY[i] == difficulty)
				return i;
		}		
		return NaN;
	}
	
	private function destroyThis(e:Event):void
	{
		removeDropList();
		
		_topView.keyboardForTextField = false;
		inputText.removeEventListener(FocusEvent.FOCUS_IN, inputTextFocusEvent);
		inputText.removeEventListener(FocusEvent.FOCUS_OUT, inputTextLoseFocusEvent);
		
		//RETURN TO SWIPE FUNCTIONALITY
		Multitouch.inputMode = MultitouchInputMode.GESTURE;
		
		for(var i:int = 0; i<3; i++)
		{
			MovieClip(sprite.getChildByName("btn"+i)).removeEventListener(MouseEvent.CLICK, btnClickEventHandler);				
		}
		sprite.hotspot.removeEventListener(MouseEvent.CLICK, returnToMenu);
		
		while(this.numChildren > 0)
		{
			this.removeChildAt(0);
		}
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
	}	
}
}