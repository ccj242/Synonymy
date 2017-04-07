package com.view
{
import com.Constants;
import com.controller.DataRequestController;
import com.greensock.TweenLite;
import com.scroller.TouchScroller;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.net.URLRequest;
import flash.net.navigateToURL;

public class More2View extends MovieClip
{	
	private var _topView:MovieClip;
	
	private var container:MovieClip;
	private var mc:More2_MC;
	private var dropList:DropListMC;
	
	public var _isSelecting:Boolean;
	
	
	public function More2View(topView:MovieClip)
	{
		//trace("-- More2View()");			

		_topView = topView;
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	public function setIsSelecting(value:Boolean):void
	{
		_isSelecting = value;
	}
	
	private function init(e:Event):void
	{
		//trace("More2View.init()");
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		var dataRequest:DataRequestController = new DataRequestController();
		dataRequest.topScoreDataReturnedSignal.addOnce(parseScoreData);
		dataRequest.requestData();
		
		container = new MovieClip();		
		this.addChild(container);
		
		mc = new More2_MC;
		container.addChild(mc);
		
		if(_topView.PREV_VIEW == Constants.MORE3_VIEW)
			MovieClip(mc["btn0"]).rotation = -180;
		
		addButtonEvents();
		
		_topView.viewLoadedSignal.dispatch(this);
	}
	
	private function addButtonEvents():void
	{
		for(var i:int = 0; i<3; i++)
		{
			if(i==0)
				MovieClip(mc["btn"+i]).width *= _topView.SCREEN_RATIO_FACTOR;
			
			MovieClip(mc["btn"+i]).addEventListener(MouseEvent.CLICK, btnClickEventHandler);				
		}		
	}
	
	private function btnClickEventHandler(e:MouseEvent):void
	{
		//trace(e.target.name as String);
		
		switch(e.target.name as String)
		{
			case "btn0":
			{				
				if(_topView.PREV_VIEW == Constants.MORE1_VIEW)
					_topView.showNewViewSignal.dispatch(Constants.MORE3_VIEW, Constants.SWIPE_LEFT);
				else if(_topView.PREV_VIEW == Constants.MORE3_VIEW)
					_topView.showNewViewSignal.dispatch(Constants.MORE1_VIEW, Constants.SWIPE_RIGHT);
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
					MovieClip(dropList).gotoAndStop(5);
					mc.addChild(mc["btn1"]);
					
					for(var i:int=0; i<3; i++)
					{
						MovieClip(dropList["_btn"+i]).width *= _topView.SCREEN_RATIO_FACTOR;
						
						if(i == 0)
							MovieClip(dropList["_btn"+i]).addEventListener(MouseEvent.CLICK, dropListButtonHandler);
					}
					
					MovieClip(dropList["transClip"]).addEventListener(MouseEvent.CLICK, closeDropList);
					dropList.x = 340;
					TweenLite.to(dropList, 0.35, {x:0});
					
					_topView.preventSwipe = true;					
				}
				else
				{
					TweenLite.to(dropList, 0.35, {x:340, onComplete:removeDropList});
				}				
				break;
			}
			case "btn2":
			{
				navigateToURL(new URLRequest("http://www.synonymy-game.com/#stats"), "_blank");
				break;
			}
			default:
			{
				break;
			}
		}
	}
	
	private function dropListButtonHandler(e:MouseEvent):void
	{
		switch(e.target.name)
		{
			case "btn0":
			{
				closeDropList(null);
				_topView.getHelpScreenSignal.dispatch();
				break;
			}
			default:
			{
				break
			}
		}
	}
	
	private function closeDropList(e:MouseEvent):void
	{
		TweenLite.to(dropList, 0.35, {x:340, onComplete:removeDropList});
		MovieClip(dropList["transClip"]).removeEventListener(MouseEvent.CLICK, closeDropList);
	}
	
	private function removeDropList():void
	{
		_topView.preventSwipe = false;
		
		if(!mc || !dropList)
			return;
		
		MovieClip(dropList["_btn0"]).removeEventListener(MouseEvent.CLICK, dropListButtonHandler);
		MovieClip(dropList["transClip"]).removeEventListener(MouseEvent.CLICK, closeDropList);
		
		mc.removeChild(dropList);
		dropList = null;
	}
	
	private function parseScoreData(dataString:String):void
	{
		if(dataString == "dataerror")
		{
			if(MovieClip(mc["dataInfo"]))
				MovieClip(mc["dataInfo"]).gotoAndStop(2);
			return;
		}
		
		if(MovieClip(mc["dataInfo"]))
			mc.removeChild(MovieClip(mc["dataInfo"]));
		
		var jsonObj:Object = JSON.parse(dataString);
				
		var num:int=0
		for(var key in jsonObj.data)
		{
			num++;
		}
		
		//trace("Total rows of Score data : " + num);
		
		var tintArray:Array = Constants.DIFFICULTY_COLOR_ARRAY;
		
		var table:Sprite = new Sprite();		
		
		var _y:int = 0;
		for(var i:int=0; i<num; i++)
		{
			var obj:Object = jsonObj.data[String(i)];
			
			var repeater:TopScoreRepeater = new TopScoreRepeater();
			repeater.initials.text = obj.username;
			repeater.passcode.text = obj.passcode;
			repeater.startwd.text = obj.startwd;
			repeater.endwd.text = obj.endwd;
			repeater.score.text = obj.score;
			repeater.difficulty.text = String(obj.difficulty).toLowerCase();
			
			var colorTransform:ColorTransform = repeater.transform.colorTransform;			
			
			switch(String(obj.difficulty).toLowerCase())
			{
				case "easiest":
				{
					colorTransform.color = tintArray[0];
					break;
				}
				case "easy":
				{
					colorTransform.color = tintArray[1];					
					break;
				}
				case "medium":
				{
					colorTransform.color = tintArray[2];					
					break;
				}
				case "hard":
				{
					colorTransform.color = tintArray[3];					
					break;
				}
				case "hardest":
				{
					colorTransform.color = tintArray[4];					
					break;
				}					
				default:
				{
					break;
				}
			}
			
			repeater.transform.colorTransform = colorTransform;
			
			table.addChild(repeater);
			repeater.x = 0;
			repeater.y = _y;
			
			_y += 80;
		}
		
		var square:Sprite = new Sprite();
		square.graphics.beginFill(0x000000, 0);
		square.graphics.drawRect(0,0,table.width,table.height);
		square.graphics.endFill();	
		table.addChild(square);
		addScrollingContent(table);
	}
	
	private function addScrollingContent(table:Sprite):void
	{		
		var w:int = 1900;
		var h:int = 730;
		var scroller:TouchScroller = new TouchScroller(w, h, _topView, table);
		scroller.x = 20;
		scroller.y = 160;
		mc.addChild(scroller);
	}
	
	private function destroyThis(e:Event):void
	{
		removeDropList();
		
		for(var i:int = 0; i<3; i++){
			MovieClip(mc.getChildByName("btn"+i)).removeEventListener(MouseEvent.CLICK, btnClickEventHandler);
		}
		
		while(this.numChildren > 0)
		{
			this.removeChildAt(0);
		}
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		//trace("MORE 2 VIEW IS GONE this : " + this);
	}
}
}
