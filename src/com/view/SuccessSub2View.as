package com.view
{
import com.Constants;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class SuccessSub2View extends Sprite
{
	private var charsArray:Array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
	private var lettersArray:Array;
	private var allWordsArray:Array;
	private var container:Sprite;
	private var mc:MovieClip;
	private var mainBtn:MovieClip;
	private var currentObj:Object;
	private var timer:Timer;
	private var _topView:MovieClip;
	
	public function SuccessSub2View(topView)
	{
		_topView = topView;
		allWordsArray = _topView.gameDataVO.allWordsArray;
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	public function get intitials():String
	{
		var concatStr:String="";
		for(var i:int = 0; i<lettersArray.length; i++) 
		{
			concatStr += lettersArray[i].txt.text;
		}		
		return concatStr;
	}
	
	private function init(e:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		container = new MovieClip;
		this.addChild(container);
		
		mc = new SuccessMC_sub2;
		container.addChild(mc);
		
		displayData();
		initialsSetup();
		
		_topView.preventSwipe = true;
	}
	
	private function displayData():void
	{
		//colour score text
		mc.scoreTxt.textColor = Constants.DIFFICULTY_COLOR_ARRAY[_topView.userVO.difficultyNum];
		
		mc.scoreTxt.text = String(_topView.SCORE);
		//trace("String(_topView.SCORE) : " + String(_topView.SCORE));
		
		mc.durationTxt.text = formatDuration(_topView.DURATION);
		//mc.durationTxt.text = "Hello";
		//trace("formatDuration(_topView.DURATION) : " + formatDuration(_topView.DURATION));
		mc.numWordsTxt.text = String(allWordsArray.length) + " words";
	}
	
	private function formatDuration(dur:int):String
	{
		var d:int = dur / 86400 % 7;
		var h:int = dur / 3600 % 24;
		var m:int = dur / 60 % 60; 
		var s:int = dur % 60;
		
		if(d>0)
			return d + " d " + h + " h " + m + " m " + s + " s";
		else if(d<=0 && h>0)
			return h + " h " + m + " m " + s + " s";
		else if(d<=0 && h<=0 && m>0)
			return m + " m " + s + " s";
		else
			return s + " s";
	}
	
	private function initialsSetup():void
	{
		lettersArray = new Array();
		
		for(var i:int=0; i<3; i++)
		{
			var letter:LetterSelectorMC = new LetterSelectorMC;
			letter.scaleX = 2.2;
			letter.scaleY = 2.2;
			container.addChild(letter);
			
			var initialsArray:Array = String(_topView.userVO.userName).split("");
			
			if(initialsArray.length)
				letter.txt.text = initialsArray[i];
			else
				letter.txt.text = "A";
			
			lettersArray.push(letter);
			
			lettersArray[i].y = 300;
			if(i>0)
				lettersArray[i].x = lettersArray[i-1].x + lettersArray[i-1].width + 1;
			else
				lettersArray[i].x = 180;
		}
	}
	
	public function enableTextSelector():void
	{		
		for(var i:int=0; i<3; i++)
		{
			lettersArray[i].mouseChildren = false;
			lettersArray[i].addEventListener(MouseEvent.MOUSE_UP, releaseEventHandler);
			lettersArray[i].addEventListener(MouseEvent.MOUSE_DOWN, touchEventHandler);
		}
	}
	
	private function releaseEventHandler(e:MouseEvent):void
	{		
		if(timer)
		{
			timer.stop();
			timer = null;
		}
		e.currentTarget.removeEventListener(MouseEvent.MOUSE_OUT, releaseEventHandler);
		this.removeEventListener(MouseEvent.MOUSE_UP, releaseEventHandler);
		updateCharacter(e.currentTarget);
	}	
	
	// timer to loop through characters quickly with sustained touch
	private function touchEventHandler(e:MouseEvent):void
	{
		currentObj = e.currentTarget;
		
		e.currentTarget.addEventListener(MouseEvent.MOUSE_OUT, releaseEventHandler);
		this.addEventListener(MouseEvent.MOUSE_UP, releaseEventHandler);
		
		timer = new Timer(500);
		timer.addEventListener(TimerEvent.TIMER, timerEventHandler);
		timer.start();
	}
	
	private function timerEventHandler(e:TimerEvent):void
	{
		if(timer)
			timer.delay = 100;
		
		updateCharacter(currentObj);
	}
	
	private function updateCharacter(sprite:Object):void
	{		
		// compare current string value of sprite
		var num:int=0;
		for(var i:int=0; i<charsArray.length; i++)
		{			
			if(charsArray[i] == sprite.txt.text)
			{
				num = i;
				break;
			}				
		}
		
		// update the text field with next item in charsArray
		if(num >= charsArray.length-1)
			sprite.txt.text = charsArray[0];
		else		
			sprite.txt.text = charsArray[num+1];
	}
	
	private function destroyThis(e:Event):void
	{
		_topView.preventSwipe = false;
		
		
		
		for(var i:int = 0; i<lettersArray.length; i++)
		{
			lettersArray[i].removeEventListener(MouseEvent.MOUSE_UP, releaseEventHandler);
			lettersArray[i].removeEventListener(MouseEvent.MOUSE_OUT, releaseEventHandler);
			lettersArray[i].removeEventListener(MouseEvent.MOUSE_DOWN, touchEventHandler);
		}
		lettersArray = null;
		
		if(timer)
		{
			timer.removeEventListener(TimerEvent.TIMER, timerEventHandler);
			timer = null;
		}
		this.removeEventListener(MouseEvent.MOUSE_UP, releaseEventHandler);
		
		while(this.numChildren > 0)
		{
			this.removeChildAt(0);
		}
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		//trace("SUCCESS SUB 1 VIEW IS GONE this : " + this);
	}	
}
}