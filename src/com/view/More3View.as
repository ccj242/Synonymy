package com.view
{
import com.Constants;
import com.greensock.TweenLite;
import com.greensock.easing.Circ;
import com.scroller.TouchScroller;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import org.osflash.signals.DeluxeSignal;

public class More3View extends MovieClip
{	
	private var _topView:MovieClip;
	
	private var container:MovieClip;
	private var mc:More3_MC;
	private var creditsMC:CreditsMC;
	private var scroller:TouchScroller;
	
	public var returnToMenuView:DeluxeSignal = new DeluxeSignal();
	
	public function More3View(topView:MovieClip)
	{
		//trace("-- More3View()");			

		_topView = topView;
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event):void
	{		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		container = new MovieClip;
		this.addChild(container);
		
		mc = new More3_MC;
		container.addChild(mc);
				
		_topView.viewLoadedSignal.dispatch(this);
		
		addScrollingContent();
	}
	
	private function addScrollingContent():void
	{
		creditsMC = new CreditsMC();		
		
		
		var w:int = 1920;
		var h:int = 1080;
		scroller = new TouchScroller(w, h, _topView, creditsMC, true);
		scroller.x = 10;
		scroller.y = 0;
		mc.addChild(scroller);
		
		mc.addChild(mc.trans);
		MovieClip(mc.trans).visible = false; //prevent any further interaction until tween is complete
		
		addCreditsButtonEvents();
	}
	
	private function addCreditsButtonEvents():void
	{
		for(var i:int=0; i<8; i++)
		{
			//if(i==4)
				//MovieClip(creditsMC["btn"+i]).scaleY = _topView.SCREEN_RATIO_FACTOR;
			
			MovieClip(creditsMC["btn"+i]).addEventListener(MouseEvent.CLICK, creditsClickHandler);
		}
	}
	
	private function creditsClickHandler(e:MouseEvent):void
	{
		trace("More3View.creditsClickHandler() - TARGET : " + e.currentTarget.name);
		
		switch(e.currentTarget.name)
		{
			case "btn0":
			{
				navigateToURL(new URLRequest("http://www.jarvisfilms.com"), "_blank");
				break;
			}
			case "btn1":
			{
				navigateToURL(new URLRequest("https://richarddawkins.net"), "_blank");
				break;
			}
			case "btn2":
			{
				trace("open michaelbromley website");
				navigateToURL(new URLRequest("http://michaelbromley.ca"), "_blank");
				break;
			}
			case "btn3":
			{
				navigateToURL(new URLRequest("https://www.facebook.com/dadukpiano"), "_blank");
				break;
			}
			case "btn4":
			{				
				MovieClip(mc.trans).visible = true;		
				TweenLite.to(scroller.list, 0.7, {y:0, ease:Circ.easeOut, onComplete:onTransitionComplete});	
				break;
			}
			case "btn5":
			{
				navigateToURL(new URLRequest("https://www.jamendo.com/en/list/a1754/et-apres"), "_blank");
				break;
			}
			case "btn6":
			{
				navigateToURL(new URLRequest("https://itunes.apple.com/us/album/rue-portobello/id400653083"), "_blank");
				break;
			}
			case "btn7":
			{
				navigateToURL(new URLRequest("http://www.synonymy-game.com/"), "_blank");
				break;
			}
			default:
			{
				break;
			}
		}
	}
	
	private function onTransitionComplete():void
	{
		MovieClip(mc.trans).visible = false;		
		returnToMenuView.dispatch(Constants.MENU_VIEW, Constants.SWIPE_DOWN);
	}
	
	private function destroyThis(e:Event):void
	{
		for(var i:int=0; i<8; i++)
		{
			MovieClip(creditsMC["btn"+i]).removeEventListener(MouseEvent.CLICK, creditsClickHandler);
		}		
		
		while(this.numChildren > 0)
		{
			this.removeChildAt(0);
		}
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		//trace("MORE 3 VIEW IS GONE this : " + this);
	}
}
}