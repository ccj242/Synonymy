package com.media
{ 
       
import com.Constants;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.events.TimerEvent;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;


[SWF(backgroundColor="#000000")]
public class VideoPlayer extends MovieClip 
{
	private var nc:NetConnection;
	private var ns:NetStream;
	private var vid:Video;
	private var netStatusCache:String;
	private var volumeTransform:SoundTransform = new SoundTransform;
	private var netClient:Object;
	private var useServerVideo:Boolean;
	
	private var _fileName:String;
	private var _width:Number;
	private var _height:Number;
	private var _parent:Object;
	
	
	public function VideoPlayer(fileName:String, w:int, h:int, parent:Object=null):void
	{
		_fileName = fileName;
		_width = w;
		_height = h;
		_parent = parent;
				
		trace("VideoPlayer() - _fileName : " + _fileName);
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
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
			//trace("JUMP TO CUE PONT - SERVER VIDEO 2");
			
			_fileName = Constants.SERVER_VIDEO_TUTORIAL_2;
			nullifyNetstream();
			init(null);
			
			if(_parent)
				_parent.showPreloader();
		}
	}
	
	private function init(event:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, init );
		
		nc = new NetConnection;
		nc.connect(null);
		
		ns = new NetStream(nc);
		ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		
		netClient = new Object;
		ns.client = netClient;
				
		vid = new Video(_width, _height);
		this.addChild(vid);
		vid.attachNetStream(ns);
		
		ns.play(_fileName);
		ns.seek(0);
		ns.pause();
		
		//trace("VideoPlayer() - _fileName : " + _fileName);
		
		//setVolume(0);
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
					trace("VideoPlayer.netStatusHandler() - Video is not Found");
					
					useServerVideo = true;					
					
					if(_fileName == Constants.VIDEO_TUTORIAL)
						_fileName = Constants.SERVER_VIDEO_TUTORIAL;
					
					nullifyNetstream();
					init(null);
					
					//CHECK INTERNET CONNECTION
					
					var internetConnect:InternetConnectivity = new InternetConnectivity(_parent);
				}
				case "NetStream.Play.Start" :
				{
					playVideo();
					
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
					else
					{
						trace("DISPATCH END OF VIDEO");
						
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
	
	public function stopVideo():void
	{
		ns.seek(0);
		ns.pause();
	}
	public function pauseVideo():void
	{
		ns.pause();
		this.visible = false;
	}
	public function playVideo():void
	{
		ns.resume();
		this.visible = true;
	}
	
	public function setVolume(newVolume:Number):void
	{
		volumeTransform.volume = newVolume;
		ns.soundTransform = volumeTransform;
	}
	
	private function nullifyNetstream():void
	{
		stopVideo();
		
		ns.close();		
		ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);		
		ns = null;
		
		vid.clear();
		vid.attachNetStream(null);
		this.removeChild(vid);
		vid = null;
		
		nc.close();
		nc = null;
		
		netStatusCache = null;
		volumeTransform = null;
		netClient = null;
		
		//handleDeactivate(null);
	}
	
	private function killVideo(e:Event):void
	{		
		nullifyNetstream();
				
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, killVideo);
		
		//trace("VIDEO PLAYER IS GONE this : " + this);
	}
}
}
