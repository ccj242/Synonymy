package com.media
{
	
import com.Constants;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.events.StageVideoAvailabilityEvent;
import flash.geom.Rectangle;
import flash.media.SoundTransform;
import flash.media.StageVideo;
import flash.media.StageVideoAvailability;
import flash.net.NetConnection;
import flash.net.NetStream;
 
[SWF(backgroundColor="#000000")]
public dynamic class AIRMobileVideo extends Sprite
{
	protected var ns:NetStream;
	protected var nc:NetConnection;	
	protected var video:StageVideo;
	
	private var stageVideoAvail:Boolean;
	private var netStatusCache:String;
	private var volumeTransform:SoundTransform = new SoundTransform;
	private var useServerVideo:Boolean;
	
	private var _fileName:String;
	private var _width:int;
	private var _height:int;
	private var _parent:Object;
	
	public function AIRMobileVideo(fileName:String, w:int, h:int, parent:Object=null)
	{
		_fileName = fileName;
		_width = w;
		_height = h;
		_parent = parent;
		
		this.addEventListener(Event.ADDED_TO_STAGE, onAddedtoStage);
		this.addEventListener(Event.REMOVED_FROM_STAGE, killVideo);
	}
	
	public function getVideoTime():Number
	{
		return ns.time;
	}
	
	public function jumpToCuePoint(newpoint:Number):void
	{
		if(!useServerVideo)
			ns.seek(newpoint);
		else 
		{
			_fileName = Constants.SERVER_VIDEO_TUTORIAL_2;
			nullifyNetstream();
			initVideo();
			
			if(_parent)
				_parent.showPreloader();
		}
	}
	
	private function onAddedtoStage(e:Event):void
	{		
		//add transmc to give width and height 
		var transmc:TransMC = new TransMC();
		transmc.width = _width;
		transmc.height = _height;
		this.addChild(transmc);
		transmc.alpha = 0;

		stage.addEventListener( StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY , stageVideoState );
	}	
 
	protected function stageVideoState(e:StageVideoAvailabilityEvent):void
	{
		trace("stageVideoState : " + e.availability);
		
		stageVideoAvail = (e.availability == StageVideoAvailability.AVAILABLE);
		
		if(stage)
			initVideo();
		else
		{			
		}
	}
	
	private function initVideo():void
	{
		nc = new NetConnection();
		nc.connect(null);
		
		ns = new NetStream(nc);
		ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		ns.client = this;
 
		if (stageVideoAvail)
		{			
			var v:Vector.<StageVideo> = stage.stageVideos;
			trace("stageVideoState() - number of available videos : " + v.length);
			
			trace("stageVideoState() - viewport width : " + _width);
			
			video = stage.stageVideos[v.length-1];
			video.attachNetStream(null);
			
			video.viewPort = new Rectangle( 0, 0, _width , _height );
			video.attachNetStream( ns );
			
			ns.play(_fileName);
			ns.seek(0);
			ns.pause();
		}
	}
	
	private function netStatusHandler(e:NetStatusEvent)
	{
		trace("Net Status Event : " + e.info.code);
				
		if(netStatusCache != e.info.code)
		{
			switch (e.info.code)
			{
				case "NetStream.Play.StreamNotFound" :
				{
					trace("VideoPlayer.netStatusHandler() - Tutorial video is not Found");
					
					useServerVideo = true;
					_fileName = Constants.SERVER_VIDEO_TUTORIAL;
					nullifyNetstream();
					initVideo();
					
					//CHECK INTERNET CONNECTION
					var internetConnect:InternetConnectivity = new InternetConnectivity(_parent);
				}
				case "NetStream.Play.Start" :
				{
					ns.resume();
					
					if(_parent)
						_parent.hidePreloader();
					break;
				}
				case "NetStream.Buffer.Empty" : // notfies when video reaches end
				{
					if(_fileName == Constants.VIDEO_BACKGROUND) //loop background
					{
						ns.pause();
						ns.seek(0);
						ns.resume();
					}
					else if(_fileName == Constants.SERVER_VIDEO_TUTORIAL) //if server vid1 load server vid2
					{
						_parent.testTutorialVideoLocation.dispatch();
					}
					break;
				}
				case "NetStream.Buffer.Full" :
					break;					
				case "NetStream.Buffer.Flush" :
					break;
				case "NetStream.Seek.Notify" :
					break;
				case "NetStream.Seek.InvalidTime" :
					break;
				case "NetStream.Play.Stop" :
					break;
			}
			netStatusCache = e.info.code;
		}
	}
	
	public function setVolume(newVolume:Number):void
	{
		volumeTransform.volume = newVolume;
		ns.soundTransform = volumeTransform;
	}
 
	//captures client (this) metadata;
	public function onMetaData(obj:Object):void
	{
	}	
	
	public function onXMPData(obj:Object):void
	{		
	}
	
	private function nullifyNetstream():void
	{
		ns.close();		
		ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);		
		ns = null;
		
		video.viewPort = new Rectangle( 0, 0, 0, 0);
		video = null;
		
		nc.connect(null);
		nc.close();
		nc = null;
		
		netStatusCache = null;
		volumeTransform = null;
		
		//handleDeactivate(null);
	}
	
	private function killVideo(e:Event):void
	{
		nullifyNetstream();
		
		this.removeEventListener(Event.ADDED_TO_STAGE, onAddedtoStage);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, killVideo);
		
		//trace("VIDEO PLAYER IS GONE this : " + this);
	}
 
}
}