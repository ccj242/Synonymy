package com.view
{
import com.Constants;
import com.greensock.TweenLite;
import com.scroller.TouchScroller;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextFieldAutoSize;

public class DefinitionView extends MovieClip
{	
	private var _defVO:Object;
	private var _topView:MovieClip;
	
	private var container:MovieClip;
	private var mc:DefinitionMC;
	private var dropList:DropListMC;
		
	public function DefinitionView(topView:MovieClip)
	{
		//trace("-- DefinitionView()");

		_topView = topView;
		_defVO = _topView.gameDataVO;
				
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event):void
	{		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		container = new MovieClip;
		this.addChild(container);
		
		mc = new DefinitionMC();
		container.addChild(mc);
		
		var syllables:String = strReplace(_defVO.endWordSyllables, "%", "\u00B7");
		mc.endWord.text = syllables;
						
		addScrollingContent();
		addButtonEvents();
		
		_topView.viewLoadedSignal.dispatch(this);
	}
	
	private function addScrollingContent():void
	{
		var sprite:DefinitionTextMC = new DefinitionTextMC();
		sprite.definition.autoSize = TextFieldAutoSize.LEFT;
		sprite.definition.text = _defVO.endWordDefn;
		
		// add our list and listener
		var scroller:TouchScroller = new TouchScroller(1560, 580, _topView, sprite);
		scroller.x = 220;
		scroller.y = 310;
		mc.addChild(scroller);
	}
	
	private function addButtonEvents():void
	{
		for(var i:int = 0; i<2; i++)
		{
			if(i==0)
				MovieClip(mc["btn"+i]).width *= _topView.SCREEN_RATIO_FACTOR;
			
			MovieClip(mc["btn"+i]).addEventListener(MouseEvent.CLICK, btnClickEventHandler);				
		}		
	}
	
	private function btnClickEventHandler(e:MouseEvent):void
	{
		switch(e.target.name as String)
		{
			case "btn0":
			{			
				_topView.leaveDefinitionViewSignal.dispatch(Constants.GAME_VIEW);				
				break;
			}
			case "btn1":
			{
				if(!dropList)
				{
					dropList = new DropListMC;
					mc.addChild(dropList);
					MovieClip(dropList).gotoAndStop(3);
					mc.addChild(mc["btn1"]); // brings list button top top
					MovieClip(dropList["transClip"]).addEventListener(MouseEvent.CLICK, closeDropList);
					dropList.x = 340;
					TweenLite.to(dropList, 0.35, {x:0});
					
					addDropListEventHandlers();
					
					_topView.preventSwipe = true;					
				}
				else
				{
					TweenLite.to(dropList, 0.35, {x:340, onComplete:removeDropList});
				}		
				
				break;
			}
			default:
			{
				break;
			}
		}
	}
	
	private function addDropListEventHandlers():void
	{
		if(dropList)
		{
			for(var i:int=0; i<2; i++)
			{
				MovieClip(dropList["b"+i]).width *= _topView.SCREEN_RATIO_FACTOR;
				MovieClip(dropList["b"+i]).addEventListener(MouseEvent.CLICK, dropListButtonHandler);
			}
		}
	}
	
	private function dropListButtonHandler(e:MouseEvent):void
	{
		switch(e.target.name)
		{
			case "b0":
			{
				closeDropList(null);
				_topView.getHelpScreenSignal.dispatch();
				break;
			}
			case "b1":
			{
				TweenLite.to(dropList, 0.35, {x:340, onComplete:removeDropList, onCompleteParams:[true]});
				MovieClip(dropList["transClip"]).removeEventListener(MouseEvent.CLICK, closeDropList);
				break;
			}
		}
	}
	
	private function closeDropList(e:MouseEvent):void
	{
		TweenLite.to(dropList, 0.35, {x:340, onComplete:removeDropList});
		MovieClip(dropList["transClip"]).removeEventListener(MouseEvent.CLICK, closeDropList);
	}
	
	private function removeDropList(getMainMenu:Boolean=false):void
	{
		mc.removeChild(dropList);
		dropList = null;
		_topView.preventSwipe = false;
		
		if(getMainMenu)
		{
			_topView.leaveDefinitionViewSignal.dispatch(Constants.MENU_VIEW);
		}
	}
	
	
	function strReplace(str:String, search:String, replace:String):String 
	{
		return str.split(search).join(replace);
	}
	
	private function destroyThis(e:Event):void
	{
		if(dropList)
		{
			for(var i:int=0; i<2; i++)
			{
				MovieClip(dropList["b"+i]).removeEventListener(MouseEvent.CLICK, dropListButtonHandler);
			}			
			
			MovieClip(dropList["transClip"]).removeEventListener(MouseEvent.CLICK, closeDropList);
			mc.removeChild(dropList);	
		}
		
		for(var j:int = 0; j<2; j++)
		{
			MovieClip(mc.getChildByName("btn"+j)).removeEventListener(MouseEvent.CLICK, btnClickEventHandler);				
		}
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
				
		//trace("DEFINITION VIEW IS GONE this : " + this);
	}
}
}

