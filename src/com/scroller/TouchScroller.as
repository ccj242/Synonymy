package com.scroller
{
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

/** 
 * modified code originally written by:
 * Michael Ritchie (www.thanksmister.com) 
 * */


public class TouchScroller extends Sprite
{
	private var listHitArea:Shape;
	public var list:Sprite;
	private var listHeight:Number;
	private var listWidth:Number;
	private var scrollListHeight:Number; // full height of scrollable content?
	private var scrollAreaHeight:Number; // visible area ?
	private var listTimer:Timer; // timer for all events
		
	//private var scrollBar:Shape;
	private var lastY:Number = 0; // last touch position
	private var firstY:Number = 0; // first touch position
	private var listY:Number = 0; // initial list position on touch 
	private var diffY:Number = 0;;
	private var inertiaY:Number = 0;
	private var minY:Number = 0;
	private var maxY:Number = 0;
	private var totalY:Number;
	private var scrollRatio:Number = 40; // how many pixels constitutes a touch
	
	private var scrollArea:MovieClip;
	private var _scrollItem:Sprite;
	private var _topView:MovieClip;
		
	private var isTouching:Boolean = false;
	private var _restrictedScrolling:Boolean;

	
	public function TouchScroller(w:Number, h:Number, topView:MovieClip, scrollItem:Sprite, restrictedScrolling:Boolean=false)
	{
		_topView = topView;
		_scrollItem = scrollItem;
		
		listWidth = w; 
		listHeight = h;
		scrollAreaHeight = listHeight;
		
		_restrictedScrolling = restrictedScrolling;

		this.addEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.REMOVED_FROM_STAGE, destroy);
	}
	
	private function init(e:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, init);		
		
		//add mouse wheel functionality if desktop version
		if(_topView.DESKTOP_VERSION)
		{
			this.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		}
		//or use touch scrolling
		else
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownEvent);
			
			listTimer = new Timer(33);
			listTimer.addEventListener( TimerEvent.TIMER, onListTimer);
			listTimer.start();
		}		
		
		scrollListHeight = 0;
		
		creatList();
		
		createSWipeArea();
		
		addListItem();
	}	
	
	/**
	 * Create an empty list and the list hit area, which is also its mask.
	 * */
	private function creatList():void
	{
		if(!listHitArea){
			listHitArea = new Shape();
			this.addChild(listHitArea);
		}
		
		listHitArea.graphics.clear();
		listHitArea.graphics.beginFill(0x000000, 0);
		listHitArea.graphics.drawRect(0, 0, listWidth, listHeight)
		listHitArea.graphics.endFill();
		
		if(!list){
			list = new Sprite();
			this.addChild(list);
		}
		list.mask = listHitArea;
	}
	
	private function createSWipeArea():void
	{
		if(scrollArea)
			return;
		
		scrollArea = new MovieClip;
		
		scrollArea.graphics.clear();
		scrollArea.graphics.beginFill(0xff0000, 0);
		if(_restrictedScrolling)
		{
			scrollArea.graphics.drawRect(0, 0, 400, listHeight);
			
			scrollArea.graphics.beginFill(0xff00ff, 0);
			scrollArea.graphics.drawRect(500, 0, 1260, listHeight-515);
						
			
			scrollArea.graphics.beginFill(0xffff00, 0);
			scrollArea.graphics.drawRect(0, listHeight, 400, listHeight);
			
			scrollArea.graphics.beginFill(0x0000ff, 0);
			scrollArea.graphics.drawRect(500, listHeight-515, 415, 200);
			
			scrollArea.graphics.beginFill(0xffffff, 0);
			scrollArea.graphics.drawRect(1020, listHeight-515, 730, 200);
			
			scrollArea.graphics.beginFill(0x00ff00, 0);
			scrollArea.graphics.drawRect(500, listHeight-315, 250, 310);
			scrollArea.graphics.drawRect(1190, listHeight-315, 570, 310);
		}
		else
		{
			scrollArea.graphics.drawRect(0, 0, listWidth, listHeight);
		}
		
		scrollArea.graphics.endFill();
		
		this.addChild(scrollArea);
	}
	
	private function addListItem():void
	{		
		list.addChild(_scrollItem);
		scrollListHeight = _scrollItem.height;
		
		// add background to scroll list after scroll list height is known
		list.graphics.clear();
		list.graphics.beginFill(0, 0);
		list.graphics.drawRect(0, 0, listWidth, scrollListHeight);
		list.graphics.endFill();
	}
	
	private function mouseWheelHandler(event:MouseEvent):void 
	{		
		if ((event.delta > 0)) 
		{
			list.y += (event.delta * 40);
		}
		else if ((event.delta < 0))  
		{
			list.y += (event.delta * 40);
		}
		
		var listMax = list.height - list.height * 0.1;
		
		// constrain scrolling
		if(_restrictedScrolling)
		{
			if(list.y >= 0)
				list.y = 0;
			else if(list.y <= -listMax+660)
				list.y = -listMax+660;
		}
		else
		{
			if(list.y >= 0)
				list.y = 0;
			else if(list.y <= -listMax+300)
				list.y = -listMax+300;
		}
	}
	
	
	/**
	 * Detects first mouse or touch down position.
	 * */
	protected function mouseDownEvent(e:Event):void 
	{
		_topView.scrollingEventSignal.dispatch(true);
		
		scrollArea.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveEvent);
		scrollArea.addEventListener(MouseEvent.MOUSE_UP, mouseUpEvent);
		scrollArea.addEventListener(MouseEvent.MOUSE_OUT, mouseUpEvent);
		scrollArea.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownEvent);

		inertiaY = 0;
		firstY = mouseY;
		listY = list.y;
		minY = Math.min(-list.y, -scrollListHeight + listHeight - list.y);
		maxY = -list.y;
	}
	
	/**
	 * List moves with mouse or finger when mouse down or touch activated. 
	 * If we move the list moves more than the scroll ratio then we 
	 * clear the selected list item. 
	 * */
	protected function mouseMoveEvent(e:MouseEvent):void 
	{
		totalY = mouseY - firstY;

		if(Math.abs(totalY) > scrollRatio) isTouching = true;

		if(isTouching)
		{
			diffY = mouseY - lastY;	
			lastY = mouseY;

			if(totalY < minY)
				totalY = minY - Math.sqrt(minY - totalY);
			
			if(totalY > maxY)
				totalY = maxY + Math.sqrt(totalY - maxY);
			
			list.y = listY + totalY;
		}
	}
	
	/**
	 * Handles mouse up and begins animation. This also deslects
	 * any currently selected list items. 
	 * */
	protected function mouseUpEvent(e:MouseEvent):void 
	{
		_topView.scrollingEventSignal.dispatch(false);
		_topView._stage.focus = _topView._stage; // retain focus needed for desktop app.
		
		scrollArea.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownEvent);
		scrollArea.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveEvent);
		scrollArea.removeEventListener(MouseEvent.MOUSE_UP, mouseUpEvent);
		scrollArea.removeEventListener(MouseEvent.MOUSE_OUT, mouseUpEvent);
			
		if(isTouching)
		{
			isTouching = false;
			inertiaY = diffY;
		}
	}
	
	/**
	 * Timer event handler.  This is always running keeping track
	 * of the mouse movements and updating any scrolling
	 * 
	 * Mouse x,y coords come through as negative integers when this out-of-window tracking happens. 
	 * The numbers usually appear as -107374182, -107374182. To avoid having this problem we can 
	 * test for the mouse maximum coordinates.
	 * */
	private function onListTimer(e:Event):void
	{			
		// scroll the list on mouse up
		if(!isTouching) {
			
			if (list.y > 0)
			{
				inertiaY = 0;
				list.y *= 0.3;
				
				if(list.y < 1)
					list.y = 0;
			}
			else if(scrollListHeight >= listHeight && list.y < listHeight - scrollListHeight)
			{
				inertiaY = 0;
				var diff:Number = (listHeight - scrollListHeight) - list.y;
				
				if(diff > 1)
					diff *= 0.1;
				
				list.y += diff;
			}
			else if (scrollListHeight < listHeight && list.y < 0)
			{
				inertiaY = 0;
				list.y *= 0.8;
				
				if(list.y > -1)
					list.y = 0;
			}
			
			if( Math.abs(inertiaY) > 1)
			{
				list.y += inertiaY;
				inertiaY *= 0.9;
			} 
			else
			{
				inertiaY = 0;
			}
		} 
		else
		{			
		}
	}
	
	private function removeListItems():void
	{
		if(listTimer)
			listTimer.stop();
		
		isTouching = false;
		scrollAreaHeight = 0;
		scrollListHeight = 0;
		
		while(list.numChildren > 0)
		{
			list.removeChildAt(0);
		}
	}

	protected function destroy(e:Event):void
	{
		_topView.scrollingEventSignal.dispatch(false);
		_topView._stage.focus = _topView._stage; // retain focus needed for desktop app.
		
		this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		this.removeListItems();
		
		if(listTimer) 
		{		
			listTimer.removeEventListener(TimerEvent.TIMER, onListTimer);
			listTimer = null;
		}
		removeChild(list);
		removeChild(listHitArea);
	}
}
}