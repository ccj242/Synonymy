package com.view
{
import com.scroller.TouchScroller;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextFieldAutoSize;

public class SuccessSub1View extends Sprite
{
	private var _topView:MovieClip;
	
	private var container:Sprite;
	private var mc:Sprite;
	
	private var allWordsArray:Array;
	
	
	public function SuccessSub1View(topView)
	{		
		_topView = topView;
		allWordsArray = _topView.gameDataVO.allWordsArray;
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		container = new Sprite;
		this.addChild(container);
		
		mc = new SuccessMC_sub1;
		container.addChild(mc);
		addScrollingContent();
	}
	
	
	private function addScrollingContent():void
	{
		var w:int = 1560;
		var h:int = 380;
		
		var allWordsString:String = insertSpaces(allWordsArray.toString());
		
		var sprite:SuccessTextMC = new SuccessTextMC();
		sprite.width = w;
		sprite.allWords.text = allWordsString;
		sprite.allWords.autoSize = TextFieldAutoSize.LEFT;
				
		var scroller:TouchScroller = new TouchScroller(w, h, _topView, sprite);
		scroller.x = 180;
		scroller.y = 300;
		mc.addChild(scroller);
		
		if(sprite.height < h)
		{
			scroller.y += 190 - sprite.height/2;
		}
	}
	
	private function insertSpaces(str:String):String
	{
		return str.split(",").join(", ");
	}
	
	private function destroyThis(e:Event):void
	{
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