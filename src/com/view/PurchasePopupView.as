package com.view
{
import com.greensock.TweenLite;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.Capabilities;

public class PurchasePopupView extends MovieClip
{
	private var _topView:MovieClip;
	private var mc:PurchasePopup_mc;
	private var urlRequestMade:Boolean;
	
	public function PurchasePopupView(topView:MovieClip)
	{	
		_topView = topView;
	
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		mc = new PurchasePopup_mc;
		this.addChild(mc);
		
		// frame selection
		mc.gotoAndStop(frameSelection(_topView.CURRENT_PURCHASE_POPUP_FRAME));
		
		for(var i:int=0; i<2; i++)
		{
			MovieClip(mc["btn"+i]).addEventListener(MouseEvent.CLICK, addFreeButtonHandler);
		}
		
		TweenLite.to(mc["btn0"], 0.5, {delay:3, y:125});
	}	
	
	private function frameSelection(currFrame:int=-1):int
	{
		trace("PurchasePopupView.frameSelection() - currFrame " + currFrame);
		
		var newFrame:int;
		if(currFrame < 0)
			newFrame =  Math.ceil(Math.random() * mc.totalFrames);
		else
			newFrame = (currFrame < mc.totalFrames) ? (currFrame + 1) : 1;	
		
		_topView.CURRENT_PURCHASE_POPUP_FRAME = newFrame;		
		return newFrame;
	}
	
	private function addFreeButtonHandler(e:MouseEvent):void
	{
		switch(e.target.name as String)
		{
			case "btn0":
			{				
				_topView.closePurchasePopupSignal.dispatch();
				
				break;
			}
			case "btn1":
			{
				if(!urlRequestMade)
				{
					_topView.closePurchasePopupSignal.dispatch();
					
					switch(mc.currentFrame)
					{						
						case 2:
							return navigateToURL(new URLRequest("https://www.youtube.com/embed/2rI_em4MscE?VQ=HD1080&autoplay=1"), "_blank");
							break;
						case 3:
							if(Capabilities.os.indexOf("iPhone") >= 0)
								return navigateToURL(new URLRequest("https://itunes.apple.com/de/app/word-unknown/id1064901570?l=en&mt=8"), "_blank");
							else //Android
								return navigateToURL(new URLRequest("https://play.google.com/store/apps/details?id=com.jarvisfilms.wordunknown&hl=en"), "_blank");
							break;
						case 4:
							if(Capabilities.os.indexOf("iPhone") >= 0)
								return navigateToURL(new URLRequest("http://www.phoneflare.com/iOS.html"), "_blank");
							else //Android
								return navigateToURL(new URLRequest("http://www.phoneflare.com/Android.html"), "_blank");
							break;
						case 5:
							if(Capabilities.os.indexOf("iPhone") >= 0)
								return navigateToURL(new URLRequest("http://www.smstactics.com"), "_blank");
							else //Android
								return navigateToURL(new URLRequest("https://play.google.com/store/apps/details?id=com.jarvisfilms.smstactics&hl=en"), "_blank");
							break;
						case 1:
						default:
							if(Capabilities.os.indexOf("iPhone") >= 0 || Capabilities.os.indexOf("iPad") >= 0)
								return navigateToURL(new URLRequest("https://itunes.apple.com/us/app/synonymy/id924648807?ls=1&mt=8"), "_blank");
							else if(Capabilities.os.indexOf("Linux") >= 0) //Android
								return navigateToURL(new URLRequest("https://play.google.com/store/apps/details?id=air.com.jarvisfilms.synonomy"), "_blank");
							else //PC and Mac
								navigateToURL(new URLRequest("https://www.synonymy-game.com"), "_blank");
							break;
					}
				}
				
				urlRequestMade = true;
				
				break;
			}
		}
	}
	
	private function destroyThis(e:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);		
		
		for(var i:int=0; i<2; i++)
		{
			MovieClip(mc["btn"+i]).removeEventListener(MouseEvent.CLICK, addFreeButtonHandler);
		}
		
		while(this.numChildren > 0)
		{
			this.removeChildAt(0);
		}
		
		trace("DESTROY THE POPUP VIEW");
	}
	
}
}