package com.media
{
import com.Constants;

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;


public class SoundFXPlayer
{
	private var _topView:Object;
	private var sample:Sound;
	private var channel:SoundChannel;
	private var trans:SoundTransform;
		
	private var pianoPrefix:String = "audio/PianoSamples/";	
	private var strumPrefix:String = "audio/Strums/";
	private var strumNum:int;
	private var maxStrum:int = 9;

	private var volume:Number = 0.75;
	
	public function SoundFXPlayer(topView:Object)
	{
		_topView = topView;
		
		// this is a singleton so this is only done once then we +1 each time
		strumNum = Math.floor( Math.random()*9 ) + 1;
	}
	
	public function init():void
	{
	}
	
	public function playSound(type:String, pianoFileName:String=null):void
	{
		//trace("SFX SOUND - type: " + type);
		
		if(_topView.userVO.audioStatus == 0)
			return;
		
		if(type == Constants.STRUM_SOUND)
		{
			var posNeg = int(Math.random()*2) - 1 | 1;
			
			strumNum += posNeg;
			
			if(strumNum > maxStrum)
				strumNum = maxStrum-1;
			else if(strumNum < 1)
				strumNum = 2;
			
			//trace("SoundFXPlayer - strumNum : " + strumNum);
			
			playFile(String(strumPrefix + "S" + strumNum + ".mp3"));
		}
		else if(type == Constants.PIANO_SOUND)
		{
			playFile(String(pianoPrefix + pianoFileName + ".mp3"));
		}
	}
	
	public function playFile(fileName):void
	{
		//trace("SoundFXPlayer - fileName : " + fileName);
		
		sample = new Sound(); 
		sample.load(new URLRequest(fileName));
		
		trans = new SoundTransform(volume);
		
		sample.play(0, 0, trans);
	}
}
}
