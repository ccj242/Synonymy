package com.view
{
import com.Constants;
import com.greensock.TweenLite;
import com.media.AIRMobileVideo;
import com.media.InternetConnectivity;
import com.media.VideoPlayer;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.events.TimerEvent;
import flash.net.NetworkInfo;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.Capabilities;
import flash.utils.Timer;
import flash.utils.setTimeout;

import org.osflash.signals.DeluxeSignal;
import org.osflash.signals.Signal;

public class TutorialView extends Sprite
{	
	private var _topView:MovieClip;
	
	private var container:Sprite;
	private var mc:MovieClip;
	private var hideTimer:Timer
	private var airvideo:AIRMobileVideo;
	private var airvideo2:VideoPlayer;
	
	private var myCuePoint:Number = 56.5;
	private var usedCuePoint:Boolean;
	
	public var testTutorialVideoLocation:Signal = new Signal();
	public var returnToMenuView:DeluxeSignal = new DeluxeSignal();
	
	public var noInternetConnectivitySignal:Signal = new Signal();
	
	public function TutorialView(topView:MovieClip)
	{
		//trace("-- TutorialView()");			

		_topView = topView;
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		container = new Sprite;
		this.addChild(container);
		
		mc = new TutorialMC;
		container.addChild(mc);
		MovieClip(mc["btn0"]).alpha = 0;
		
		_topView.viewLoadedSignal.dispatch(this);
		
		noInternetConnectivitySignal.add(noInternetConnection); //dispatcher is in video class
		
		playVideo();
		
		testTutorialVideoLocation.add(determineRequiredAction);
		
		/*var timer:Timer = new Timer(2000, 1);
		timer.addEventListener(TimerEvent.TIMER, showBackBtn);
		timer.start();*/
	}
	
	private function noInternetConnection():void
	{
		//trace("NO INTERNET CONNCECTION");
		
		MovieClip(mc["preloader"]).visible = true;
		MovieClip(mc["preloader"]).gotoAndStop(2);
		
		addTutorialButtonHandlers();
	}
	
	private function addTutorialButtonHandlers():void
	{
		var tut_mc:MovieClip = MovieClip(mc["preloader"]);
		
		for(var i:int=0; i<6; i++)
		{
			MovieClip(tut_mc["btn"+i]).addEventListener(MouseEvent.CLICK, tutBtnHandler);
		}
	}	
	
	// this assumes that play head is currently at second frame
	private function removeTutorialButtonHandlers():void
	{	
		var tut_mc:MovieClip = MovieClip(mc["preloader"]);
		
		for(var i:int=0; i<6; i++)
		{
			MovieClip(tut_mc["btn"+i]).removeEventListener(MouseEvent.CLICK, tutBtnHandler);
		}
	}
	
	private function tutBtnHandler(e:MouseEvent):void
	{
		//trace(e.target.name);
		
		switch(e.target.name)
		{
			case "btn0":
			{
				removeVideo();
				removeTutorialButtonHandlers();
				returnToMenuView.dispatch(Constants.MENU_VIEW, Constants.SWIPE_LEFT);
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
	
	private function showBackBtn():void //e:TimerEvent
	{
		this.addChild(mc["btn0"]); //move arrow button to top of stack
		MovieClip(mc["btn0"]).width *= _topView.SCREEN_RATIO_FACTOR;
		MovieClip(mc["btn0"]).addEventListener(MouseEvent.CLICK, buttonSwipeEvent);
		
		showBackButton(null);
	}
	
	private function showBackButton(e:MouseEvent):void
	{		
		MovieClip(mc["btn0"]).visible = true;
		TweenLite.to(mc["btn0"], 0.5, {delay:1, alpha:1});
		
		if(airvideo)
		{
			Sprite(airvideo).removeEventListener(MouseEvent.CLICK, showBackButton);
		}
		if(airvideo2)
		{			
			Sprite(airvideo2).removeEventListener(MouseEvent.CLICK, showBackButton);
		}
		
		initiateHideTimer();
	}
	
	private function initiateHideTimer():void
	{
		hideTimer = new Timer(3000, 1);
		hideTimer.addEventListener(TimerEvent.TIMER, hideBackBtn);
		hideTimer.start();
	}
	
	private function killHideTimer():void
	{
		if(hideTimer)
		{
			hideTimer.stop();
			hideTimer.removeEventListener(TimerEvent.TIMER, hideBackBtn);
			hideTimer = null;
		}
	}
	
	private function hideBackBtn(e:TimerEvent):void
	{		
		hideBackButton(null);
	}	
	
	private function hideBackButton(e:TimerEvent):void
	{		
		TweenLite.to(mc["btn0"], 0.5, {alpha:0, onComplete:makeButtonNotVisible});
		
		killHideTimer();
	}
	
	private function makeButtonNotVisible():void
	{
		MovieClip(mc["btn0"]).visible = false;
		
		if(airvideo)
		{
			Sprite(airvideo).addEventListener(MouseEvent.CLICK, showBackButton);
		}
		if(airvideo2)
		{
			Sprite(airvideo2).addEventListener(MouseEvent.CLICK, showBackButton);
		}
	}
	
	public function playVideo():void
	{
		_topView.pauseBackground();
		
		removeVideo();
		
		setTimeout(startVid, 1500);
	}
		
	private function startVid():void
	{
		var width:Number = _topView.appWidth;
		var height:Number = _topView.appHeight;
		
		if(Capabilities.os.indexOf("iPad") >= 0 || Capabilities.os.indexOf("iPhone") >= 0)  // || Capabilities.os.indexOf("Linux") >= 0
		{
			// apple device
			trace("TutorialView.playVideo() - AIRMobileVideo");
			
			airvideo = new AIRMobileVideo(Constants.VIDEO_TUTORIAL, width, height, this);
			this.addChild(airvideo);
			airvideo.width = 1920;
			airvideo.height = 1080;
		}
		else
		{
			trace("TutorialView.playVideo() - VideoPlayer");
			
			airvideo2 = new VideoPlayer(Constants.VIDEO_TUTORIAL, width, height, this);
			this.addChild(airvideo2);
		}
	}
	
	public function showPreloader():void
	{
		//trace("TutorialView.showPreloader()");
		
		MovieClip(mc["preloader"]).visible = true;
	}
	
	//called when video starts
	public function hidePreloader():void
	{
		//trace("TutorialView.hidePreloader()");
		
		showBackBtn();
		
		MovieClip(mc["preloader"]).visible = false;
	}	
	
	private function buttonSwipeEvent(e:MouseEvent):void
	{		
		determineRequiredAction();
	}
	
	private function determineRequiredAction():void
	{		
		if(airvideo)
		{			
			//trace("airvideo.getVideoTime() : " + airvideo.getVideoTime());
			
			if(!_topView.SHORT_VIDEO && !usedCuePoint && airvideo.getVideoTime() < myCuePoint)
			{			
				usedCuePoint = true;
				airvideo.jumpToCuePoint(myCuePoint);
			}
			else
			{
				removeVideo();
				returnToMenuView.dispatch(Constants.MENU_VIEW, Constants.SWIPE_LEFT);
			}
		}
		else if(airvideo2)
		{
			//trace("airvideo2.getVideoTime() : " + airvideo2.getVideoTime());
			
			if(!_topView.SHORT_VIDEO && !usedCuePoint && airvideo2.getVideoTime() < myCuePoint)
			{				
				usedCuePoint = true;
				airvideo2.jumpToCuePoint(myCuePoint);
			}
			else
			{					
				removeVideo();
				returnToMenuView.dispatch(Constants.MENU_VIEW, Constants.SWIPE_LEFT);
			}
		}
		else
		{
			removeVideo();
			returnToMenuView.dispatch(Constants.MENU_VIEW, Constants.SWIPE_LEFT);
		}
	}
	
	
	private function removeVideo():void
	{
		if(airvideo)
		{
			Sprite(airvideo).removeEventListener(MouseEvent.CLICK, showBackButton);
			this.removeChild(airvideo);
			airvideo = null;
		}
		else if(airvideo2)
		{
			Sprite(airvideo2).removeEventListener(MouseEvent.CLICK, showBackButton);
			this.removeChild(airvideo2);
			airvideo2 = null;
		}
		else 
		{			
		}
	}
	
	private function destroyThis(e:Event):void
	{
		killHideTimer();
		
		removeVideo();
		
		noInternetConnectivitySignal.remove(noInternetConnection);
		
		while(this.numChildren > 0)
		{
			this.removeChildAt(0);
		}
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		_topView.playBackground();
		
		//trace("TUTORIAL VIEW IS GONE this : " + this);
	}
}
}