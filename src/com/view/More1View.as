package com.view
{
import com.Constants;
import com.greensock.TweenLite;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import org.osflash.signals.DeluxeSignal;
import org.osflash.signals.Signal;
	
public class More1View extends MovieClip
{	
	private var _topView:MovieClip;
	
	private var container:MovieClip;
	private var mc:More1_MC;
	private var dropList:DropListMC;
	
	private var originalDifficultyNum:int;
	private var originalAudioStatus:int;
	
	public var returnToMenuView:DeluxeSignal = new DeluxeSignal();
	public var gotoMenuAndDisplaySelector:Signal = new Signal();
	
	public function More1View(topView)
	{
		//trace("-- More1View()");
		
		

		_topView = topView;
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event):void
	{
		//trace("More1View init();
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		container = new MovieClip;
		this.addChild(container);
		
		mc = new More1_MC;
		container.addChild(mc);

		setDifficultyMC();
		
		if(_topView.PREV_VIEW == Constants.MORE2_VIEW)
			MovieClip(mc["btn2"]).rotation = -90;
		
		//trace("More1View() - INITIAL audioStatus : " + _topView.userVO.audioStatus);
		
		
		//get original values to check for change when leaving view
		originalDifficultyNum = _topView.userVO.difficultyNum;
		originalAudioStatus = _topView.userVO.audioStatus;
		
		if(_topView.userVO.audioStatus == 0)
		{
			MovieClip(mc.music_mc).gotoAndStop(2);
		}
		else if(_topView.userVO.audioStatus == 1)
		{
			MovieClip(mc.music_mc).gotoAndStop(1);
		}
		else
		{
		}
		_topView.viewLoadedSignal.dispatch(this);
		
		addButtonEvents();
	}
	
	private function addButtonEvents():void
	{
		for(var i:int = 0; i<5; i++)
		{
			if(i==2)
			{
				if(MovieClip(mc["btn"+i]).rotation == -90)
				{
					MovieClip(mc["btn"+i]).height *= _topView.SCREEN_RATIO_FACTOR;
				}
				else
				{
					MovieClip(mc["btn"+i]).width *= _topView.SCREEN_RATIO_FACTOR;
				}
			}
			
			MovieClip(mc.getChildByName("btn"+i)).addEventListener(MouseEvent.CLICK, btnClickEventHandler);				
		}		
	}
	
	private function btnClickEventHandler(e:MouseEvent):void
	{
		trace(e.target.name as String);
		
		switch(e.target.name as String)
		{
			case "btn0":
			{
				if(_topView.AD_VERSION)
				{
					_topView.displayPurchasePopup();					
					
					//Allow toggling from Easyiest to Easy and back again					
					if(_topView.userVO.difficultyNum == 0)
						_topView.userVO.difficultyNum = 1;
					else
						_topView.userVO.difficultyNum = 0;
					
					_topView.resetGameVariables();
					
					setDifficultyMC();
					
				}
				else
				{
					_topView.userVO.difficultyNum += 1;
					
					if(_topView.userVO.difficultyNum >= Constants.DIFFICULTY_ARRAY.length)
						_topView.userVO.difficultyNum = 0;
						
					_topView.resetGameVariables();
						
					//mc.difficultyText.text = String(DIFFICULTY_ARRAY[_topView.userVO.difficultyNum]).toLowerCase();
					setDifficultyMC();
				}	
				break;
			}
			case "btn1":
			{
				var musicToggleMC:MovieClip = MovieClip(mc.getChildByName("music_mc"));				
				
				switch(musicToggleMC.currentFrame)
				{
					case 1:
					{
						musicToggleMC.gotoAndStop(2);
						_topView.userVO.audioStatus = 0;
						break;
					}
					case 2:
					{
						musicToggleMC.gotoAndStop(1);
						_topView.userVO.audioStatus = 1;
						break;
					}
					default:
					{
					}
				}
				
				break;
			}
			case "btn2":
			{				
				if(_topView.PREV_VIEW == Constants.MORE2_VIEW)
					_topView.showNewViewSignal.dispatch(Constants.MENU_VIEW, Constants.SWIPE_DOWN);
				else if(_topView.PREV_VIEW == Constants.MENU_VIEW)
					_topView.showNewViewSignal.dispatch(Constants.MORE2_VIEW, Constants.SWIPE_LEFT);
				else
				{					
				}
				
				break;
			}
			case "btn3":
			{
				if(!dropList)
				{
					dropList = new DropListMC;
					mc.addChild(dropList);
					mc.addChild(mc["btn3"]);
					
					for(var i:int=0; i<3; i++)
					{
						MovieClip(dropList["btn"+i]).width *= _topView.SCREEN_RATIO_FACTOR;
						
						if(i == 0)
							MovieClip(dropList["btn"+i]).addEventListener(MouseEvent.CLICK, dropListButtonHandler);
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
			case "btn4":
			{
				gotoMenuAndDisplaySelector.dispatch();
				
				break;
			}			
			default:
			{
				break;
			}
		}
		
		//trace("More1View() - UPDATED audioStatus : " + _topView.userVO.audioStatus);
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
		
		MovieClip(dropList["btn0"]).addEventListener(MouseEvent.CLICK, dropListButtonHandler);
		MovieClip(dropList["transClip"]).removeEventListener(MouseEvent.CLICK, closeDropList);
		
		mc.removeChild(dropList);
		dropList = null;
	}
	
	private function setDifficultyMC():void
	{
		MovieClip(mc.difficulty_mc).gotoAndStop(_topView.userVO.difficultyNum + 1);
		
		//ADD VERSION MUST STAY ON EASIEST
		/*if(_topView.AD_VERSION)
		{
		_topView.userVO.difficultyNum = 0;
		MovieClip(mc.difficulty_mc).gotoAndStop(1);
		}*/
		
	}
	
	private function destroyThis(e:Event):void
	{
		_topView.closePurchasePopup();
		
		//UPDATE DATABASE ON EXIT - If a setting has changed
		if(originalDifficultyNum != _topView.userVO.difficultyNum || originalAudioStatus != _topView.userVO.audioStatus)
			_topView.userModel.updateUserTable();
		
		removeDropList();
		
		for(var i:int = 0; i<5; i++)
		{
			MovieClip(mc.getChildByName("btn"+i)).removeEventListener(MouseEvent.CLICK, btnClickEventHandler);
		}
		
		while(this.numChildren > 0)
		{
			this.removeChildAt(0);
		}
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		//trace("MORE 1 VIEW IS GONE this : " + this);
	}
}
}