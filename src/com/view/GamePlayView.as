package com.view
{

import com.Constants;
import com.greensock.TweenLite;
import com.greensock.plugins.BlurFilterPlugin;
import com.greensock.plugins.TweenPlugin;
import com.model.KeywordDefinitionModel;

import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextFieldAutoSize;

import org.osflash.signals.DeluxeSignal;

public class GamePlayView extends MovieClip
{
	private var _topView:MovieClip;
	private var keyDefnBtn:Sprite;
	private var keywordDefinitionView:KeywordDefinitionView
	private var swipeStopsSelection:Boolean;
	
	//private var isTweening:Boolean;
	private var synsArray:Array=[];
	private var keyword:String;
	private var wordBlockViewArray:Array;
	private var crumbMarkersArray:Array=[];	
	private var CURR_VIEW_NUM:int=1;	
	private var _blurValue:int=0;
	
	public var keywordClip:MovieClip;	
	public var pageCrumbs:MovieClip
		
	public function GamePlayView(topView, blurValue)
	{	
		//trace("-- GamePlayView() - blurValue : " + blurValue);
		
		_topView = topView;
		
		if(blurValue)
			_blurValue = blurValue;
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	public function keyStrokeWordSelection(wordLocation:String):void
	{
		trace("GamePlayView.keyStrokeWordSelection() - wordLocation : " + wordLocation);
		
		if(wordLocationNum(wordLocation) < wordBlockViewArray[CURR_VIEW_NUM-1].textArrayLength)
		{
			MovieClip(wordBlockViewArray[CURR_VIEW_NUM-1]).keyBoardWordSelection(wordLocation);
		}
		else
		{
			_topView.letterCornerSelectionSignal.addOnce(keyStrokeWordSelection);
		}
		
		
	}
	
	private function wordLocationNum(location:String):int
	{
		var num:int = 0;
		switch(location)
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
		
		return num;
	}
		
	private function init(e:Event):void
	{
		//trace("GamePlayView.init()");
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		_topView.gamePlaySwipeSignal = new DeluxeSignal();	
		_topView.gamePlaySwipeSignal.add(swipeActionHandler);
		
		_topView.letterCornerSelectionSignal.addOnce(keyStrokeWordSelection);
		
		_topView.swipeingPreventsTouchEvent.add(preventsTouchEvent); //subscribe to event (wordBlockViews also subscribes)
		
		// re-randomize colorsArray
		_topView.userModel.randomiseColorsArray();

		synsArray = _topView.gameDataVO.synonymsArray;
		keyword = _topView.gameDataVO.currentWord;
		
		buildKeyword();
		buildWordBlockViews();
		buildPageCrumbs();
	}
	
	private function buildKeyword():void
	{
		keywordClip = new TextMC();
		keywordClip.txt.autoSize = TextFieldAutoSize.LEFT;			
		keywordClip.txt.text = keyword;
		keywordClip.scaleX = 2.7;
		keywordClip.scaleY = 2.7;
		keywordClip.x = int(_topView.appWidth/2 - keywordClip.width/2);
		keywordClip.y = int(_topView.appHeight/2) - 40;
		
		keyDefnBtn = new Sprite();
		var rectangle:Shape = new Shape;
		rectangle.graphics.beginFill(0xFF0000);
		rectangle.graphics.drawRect(0, 0, keywordClip.txt.width,55);
		rectangle.graphics.endFill();
		rectangle.alpha = 0;
		keyDefnBtn.addChild(rectangle);
		keyDefnBtn.addEventListener(MouseEvent.CLICK, getKeywordDefn, false, -10); //competes with swipe gesture event
		
		keyDefnBtn.x = keywordClip.x;
		keyDefnBtn.y = keywordClip.y-55;
		keyDefnBtn.scaleX = 2.7;
		keyDefnBtn.scaleY = 2.7;
		
		this.addChild(keywordClip);
		
		this.addChild(keyDefnBtn);
		
		blurKeyword(2, 0.2);
	}
	
	private function buildWordBlockViews()
	{
		wordBlockViewArray = new Array;
		var j:int=1;
		var arr:Array = new Array;		
		for(var i:int=1; i<synsArray.length+1; i++)		
		{
			arr.push(synsArray[i-1]);
			
			if (i % 4 == 0 || i == synsArray.length)
			{			
				var block:WordBlockView = new WordBlockView(arr, j, _topView);
				wordBlockViewArray.push(block);
				
				if(i != 0)
				{
					arr = [];
					j++;
				}
			}			
		}
		synsArray = null;
	
		for(var k:int=0; k<wordBlockViewArray.length; k++)
		{			
			wordBlockViewArray[k].width = _topView.appWidth;
			wordBlockViewArray[k].height = _topView.appHeight;
			this.addChild(wordBlockViewArray[k]);
			
			if(k>0)
			{
				wordBlockViewArray[k].x = _topView.appWidth;
				wordBlockViewArray[k].visible = false;
			}
		}		
		//trace("buildWordBlockViews()- DONE - array length : " + wordBlockViewArray.length);
		
		_topView.CURRENT_GAME_BLOCK_NUM = 1;
		_topView.TOTAL_GAME_BLOCK_NUMS = wordBlockViewArray.length;

		wordBlockViewArray[0].fadeInFirstWordBlock();
		
		this.setChildIndex(keyDefnBtn, this.numChildren-1);
	}	
	
	private function blurKeyword(dur:Number, del:Number):void
	{
		//trace("GamePlayView.blurKeyword()");
		
		TweenPlugin.activate([BlurFilterPlugin]);
		//var arr:Array = [Math.random()*2 + 2, Math.random()*2 + 4];
		TweenLite.to(keywordClip, dur, {delay:del, blurFilter:{blurX:_blurValue, blurY:_blurValue, quality:1}});  //, onComplete:reverseBlur, onCompleteParams:arr
	}
	
	/*private function reverseBlur(dur:Number, del:Number):void
	{
		//trace("GamePlayView.reverseBlur()");
		
		var arr:Array = [Math.random()*2 + 2, Math.random()*1 + 1];		
		TweenLite.from(keywordClip, dur, {delay:del, blurFilter:{blurX:_blurValue, blurY:_blurValue, quality:1}, onComplete:blurKeyword, onCompleteParams:arr});
	}*/
	
	private function preventsTouchEvent(value:Boolean):void
	{
		//trace("GamePlayView.preventsTouchEvent() - value : " + value);
		
		swipeStopsSelection = value;
	}
	
	private function getKeywordDefn(e:MouseEvent):void
	{
		//trace("GamePlayView.getKeywordDefn()");
		
		if(swipeStopsSelection)
			return;
		
		//trace("GamePlayView.getKeywordDefn() - keywordClip.txt.text : " + keywordClip.txt.text);
		
		var keyDefModel:KeywordDefinitionModel = new KeywordDefinitionModel();
		keyDefModel.keywordDefinitionSignal.addOnce(onDefinitionDataReturned);
		keyDefModel.queryDatabase(String(keywordClip.txt.text));
	}
	
	private function onDefinitionDataReturned(definition:String):void
	{
		//trace("GamePlayView.keyWordDefnDataReturned() - definition : " + definition);
		
		_topView.preventSwipe = true;
		
		keywordDefinitionView = new KeywordDefinitionView(definition, _topView);
		keywordDefinitionView.closeKeyDefView.add(removeKeyDefinitionView);
		_topView.addChild(keywordDefinitionView);		
		keywordDefinitionView.alpha = 0;
		
		_topView.blurContainer();
		TweenLite.to(keywordDefinitionView, 0.5, {delay:0.2, alpha:1});
	}
	
	private function removeKeyDefinitionView():void
	{
		_topView._stage.focus = _topView._stage; // retain focus - needed for desktop app.		
		_topView.removeChild(keywordDefinitionView);
		
		_topView.unBlurContainer();
	}
	
	private function buildPageCrumbs():void
	{
		var pageText:PageText = new PageText();
		pageText.endWord.text = _topView.gameDataVO.endWord;
		pageText.endWord.autoSize = TextFieldAutoSize.LEFT;
		pageText.btn0.width = pageText.endWord.width+5;
		pageText.btn0.addEventListener(MouseEvent.CLICK, jumpToDefinitionView, false, 0, true);
		
		var markerX:Number = pageText.endWord.width;
		var markerY:Number = pageText.endWord.height/2;
		var markersHolder:MovieClip = new MovieClip();
		for(var i:int=0; i<wordBlockViewArray.length; i++)
		{
			markerX += 40;
			
			var marker:PageMarker = new PageMarker();
			markersHolder.addChild(marker);
			marker.y = markerY;
			marker.x = markerX;
			marker.addEventListener(MouseEvent.CLICK, onMarkerClickHandler);
			crumbMarkersArray.push(marker);
			
			if(i>0)
				crumbMarkersArray[crumbMarkersArray.length-1].markerInside.alpha = 0.4;
		}
		
		pageCrumbs = new MovieClip();
		pageCrumbs.addChild(pageText);
		pageCrumbs.addChild(markersHolder);
		pageCrumbs.alpha = 0.5;
		this.addChild(pageCrumbs);
		
		pageCrumbs.scaleX = 1.2;
		pageCrumbs.scaleY = 1.2;
		pageCrumbs.x = _topView.appWidth/2 - pageCrumbs.width/2;
		pageCrumbs.y = _topView.appHeight - 115;
		
		TweenLite.from(pageCrumbs, 0.4, {delay:0.4, alpha:0});
	}
	
	private function jumpToDefinitionView(e:MouseEvent):void
	{
		_topView.getDefinitionView();
	}
	
	private function onMarkerClickHandler(e:MouseEvent):void
	{		
		for(var i:int=1; i<crumbMarkersArray.length+1; i++)
		{
			if(e.currentTarget == crumbMarkersArray[i-1])
			{				
				var action:String;
				if(i > CURR_VIEW_NUM)
					action = Constants.SWIPE_LEFT;
				else if(i < CURR_VIEW_NUM)
					action = Constants.SWIPE_RIGHT;
				else
					return;
				
				swipeActionHandler(i, action);
				break;
			}
		}
	}
	
	private function swipeActionHandler(newBlockNum:int, swipeAction:String):void
	{
		//trace("GamePlayView.swipeActionHandler() swipeAction: " + swipeAction);
		
		if(!wordBlockViewArray) // || isTweening
			return;
		
		//isTweening = true;
		
		var _x:Number = 0; 
		if(swipeAction == Constants.SWIPE_LEFT)
		{
			_x = _topView.appWidth;
		}
		else if(swipeAction == Constants.SWIPE_RIGHT)
		{
			_x = -_topView.appWidth;
		}
		else
			return;
		
		CURR_VIEW_NUM = newBlockNum;
		
		//trace("GamePlayView.swipeActionHandler() NEW CURR_VIEW_NUM: " + CURR_VIEW_NUM);
		
		for(var i:int=0; i<wordBlockViewArray.length; i++)
		{			
			if(wordBlockViewArray[i]._viewNum == CURR_VIEW_NUM)
			{
				wordBlockViewArray[i].visible = true;
				wordBlockViewArray[i].x = 0;
				TweenLite.from(wordBlockViewArray[i], 0.4, {x:_x, onComplete:completeSwipeAction});
			}
			else if(wordBlockViewArray[i]._viewNum < CURR_VIEW_NUM) // move to left of stage			
			{				
				TweenLite.to(wordBlockViewArray[i], 0.4, {x:-_topView.appWidth});
			}
			else
			{				
				TweenLite.to(wordBlockViewArray[i], 0.4, {x:_topView.appWidth});
			}
		}
		_topView.soundFXPlayer.playSound(Constants.STRUM_SOUND);
		
		_topView.CURRENT_GAME_BLOCK_NUM = CURR_VIEW_NUM;
		
		updateCrumbs();
	}
	
	private function completeSwipeAction():void
	{
		//isTweening = false;
		
		_topView.swipeingPreventsTouchEvent.dispatch(false);
		
		for each(var item in wordBlockViewArray)
		{
			if(item._viewNum != CURR_VIEW_NUM)
			{
				item.visible = false;
			}			
		}
	}
	
	private function updateCrumbs():void
	{
		//trace("wordBlockViewArray.length : " + wordBlockViewArray.length);
		//trace("crumbMarkersArray.length : " + crumbMarkersArray.length);
		
		for each(var mc:* in crumbMarkersArray)
		{
			mc.markerInside.alpha = 0.4;
		}
		
		for(var i:int=0; i<crumbMarkersArray.length; i++)
		{
			if(i < CURR_VIEW_NUM)
				crumbMarkersArray[i].markerInside.alpha = 1;
		}
	}	
		
	private function destroyThis(e:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		keyDefnBtn.removeEventListener(MouseEvent.CLICK, getKeywordDefn);
				
		for each(var mc:* in crumbMarkersArray)
		{
			mc.removeEventListener(MouseEvent.CLICK, onMarkerClickHandler);
		}
		crumbMarkersArray = null;
		
		while(keywordClip.numChildren > 0)
		{
			keywordClip.removeChildAt(0);
		}
		
		while(this.numChildren > 0)
		{
			this.removeChildAt(0);
		}
		wordBlockViewArray = null;
		
		
		//trace("GAME PLAY VIEW IS GONE this : " + this);
	}
	
}
}