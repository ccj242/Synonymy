package com.view
{
import com.Constants;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

public class HelpScreenView extends MovieClip
{
	private var _topView:MovieClip;
	
	private var container:MovieClip;
	private var mc:MovieClip;
	
	public function HelpScreenView(topView:MovieClip)
	{
		//trace("-- HelpScreenView()");
		
		_topView = topView;
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}	
	
	private function init(e:Event):void
	{	
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		container = new MovieClip;
		this.addChild(container);
		
		mc = new HelpScreenMC;
		container.addChild(mc);
		
		addHelpScreenEventHandlers();
	}
		
	private function addHelpScreenEventHandlers():void
	{
		for(var i:int=0; i<6; i++)
		{
			MovieClip(mc["btn"+i]).addEventListener(MouseEvent.CLICK, helpScreenTouchEvents);
		}
	}
	
	private function helpScreenTouchEvents(e:MouseEvent):void
	{
		//trace("HelpScreenView.helpScreenTouchEvents() - btn : " + e.target.name);
		
		switch(e.target.name)
		{
			case "btn0":
			{
				_topView.closeHelpScreenSignal.dispatch();
				break;
			}
			case "btn1":
			{
				navigateToURL(new URLRequest("https://www.youtube.com/watch?v=Y1cu0i-4gb8"), "_blank");
				break;
			}
			case "btn2":
			{
				navigateToURL(new URLRequest("https://twitter.com/synonymygame"), "_blank");
				break;
			}
			case "btn3":
			{
				navigateToURL(new URLRequest("https://www.facebook.com/synonymygame"), "_blank");
				break;
			}
			case "btn4":
			{
				navigateToURL(new URLRequest("http://www.synonymy-game.com/"), "_blank");
				break;
			}
			case "btn5":
			{
				navigateToURL(new URLRequest("http://www.gigapan.com/gigapans/159329/options/nosnapshots,hidetitle,fullscreen/iframe/flash.html?height=5000"), "_blank");
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
		for(var i:int=0; i<6; i++)
		{
			MovieClip(mc["btn"+i]).removeEventListener(MouseEvent.CLICK, helpScreenTouchEvents);
		}
		
		while (this.numChildren > 0)
		{
			this.removeChildAt(0)
		}		
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		//trace("HELP SCREEN VIEW IS GONE this : " + this);
	}
}
}