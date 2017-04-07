package com.view
{
	
import com.greensock.TweenLite;
import com.greensock.easing.Circ;
import com.greensock.plugins.BlurFilterPlugin;
import com.greensock.plugins.RemoveTintPlugin;
import com.greensock.plugins.TintPlugin;
import com.greensock.plugins.TweenPlugin;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.ColorTransform;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;

public class WordBlockView extends MovieClip
{
	private var textClipArray:Array = new Array;
	private var _synArray:Array = new Array;
	private var _topView:MovieClip; //Synonyms class reference
	private var frameNum:int=0;
	private var selectedWordClip:MovieClip;
	private var selectionTimer:Timer;
	private var swipeStopsSelection:Boolean;
	
	private var placeArr:Array;
	
	private var synScaleArray:Array = [1, 1.2, 1.4, 1.6, 1.8, 2, 2.2, 2.4, 2.5];
	
	public var _viewNum:int;
		
	public function WordBlockView(synArray:Array, viewNum:int, topView)
	{
		//trace("-- WordBlockView created - viewNum: " + viewNum);
		//trace("WordBlockView() - _synArray.length : " + arr.length);
		
		_synArray = synArray;
		_viewNum = viewNum;
		_topView = topView;
		
		_topView.swipeingPreventsTouchEvent.add(swipeingPreventsTouchEvent);
		
		this.graphics.clear();
		this.graphics.beginFill(0x000000, 0);
		this.graphics.lineStyle(0, 0x000000, 0);
		this.graphics.drawRect(0, 0, _topView.appWidth, _topView.appHeight);
		this.graphics.endFill();		
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	public function get textArrayLength():int
	{
		return textClipArray.length;
	}
	
	private function init(e:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		TweenPlugin.activate([TintPlugin]);
		TweenPlugin.activate([RemoveTintPlugin]);		
		
		// Random placement of synonyms
		
		placeArr = [
			[85, Math.random()*260 + 120], //top left
			[_topView.appWidth-85, Math.random()*260 + 120], //top right 
			[85, 720 + Math.random()*160],  //bottom left
			[_topView.appWidth-85, 720 + Math.random()*160] ]; //bottom right
		
		for(var i:int=0; i<_synArray.length; i++)
		{
			var syn = new TextMC();
			syn.txt.text = _synArray[i][0];
			syn.txt.autoSize = TextFieldAutoSize.LEFT;
			syn.txt.embedFonts = true;
			syn.x = placeArr[i][0];
			syn.y = placeArr[i][1];
			syn.mouseChildren = false;
			syn.addEventListener(MouseEvent.CLICK, wordSelectionHandler, false, -10); //competes with swipe gesture event
						
			textClipArray.push(syn);			
			this.addChild(textClipArray[i] as MovieClip);
			textClipArray[i].mouseChildren = false;
			
			var c:ColorTransform = this.transform.colorTransform;
			var num:int = _viewNum-1;
			if(num >= _topView.userVO.colorsArray.length)
				num = 0;
			
			c.color = uint(String("0x" + _topView.userVO.colorsArray[num][i]));
			textClipArray[i].getChildAt(0).transform.colorTransform = c;
			
			// scale according to %value
			var scale:Number = synScaleArray[ int(_synArray[i][2])-1 ];
			if(isNaN(scale))
				scale = 1;
			
			// scale endWord if is a synonym
			
			if(_viewNum == 1 && i == 1 &&  _topView.gameDataVO.endWordIsSynonym)
				scale = synScaleArray[ synScaleArray.length-1 ];
			
			textClipArray[i].scaleX = scale;
			textClipArray[i].scaleY = scale;			
			
			//trace("Text Clip Info: " + textClipArray[i].txt.text + " / scaleX " + textClipArray[i].scaleX + " / scaleY " + textClipArray[i].scaleY + " / color " + c.color);
			
			
			// TWEAK: Shift smaller words down for bottom two syn positions
			
			if(i>1 && scale < 1.8)
			{
				textClipArray[i].y += Math.round(80 * (1/scale));
				
				//trace("ADJUSTING THE WORD : i : " + i + " / scale : " + scale + " / adjust value : " + Math.round(80 * (1/scale)) +" / word : " + textClipArray[i].txt.text);
			}
			
			if (i%2 != 0)
				textClipArray[i].x -= textClipArray[i].width;
			
			// prevent overlap of synonym clips	
			// NOTE: textClip on right of screen will always be relocated
			if(i == 1 || i == 3)
			{
				if (textClipArray[i].hitTestObject(textClipArray[i-1]))
				{					
					if(i == 1) // in top half of screen
					{
						textClipArray[i-1].y = 80;
						textClipArray[i].y = textClipArray[i-1].y + textClipArray[i-1].height/2 + 30;
					}						
					else
					{
						textClipArray[i-1].y = _topView.appHeight - 270;
						textClipArray[i].y = textClipArray[i-1].y - textClipArray[i].height/2 + 30;
					}
					
					//trace("WordBlockView.init() - HIT TEST PLACEMENT :: i : " + i);
				}
			}
		}
	}
	
	public function fadeInFirstWordBlock():void
	{
		TweenPlugin.activate([BlurFilterPlugin]);
		
		for each(var item:Object in textClipArray)
		{
			TweenLite.from(item, 0.7, {blurFilter:{blurX:60, blurY:60, quality:1}, ease:Circ.easeOut});
		}
	}
	
	//Called from GamePlayView - signalled from topview keyhandler function dispatch
	public function keyBoardWordSelection(wordLocation:String):void
	{
		trace("WordBlockView.keyBoardWordSelection() - wordLocation : " + wordLocation);
		
		var num:int = 0;
		switch(wordLocation)
		{
			case 'topLeft':
			{
				num = 0;
				break;
			}
			case 'topRight':
			{
				num = 1;
				break;
			}
			case 'bottomLeft':
			{
				num = 2;
				break;
			}
			case 'bottomRight':
			{
				num = 3;
				break;
			}
		}
		
		
		for(var i:int=0; i<textClipArray.length; i++)
		{
			//if(textClipArray[i].txt.text == word)
			trace("textClipArray[i].txt.text : " + textClipArray[i].txt.text + " / x : " + textClipArray[i].x +" / y "+ textClipArray[i].y);
		}		
		
		//check that a textClip is available in that corner
		if(num >= textClipArray.length)
			return;
		
		
		selectedWordClip = textClipArray[num];		
		selectionTimer = new Timer(100,1);
		selectionTimer.addEventListener(TimerEvent.TIMER, wordSelectTimerEvent, false, 0, true);
		selectionTimer.start();		
	}
	
	private function swipeingPreventsTouchEvent(value:Boolean):void
	{
		swipeStopsSelection = value;
				
		if(selectionTimer)
		{			
			killSelectionTimer();
		}
	}
	
	private function wordSelectionHandler(e:MouseEvent):void
	{
		killSelectionTimer();
		
		if(swipeStopsSelection)
		{
			swipeStopsSelection = false;
			e.stopImmediatePropagation();
			return;
		}
		else
		{
			selectedWordClip = e.currentTarget as MovieClip;			
			selectionTimer = new Timer(100,1);
			selectionTimer.addEventListener(TimerEvent.TIMER, wordSelectTimerEvent, false, 0, true);
			selectionTimer.start();
		}
	}
	
	private function wordSelectTimerEvent(e:TimerEvent):void
	{
		killSelectionTimer();
		
		if(swipeStopsSelection)
		{
			swipeStopsSelection = false;
			return;
		}
		
		_topView._stage.focus = _topView._stage; // retain focus - needed for desktop app.
		
		var keywordMC:MovieClip = MovieClip(this.parent).keywordClip;
		TweenLite.to(keywordMC, 0.5, {alpha:0});
		
		var selWordScaleOrig:int = selectedWordClip.scaleX;
		selectedWordClip.scaleX = 2.7;
		selectedWordClip.scaleY = 2.7;
		
		TweenLite.to(selectedWordClip, 0, {tint:0xcccccc});
				
		var origX:Number;
		var origY:Number;
		for each(var item:* in textClipArray)
		{
			item.removeEventListener(MouseEvent.CLICK, wordSelectionHandler);
			
			if(item != selectedWordClip)
			{
				TweenLite.to(item, 0.5, {blurFilter:{blurX:60, blurY:60, quality:1}, ease:Circ.easeIn});
			}
			else
			{
				origX = selectedWordClip.x;
				origY = selectedWordClip.y;
				
				selectedWordClip.x = _topView.appWidth/2 - selectedWordClip.width/2;
				selectedWordClip.y = keywordMC.y;
				
				TweenLite.from(selectedWordClip, 0.5, {x:origX, y:origY, scaleX:selWordScaleOrig, scaleY:selWordScaleOrig, 
					removeTint:true, onComplete:getNewKeyword, onCompleteParams:[selectedWordClip.txt.text]});
			}
		}
		
		TweenLite.to(MovieClip(this.parent).pageCrumbs, 0.35, {alpha:0});
	}
	
	private function getNewKeyword(selectedWord:String):void
	{		
		_topView.gameNextWordSignal.dispatch(selectedWord);
	}
	
	private function killSelectionTimer():void
	{
		if(selectionTimer)
		{
			selectionTimer.stop();
			selectionTimer.removeEventListener(TimerEvent.TIMER, wordSelectTimerEvent);
			selectionTimer = null;
		}
	}
	
	private function destroyThis(e:Event):void
	{		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		killSelectionTimer();
		
		while(this.numChildren > 0)
		{
			TweenLite.killTweensOf(this.getChildAt(0));
			this.getChildAt(0).removeEventListener(MouseEvent.CLICK, wordSelectionHandler);
			this.removeChildAt(0);
		}
		textClipArray = null;
	}
}
}
