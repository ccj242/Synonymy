package com.view
{
import com.scroller.TouchScroller;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;

import org.osflash.signals.Signal;

public class KeywordDefinitionView extends MovieClip
{
	private var _definition:String;
	private var _topView:MovieClip;
	
	private var container:MovieClip;
	private var mc:KeywordDefinitionMC;
	
	public var closeKeyDefView:Signal = new Signal();
	
	
	public function KeywordDefinitionView(defn:String, topView:MovieClip)
	{
		//trace("-- KeywordDefinitionView()");
		
		_topView = topView;
		_definition = defn;		
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event):void
	{		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		container = new MovieClip;
		this.addChild(container);
		
		mc = new KeywordDefinitionMC();
		container.addChild(mc);
		
		mc.keywordTxt.text = _topView.gameDataVO.currentWord;
		
		_topView.viewLoadedSignal.dispatch(this);
		
		//addScrollingContent();
		
		addDefinitionText();
		
		this.addEventListener(MouseEvent.CLICK, btnClickEventHandler);
	}
	
	/*private function addScrollingContent():void
	{
		// add our list and listener
		var scroller:TouchScroller = new TouchScroller(1560, 580, _topView);
		scroller.x = 300;
		scroller.y = 270;
		mc.addChild(scroller);
		
		var sprite:DefinitionTextMC = new DefinitionTextMC();
		sprite.definition.text = _definition;
		scroller.addListItem(sprite);
	}*/
	
	private function addDefinitionText():void
	{
		var sprite:DefinitionTextMC = new DefinitionTextMC();
		sprite.definition.text = _definition;
		sprite.x = 310;
		sprite.y = 440;
		this.addChild(sprite);
	}
	
	private function btnClickEventHandler(e:MouseEvent):void
	{		
		closeKeyDefView.dispatch();
	}
	
	function strReplace(str:String, search:String, replace:String):String 
	{
		return str.split(search).join(replace);
	}
	
	private function destroyThis(e:Event):void
	{
		this.removeEventListener(MouseEvent.CLICK, btnClickEventHandler);
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		//trace("RULE VIEW IS GONE this : " + this);
	}

}
}