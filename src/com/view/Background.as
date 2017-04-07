package com.view
{
import com.Constants;
import com.media.AIRMobileVideo;
import com.media.VideoPlayer;

import flash.display.Sprite;
import flash.system.Capabilities;
import flash.utils.setTimeout;

public class Background extends Sprite
{
	private var _width:int, _height:int;
	public var airvideo:AIRMobileVideo;
	public var airvideo2:VideoPlayer;
	
	public function Background()
	{
	}
	
	public function setUp(w:int, h:int):void
	{		
		_width = w;
		_height = h;
		
		//trace("Background.setUp() - _width : " + _width + " / _height : " + _height);
		
		playVideo();
	}
	
	public function playVideo():void
	{		
		setTimeout(startVid, 1500);
	}
	
	private function startVid():void
	{
		
		pauseVideo();
		
		if(Capabilities.os.indexOf("iPad") >= 0 || Capabilities.os.indexOf("iPhone") >= 0)  // || Capabilities.os.indexOf("Linux") >= 0
		{
			// in mac
			trace("Background.playVideo() - USING AIRMobileVideo_AS");
			
			
			
			airvideo = new AIRMobileVideo(Constants.VIDEO_BACKGROUND, _width, _height);
			this.addChild(airvideo);
		}
		else 
		{
			trace("Background.playVideo() - USING VideoPlayer");
			
			airvideo2 = new VideoPlayer(Constants.VIDEO_BACKGROUND, _width, _height);
			this.addChild(airvideo2);
		}
	}
	
	public function pauseVideo():void
	{	
		if(airvideo)
		{
			this.removeChild(airvideo);
			airvideo = null;
		}
		else if(airvideo2)
		{
			this.removeChild(airvideo2);
			airvideo2 = null;
		}
		else 
		{			
		}
		
	}
}
}
