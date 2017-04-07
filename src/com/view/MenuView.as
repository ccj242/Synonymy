package com.view
{
	import com.Constants;
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	
	import org.osflash.signals.DeluxeSignal;
	

public class MenuView extends MovieClip
{	
	private var container:MovieClip;
	private var _topView;
	private var mc:MenuMC;
	private var newGameBtnTimer:Timer;
	private var transMC:TransMC;
	private var urlRequestMade:Boolean;
	
	private var unblurComplete:Boolean;
	private var weeklyPopupInProgress:Boolean;
	
	public var touchSignal:DeluxeSignal = new DeluxeSignal();
		
	public function MenuView(topView:MovieClip)
	{		
		//trace("-- MenuView()");

		_topView = topView;
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	public function addStartupCover():void
	{
		if(mc)
		{
			transMC = new TransMC;
			transMC.alpha = 0;
			mc.addChild(transMC);
		}
	}
	
	
	//////////////////  Disable touch/mouse events until correct time by using a trans mc
	public function unblurTweenComplete():void
	{
		trace("MENU VIEW ***** UNBLUR COMPLETE");
		
		unblurComplete = true;
		
		removeTransMC();
	}
	
	public function weeklyProgressActivityComplete():void
	{
		trace("MENU VIEW ***** WEEKLY PROGRESS COMPLETE");
		
		weeklyPopupInProgress = true;
		
		removeTransMC();
	}
	
	private function removeTransMC():void
	{
		if(!unblurComplete || !weeklyPopupInProgress)
			return;
		
		if(mc)
		{
			trace("MENU VIEW ***** REMOVE TRANSMC");
			
			mc.removeChild(transMC);
		}
	}
	/////////////////
	
	
	private function init(e:Event):void
	{		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		container = new MovieClip;
		this.addChild(container);
		
		mc = new MenuMC();
		container.addChild(mc);
		
		_topView.viewLoadedSignal.dispatch(this);
		
		if(_topView.AD_VERSION)
			mc.getChildByName("btn4").y = 524;
				
		addButtonEvents();
	}
	
	private function addButtonEvents():void
	{		
		for(var i:int = 0; i<5; i++)		
		{			
			if(i==0) //new game button	(use of timer to decide on challenge mode)
			{
				MovieClip(mc.getChildByName("btn"+i)).addEventListener(MouseEvent.MOUSE_DOWN, btn0EventHandler);
			}
			else
				MovieClip(mc.getChildByName("btn"+i)).addEventListener(MouseEvent.MOUSE_UP, btnTouchEventHandler);
		}		
	}
	
	private function btn0EventHandler(e:MouseEvent):void
	{
		//trace("NEW GAME BUTTON EVENT : " + e.type);		
		
		if(e.type == "mouseDown")
		{
			newGameBtnTimer = new Timer(500);
			newGameBtnTimer.addEventListener( TimerEvent.TIMER, startBtnTimerHandler);
			newGameBtnTimer.start();
			
			MovieClip(mc["btn0"]).addEventListener(MouseEvent.MOUSE_UP, btn0EventHandler);
			MovieClip(mc["btn0"]).addEventListener(MouseEvent.MOUSE_OUT, btn0EventHandler);
		}
		else if(e.type == "mouseOut")
		{
			//choice not yet made
			stopNewGameTimer();
		}
		else if(e.type == "mouseUp")
		{
			//choice made : new non-challenge mode game
			stopNewGameTimer();
			startNewGame(false);
		}
		else
		{
		}
	}
	
	private function stopNewGameTimer():void
	{		
		if(newGameBtnTimer)
		{			
			newGameBtnTimer.stop();
			newGameBtnTimer.removeEventListener( TimerEvent.TIMER, startBtnTimerHandler);
			newGameBtnTimer = null;
		}
	}
	
	private function startBtnTimerHandler(e:TimerEvent):void
	{
		stopNewGameTimer();
		startNewGame(true);
	}
	
	private function startNewGame(enterChallengeMode:Boolean):void
	{
		//trace("MenuView.startNewGame() - challengeMode : " + enterChallengeMode);
		
		if(!enterChallengeMode)
			_topView.userVO.challengeMode = 0;
		else
			_topView.userVO.challengeMode = 1;

		touchSignal.dispatch(Constants.NEW_GAME);
	}
	
	private function btnTouchEventHandler(e:MouseEvent):void
	{
		var command:String;
		switch(e.currentTarget.name as String)
		{
			case "btn1":
			{
				command = Constants.CONTINUE;
				break;
			}
			case "btn2":
			{
				command = Constants.TUTORIAL;
				break;
			}
			case "btn3":
			{
				command = Constants.MORE;
				break;
			}
			case "btn4":
			{
				if(!urlRequestMade)
				{
					if(Capabilities.os.indexOf("Mac") >= 0 || Capabilities.os.indexOf("iPhone") >= 0 || Capabilities.os.indexOf("iPad") >= 0)
					{					
						navigateToURL(new URLRequest("https://itunes.apple.com/us/app/synonymy/id924648807?ls=1&mt=8"), "_blank");
						TweenLite.to(this, 0, {delay:2, onComplete:resetUrlReqBool});
					}
					else //android
					{
						navigateToURL(new URLRequest("http://google.com"), "_blank");
					}
				}
				
				urlRequestMade = true;
				break;
			}
			default:
				break;
		}		
		touchSignal.dispatch(command);
	}
	
	private function resetUrlReqBool():void
	{
		urlRequestMade = false;
	}
	
	private function destroyThis(e:Event):void
	{		
		for(var i:int = 0; i<5; i++)		
		{
			if(i==0)
			{
				MovieClip(mc.getChildByName("btn"+i)).removeEventListener(MouseEvent.MOUSE_DOWN, btn0EventHandler);
			}
			else
			{
				MovieClip(mc.getChildByName("btn"+i)).removeEventListener(MouseEvent.MOUSE_UP, btnTouchEventHandler);
			}
		}
		
		if(newGameBtnTimer)			
		{
			stopNewGameTimer();
		}	
				
		while(this.numChildren > 0)
		{
			this.removeChildAt(0);
		}
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		//trace("MENU VIEW IS GONE this : " + this);
	}
}
}