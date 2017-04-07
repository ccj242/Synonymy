package com.view
{
import com.Constants;
import com.clipboard.ClipboardUtility;
import com.controller.DataSendController;
import com.greensock.TweenLite;
import com.greensock.plugins.BlurFilterPlugin;
import com.greensock.plugins.TweenPlugin;
import com.model.DataService;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextFieldAutoSize;

import org.osflash.signals.DeluxeSignal;


public class SuccessView extends MovieClip
{	
	private var _topView:MovieClip;
	
	private var container:MovieClip;
	private var mc:MovieClip;
	
	private var view1:SuccessSub1View;
	private var view2:SuccessSub2View;
	private var localTweening:Boolean;
	private var allWordsArray:Array;
	private var dropList:DropListMC;	
	private var preloader:Preloader;	
	private var clipboard:ClipboardUtility;
	private var isWeeklyChallenge:Boolean;
	
	public var successSwipeEventSignal:DeluxeSignal = new DeluxeSignal();
	
	public function SuccessView(topView:MovieClip)
	{
		//trace("-- SuccessView()");
		
		_topView = topView;
		allWordsArray = _topView.gameDataVO.allWordsArray;
				
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}	
	
	private function init(e:Event):void
	{	
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		container = new MovieClip;
		this.addChild(container);
		
		mc = new SuccessMC;
		container.addChild(mc);
		
		successSwipeEventSignal.add(onSwipeAction);
		
		_topView.viewLoadedSignal.dispatch(this);
		
		addBaseContent();
		addViews();
		addButtonEvents();
	}
	
	private function addBaseContent():void
	{
		TweenPlugin.activate([BlurFilterPlugin]);
		
		var stWordClip = new TextMC();
		stWordClip.txt.autoSize = TextFieldAutoSize.LEFT;
		stWordClip.txt.text = allWordsArray[0];
		stWordClip.scaleX = 5;
		stWordClip.scaleY = 5;
		stWordClip.x = int(_topView.appWidth/2 - stWordClip.width/2);
		stWordClip.y = int(stWordClip.height/2)-50;
		blurWord(stWordClip);
		
		mc.addChild(stWordClip);
		
		var endWordClip = new TextMC();
		endWordClip.txt.autoSize = TextFieldAutoSize.LEFT;			
		endWordClip.txt.text = allWordsArray[allWordsArray.length-1];
		endWordClip.scaleX = 5;
		endWordClip.scaleY = 5;
		endWordClip.x = int(_topView.appWidth/2 - endWordClip.width/2);
		endWordClip.y = int(_topView.appHeight - endWordClip.height/2)+50;
		blurWord(endWordClip);
		
		mc.addChild(endWordClip);
	}
	
	private function blurWord(obj:*):void
	{
		TweenLite.to(obj, 0.5, {blurFilter:{blurX:24, blurY:24, quality:1}});
	}
	
	private function addViews():void
	{
		view1 = new SuccessSub1View(_topView);
		mc.addChild(view1);
		
		view2 = new SuccessSub2View(_topView);
		view2.x = _topView.appWidth;
		view2.visible = false;
		mc.addChild(view2);		
	}
	
	private function addButtonEvents():void
	{
		for(var i:int = 0; i<2; i++)
		{
			if(i==0)
				MovieClip(mc["btn"+i]).width *= _topView.SCREEN_RATIO_FACTOR;
			
			MovieClip(mc.getChildByName("btn"+i)).addEventListener(MouseEvent.CLICK, btnClickEventHandler);
			mc.addChild(MovieClip(mc.getChildByName("btn"+i)));
		}		
	}
	
	private function btnClickEventHandler(e:MouseEvent):void
	{
		var eventString:String;		
		if(e == null)
			eventString = "btn0";
		else
			eventString = e.target.name as String;
		
		switch(eventString)
		{
			case "btn0":
			{				
				if(localTweening == true)
					return;
				
				if(view1.visible)
				{
					localTweening = true;
					
					view2.visible = true;

					//mc["btn0"].width *= _topView.SCREEN_RATIO_FACTOR; - distorted circle (oval)
					//mc["btn0"].width *= 1/_topView.SCREEN_RATIO_FACTOR; - right dimensions but too small
					
					mc["btn0"].width = 125; //resest dimentions
					mc["btn0"].height = 125;
					mc["btn0"].rotation = 90;
					mc["btn0"].height *= _topView.SCREEN_RATIO_FACTOR;
											
					TweenLite.to(view1, 0.5, {x:-_topView.appWidth});
					TweenLite.to(view2, 0.5, { x:0, onComplete:onTransitionComplete});
					
					_topView.soundFXPlayer.playSound(Constants.PIANO_SOUND, _topView.gameWinningPianoTrack);			
				}
				else if(view2.visible)
				{
					localTweening = true;
					
					_topView.userVO.userName = String(view2.intitials);
					
					var dataSendController:DataSendController = new DataSendController(_topView);
					dataSendController.dataSent.addOnce(dataSendComplete);
					dataSendController.init();
					
					var preloader:Preloader = new Preloader();
					this.addChild(preloader);
				}
				else
				{
				}
				break;
			}
			case "btn1":
			{
				if(!dropList)
				{
					dropList = new DropListMC;
					mc.addChild(dropList);
					MovieClip(dropList).gotoAndStop(4);
					mc.addChild(mc["btn1"]);
					MovieClip(dropList["transClip"]).addEventListener(MouseEvent.CLICK, closeDropList);
					dropList.x = 340;
					TweenLite.to(dropList, 0.35, {x:0});
					
					addDropListEventHandlers();
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
			for(var i:int=0; i<3; i++)
			{
				MovieClip(dropList["btn_"+i]).width *= _topView.SCREEN_RATIO_FACTOR;
			}
			
			MovieClip(dropList["btn_0"]).addEventListener(MouseEvent.CLICK, copyToClipboard);
			MovieClip(dropList["btn_1"]).addEventListener(MouseEvent.CLICK, gotoTwitter);
		}
	}
	
	private function copyToClipboard(e:MouseEvent):void
	{		
		clipboard = new ClipboardUtility();
		clipboard.copyText( _topView.userVO.password );
	}
	
	private function gotoTwitter(e:MouseEvent):void
	{
		trace("SuccessView.gotoTwitter()");
		
		//now get local data to compare
		var queryType:int = 0;
		var service:DataService = new DataService();		
		var stmtText:String = "SELECT * FROM "+Constants.WEEKLY_CHALLENGE_TABLE+" ORDER BY Id DESC LIMIT 1;";
		service.userDataReturnedSignal.addOnce(localDataReturned);
		service.queryDatabase(stmtText, queryType);
	}
		
	private function localDataReturned(dataObj:Object):void
	{
		trace("SuccessView.localDataReturned() - data : " + dataObj);
		
		//parse data for stored epoch time... and passcode
		for each(var row:Object in dataObj.data)
		{			
			var challengeCode:String="";
			if(row.Passcode != null)
				challengeCode = row.Passcode;
		}
		
		trace("			- challengeCode : " + challengeCode);
		trace("			- _topView.userVO.password : " + _topView.userVO.password);
		
		
		// send twitter url:
		
		var urlString:String = "https://twitter.com/synonymygame"; //generic url
		var difficultyLevel:String = Constants.DIFFICULTY_ARRAY[_topView.userVO.difficultyNum];
		
		if(challengeCode == _topView.userVO.password)
		{
			trace("SEND WEEKLY CHALLENGE TWITTER URL");
			
			//https://twitter.com/intent/tweet?text= Just scored XXXX on this week’s @synonymygame challenge. Join the contest with code YYYYY on ZZZZZ difficulty!			
			
			urlString = "https://twitter.com/intent/tweet?text=Just scored "+_topView.SCORE+" on this week’s @synonymygame challenge" +
						". Join the contest with code "+_topView.userVO.password+" on "+difficultyLevel+" difficulty!";			
		}
		else
		{
			trace("NOT WEEKLY CHALLENGE - SEND OTHER TWITTER URL");
			
			//https://twitter.com/intent/tweet?text= Just scored XXXX on Synonymy, a new word game narrated by Richard Dawkins! Challenge me with code YYYYY on ZZZZ difficulty
			urlString = "https://twitter.com/intent/tweet?text= Just scored "+_topView.SCORE+" on Synonymy, a new word game narrated by Richard Dawkins" +
						"! Challenge me with code "+_topView.userVO.password+" on "+difficultyLevel+" difficulty"
		}
		
		navigateToURL(new URLRequest(urlString), "_blank");
	}
	
	private function closeDropList(e:MouseEvent):void
	{		
		TweenLite.to(dropList, 0.35, {x:340, onComplete:removeDropList});
		MovieClip(dropList["transClip"]).removeEventListener(MouseEvent.CLICK, closeDropList);
	}
	
	private function removeDropList():void
	{
		mc.removeChild(dropList);
		dropList = null;		
	}
	
	private function onSwipeAction(action:String)
	{
		trace("SuccessView.onSwipeAction() - action : " + action);
		
		if(action == "swipeLeft" && view1.visible)
		{
			btnClickEventHandler(null);
		}
		else if(action == "swipeUp" && view2.visible)
		{
			btnClickEventHandler(null);
		}
	}
	
	private function onTransitionComplete():void
	{
		localTweening = false;
		view1.visible = false;
		
		view2.enableTextSelector();
	}
	
	private function dataSendComplete(success:Boolean):void //The boolean is not currently used but can be expanded on in future
	{
		//trace("SuccessView() - dataSendComplete() - success : " + success);
		
		_topView.getMenuSignal.dispatch();
	}
	
	private function destroyThis(e:Event):void
	{		
		if(preloader)
		{
			this.removeChild(preloader);
			preloader = null;
		}
		
		if(dropList)
		{
			MovieClip(dropList["btn_0"]).removeEventListener(MouseEvent.CLICK, copyToClipboard);
			MovieClip(dropList["btn_1"]).removeEventListener(MouseEvent.CLICK, gotoTwitter);
			MovieClip(dropList["transClip"]).removeEventListener(MouseEvent.CLICK, closeDropList);
			mc.removeChild(dropList);	
		}
		
		for(var i:int = 0; i<2; i++)
		{
			MovieClip(mc.getChildByName("btn"+i)).addEventListener(MouseEvent.CLICK, btnClickEventHandler);				
		}
		
		while(this.numChildren > 0)
		{
			this.removeChildAt(0);
		}
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		//trace("SUCCESS VIEW IS GONE this : " + this);
	}
}
}