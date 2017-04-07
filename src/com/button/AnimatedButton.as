package com.button
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class AnimatedButton extends MovieClip
	{
		public function AnimatedButton()
		{
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removeListener);
		}
		
		private function init(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(MouseEvent.MOUSE_DOWN, animate);
		}
		
		private function animate(e:MouseEvent):void
		{
			this.gotoAndPlay(2);
		}
		
		private function removeListener(e:Event):void
		{			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removeListener);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, animate);
		}
	}
}