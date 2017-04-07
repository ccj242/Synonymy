package com.controller
{

import com.Constants;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

import org.osflash.signals.DeluxeSignal;
	

public class DataRequestController
{
	private var loader:URLLoader;
	
	public var topScoreDataReturnedSignal:DeluxeSignal = new DeluxeSignal();
	
	public function DataRequestController()
	{
		//trace("DataRequestController()");
	}
	
	public function requestData():void
	{
		var req:URLRequest = new URLRequest();
		req.url = Constants.BASE_URL + Constants.PHP_REQUEST;
		
		loader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.TEXT;
		loader.addEventListener(Event.COMPLETE, requestCompleteHandler);
		loader.addEventListener(IOErrorEvent.IO_ERROR, request_ioFault);
		loader.load(req);
	}
	
	private function requestCompleteHandler(e:Event):void
	{
		//trace("completeHandler: " + loader.data + " - is string : " + (loader.data is String));
		
		topScoreDataReturnedSignal.dispatch(loader.data);
	}
	
	function request_ioFault(e:IOErrorEvent):void
	{
		trace("Data request failure! : " + e.target.data);
		
		topScoreDataReturnedSignal.dispatch("dataerror");
		
	}
}	
}