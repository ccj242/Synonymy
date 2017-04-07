package com.view
{
import com.controller.GameDataController;
import com.model.DataService;

import flash.display.MovieClip;
import flash.events.Event;

public class GameView extends MovieClip
{	
	private var _currentWord:String;
	private var _dataObj:Object;
	private var _topView:MovieClip;
	
	private var gamePlayView:GamePlayView;	
	private var container:MovieClip;
	private var service:DataService;
	
	
	public function GameView(topView:MovieClip)
	{		
		//trace("-- GameView() - currentWord : " + currentWord);

		_topView = topView;		
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event):void
	{
		//trace("GAME_VIEW - init()");
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroyThis);	
		
		_topView.viewLoadedSignal.dispatch(this);
		
		service = new DataService();
		
		var gameDataController:GameDataController = new GameDataController(_topView);
		_topView.gameDataUpdated.add(loadGamePlayView);
		gameDataController.checkCurrentData();
	}	
	
	private function loadGamePlayView(blurValue:int):void
	{		
		killContainer();
		
		container = new MovieClip;
		this.addChild(container);
		
		gamePlayView = new GamePlayView(_topView, blurValue);
		container.addChild(gamePlayView);
	}
	
	private function killContainer():void
	{
		if(!container)
			return;
		
		while(container.numChildren > 0)
		{
			container.removeChildAt(0);
		}
		this.removeChild(container);
		container = null;
	}
	
	private function destroyThis(e:Event):void
	{		
		_dataObj = null;
		
		killContainer();
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroyThis);
		
		//trace("GAME VIEW IS GONE this : " + this);
	}
}
}