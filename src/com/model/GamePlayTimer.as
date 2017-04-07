package com.model
{
	public class GamePlayTimer
	{
		private var aggregateTimes:Array = [];
		
		private var _startTime:int = -1;
		
		public function GamePlayTimer()
		{
		}
		
		public function setAggStartTime():void
		{
			_startTime = Math.round(new Date().valueOf()/1000);
			
			//trace("GamePlayTimer.setAggStartTime() - _startTime : " + _startTime);
		}
		public function setAggStopTime():void
		{		
			//capture set of start and stop times
			if(_startTime >= 0)
			{
				var stopTime:int = Math.round(new Date().valueOf()/1000);
				//trace("GamePlayTimer.setAggStopTime() - stopTime : " + stopTime);
				
				var arr:Array = [_startTime, stopTime];
				aggregateTimes.push(arr);
			}
			//else
				//throw new Error("error GamePlayTimer - stop time has no coresponding start time");
				
			
			//reset _startTime
			_startTime = -1;
		}
		
		public function getAggregateTime():int
		{
			//stop last time segment
			
			if(_startTime >= 0)
				setAggStopTime();
			
			var total:int=0;
			for(var i:int=0; i<aggregateTimes.length; i++)
			{
				var dur:int = aggregateTimes[i][1] - aggregateTimes[i][0];				
				total += dur;
			}
			
			//trace("GamePlayTimer() - TOTAL AGGREGATE DURATION : " + total);
			
			return total;
		}
		
		public function get startTime():int
		{
			return this._startTime;
		}
	}
}