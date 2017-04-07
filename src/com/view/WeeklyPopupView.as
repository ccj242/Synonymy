package com.view
{
import com.Constants;
import com.controller.EmailUpdateController;
import com.controller.NewGameController;
import com.greensock.TweenLite;
import com.scroller.TouchScroller;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.Capabilities;
import flash.text.TextFieldAutoSize;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

import org.osflash.signals.DeluxeSignal;

public class WeeklyPopupView extends MovieClip
{	
	//private var _DefinitionMC:Class;	
	//private var _defVO:Object;
	private var _topView:MovieClip;
	
	private var container:MovieClip;
	private var mc:PopupMC;
	
	private var urlRequestMade:Boolean;
	
	private var _weeklyChallengeCode:String;
	private var _expiryDate:Date;
	private var _difficultyLevel:String;
	
	public var proceedWithWeeklyChallengeSignal:DeluxeSignal = new DeluxeSignal();
		
	public function WeeklyPopupView(topView:MovieClip, weeklyChallengeCode:String, difficultyLevel:String, expiryEpochTime:int)
	{
		trace("-- WeeklyPopupView() - topView : " + topView +" / weeklyChallengeCode : " + weeklyChallengeCode +" / expiryEpochTime : " + expiryEpochTime);
		trace("-- WeeklyPopupView() - difficultyLevel : " + difficultyLevel);

		_topView = topView;
		_difficultyLevel = difficultyLevel;
		_weeklyChallengeCode = weeklyChallengeCode;
		_expiryDate = new Date(expiryEpochTime*1000);
		
		_topView.weeklyPopupVisible = true;
				
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event):void
	{		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		// soft keyboard
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		
		container = new MovieClip;
		this.addChild(container);
		
		mc = new PopupMC();
		container.addChild(mc);
		
		if(_topView.AD_VERSION)
		{
			if(_difficultyLevel == Constants.DIFFICULTY_ARRAY[0])
			{
				displayChallengeCodeFrame();
			}
			else
			{
				displayNotAvailalbeFrame(); //if AD_VERSION and weekly challenge is not EASIEST
			}
		}
		else
		{
			displayChallengeCodeFrame();
		}
	}
	
	private function displayChallengeCodeFrame():void
	{		
		mc.txtChallengeCode.text = _weeklyChallengeCode;		
		
		mc.txtChallengeCode.textColor = getDifficultyColour();
		
		mc.txtExpiry.text = "this contest ends on " +  _expiryDate.toString();		
		
		if(_topView.userVO.currentEmail && _topView.userVO.currentEmail.length > 0)
			mc.txtEmail.text = _topView.userVO.currentEmail;
		
		mc.txtEmail.addEventListener(FocusEvent.FOCUS_IN, inputTextFocusEvent);
		mc.txtEmail.addEventListener(FocusEvent.FOCUS_OUT, inputTextLoseFocusEvent);
		
		addButtonEvents();
		
		_topView.viewLoadedSignal.dispatch(this);
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
	
	private function addButtonEvents():void
	{
		for(var i:int = 0; i<3; i++)
		{
			MovieClip(mc["btn"+i]).width *= _topView.SCREEN_RATIO_FACTOR;
			
			MovieClip(mc["btn"+i]).addEventListener(MouseEvent.CLICK, btnClickEventHandler);				
		}		
	}
	
	private function btnClickEventHandler(e:MouseEvent):void
	{
		if(mc.txtEmail.text != _topView.userVO.currentEmail)
		{
			var emailUpdate:EmailUpdateController = new EmailUpdateController();
			emailUpdate.emailAddressUpdated.add(emailUpdateHandler);
			emailUpdate.updateEmail(mc.txtEmail.text);
		}
		else
		{
			trace("EMAIL IS THE SAME SO DON'T UPDATE");
		}
		
		switch(e.target.name as String)
		{
			case "btn0":
			{			
				trace("WeeklyPopupView.btnClickEventHandler() - Return to main menu");
				_topView.removeChild(this);
				break;
			}
			case "btn1":
			{
				trace("WeeklyPopupView.btnClickEventHandler() - Start New Game");
				_topView.removeChild(this);
				proceedWithWeeklyChallengeSignal.dispatch(_weeklyChallengeCode, getDifficultyNumber());
				break;
			}
			case "btn2":
			{
				trace("WeeklyPopupView.btnClickEventHandler() - Get Challenge Rules");
				navigateToURL(new URLRequest("http://www.synonymy-game.com/synonymchallenges.html"),"_blank");
				break;
			}
			default:
			{
				break;
			}
		}
	}
	
	private function emailUpdateHandler(result:String):void
	{
		trace("WeeklyPopupView.emailUpdateHandler() - result : " + result);
		
		if(result != "error")
			_topView.userVO.currentEmail = result;
	}
	
	
	//public static const DIFFICULTY_ARRAY:Array=["EASIEST", "EASY","MEDIUM","HARD","HARDEST"];
	//public static const DIFFICULTY_COLOR_ARRAY = [0x009966,0x996600,0xCCCC33,0xCC0099,0xCC3300];
	private function getDifficultyColour():uint
	{
		var colour:uint;
		
		for(var i:int=0; i<Constants.DIFFICULTY_ARRAY.length; i++)
		{
			if(Constants.DIFFICULTY_ARRAY[i] == _difficultyLevel)
			{
				colour = Constants.DIFFICULTY_COLOR_ARRAY[i];
				break;
			}
		}

		return colour;
	}
	
	private function getDifficultyNumber():int
	{
		for(var i:int=0; i<Constants.DIFFICULTY_ARRAY.length; i++)
		{
			if(Constants.DIFFICULTY_ARRAY[i] == _difficultyLevel)
				return i;
		}		
		return NaN;
	}
	
	
	
	//------------------------------------
	
	//** higher than easy level so display not available frame
	private function displayNotAvailalbeFrame():void
	{
		mc.gotoAndStop(2);
		
		//frame 2 dynamic text
		mc.txtChallengeCode.text = _weeklyChallengeCode;	
		mc.txtChallengeCode.textColor = getDifficultyColour();
		mc.txtExpiry.text = "this contest ends on " +  _expiryDate.toString();
		
		for(var i:int = 0; i<2; i++)
		{
			if(i == 0)
				MovieClip(mc["button"+i]).width *= _topView.SCREEN_RATIO_FACTOR;
			
			MovieClip(mc["button"+i]).addEventListener(MouseEvent.CLICK, frameTwoButtonEventHandler);				
		}
	}
	
	private function frameTwoButtonEventHandler(e:MouseEvent):void
	{
		trace("WeeklyPopupView.btnClickEventHandler() - Return to main menu");
		
		switch(e.target.name as String)
		{
			case "button0":
			{			
				trace("WeeklyPopupView.frameTwoButtonEventHandler() - Return to main menu");
				_topView.removeChild(this);
				break;
			}
			case "button1":
			{
				trace("WeeklyPopupView.frameTwoButtonEventHandler() - PURCHASE FULL GAME");
				if(!urlRequestMade)
				{
					if(Capabilities.os.indexOf("Mac") >= 0 || Capabilities.os.indexOf("iPhone") >= 0 || Capabilities.os.indexOf("iPad") >= 0)
					{					
						navigateToURL(new URLRequest("https://itunes.apple.com/us/app/synonymy/id924648807?ls=1&mt=8"), "_blank");
					}
					else //android
					{
						navigateToURL(new URLRequest("https://play.google.com/store/apps/details?id=air.com.jarvisfilms.synonomy"), "_blank");
					}
				}				
				urlRequestMade = true;
				
				break;
			}
			default:
			{
				break;
			}
		}
	}
	
	private function destroyThis(e:Event):void
	{
		if(mc.currentFrame == 1)
		{
			mc.txtEmail.addEventListener(FocusEvent.FOCUS_IN, inputTextFocusEvent);
			mc.txtEmail.addEventListener(FocusEvent.FOCUS_OUT, inputTextLoseFocusEvent);	
			
			for(var i:int = 0; i<3; i++)
			{			
				MovieClip(mc["btn"+i]).removeEventListener(MouseEvent.CLICK, btnClickEventHandler);
			}
		}
		else
		{
			for(var j:int = 0; j<2; j++)
			{			
				MovieClip(mc["button"+j]).removeEventListener(MouseEvent.CLICK, frameTwoButtonEventHandler);
			}
		}
		
		Multitouch.inputMode = MultitouchInputMode.GESTURE;
		
		while(this.numChildren > 0)
			this.removeChildAt(0);
		
		_topView.weeklyPopupVisible = false;
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
				
		trace("WEEKLY POPUP VIEW IS GONE this : " + this);
	}
}
}

