package com.model
{	
import com.Constants;

import flash.events.AsyncErrorEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

public class UrlLoad
{	
	private var loader:URLLoader;
	private var _faultback:Function;
	
	public function UrlLoad(json:String, url:String, callback:Function, faultback:Function)
	{
		_faultback = faultback;
		
		var vars:URLVariables = new URLVariables();
		var req:URLRequest = new URLRequest();
		req.method = URLRequestMethod.POST;
		req.data = json;
		req.url = Constants.BASE_URL + url;
		
		loader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, loader_complete);
		loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioFault);
		
		configureListeners(loader);
		loader.load(req);
		
		function loader_complete(e:Event):void
		{
			callback('success');
		}
		
		function loader_ioFault(e:IOErrorEvent):void
		{
			faultback('failure');
		}
	}	
	
	// LISTENERS
	private function configureListeners(dispatcher:IEventDispatcher):void
	{
		dispatcher.addEventListener(Event.COMPLETE, completeHandler);
		dispatcher.addEventListener(Event.OPEN, openHandler);
		dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
		dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
		dispatcher.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		dispatcher.addEventListener(ErrorEvent.ERROR, onError);
		dispatcher.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
		dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	}
	
	private function removeListeners(dispatcher:IEventDispatcher):void
	{
		dispatcher.removeEventListener(Event.COMPLETE, completeHandler);
		dispatcher.removeEventListener(Event.OPEN, openHandler);
		dispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
		dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
		dispatcher.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		dispatcher.removeEventListener(ErrorEvent.ERROR, onError);
		dispatcher.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
		dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	}
	
	// HANDLERS
	private function completeHandler(event:Event):void 
	{		
		removeListeners(loader);
		loader = null;
		
		trace("UrlLoad.completeHandler() - data: " + event.currentTarget.data); // this displays any echo or print_r etc. from PHP script
		//trace('UrlLoad.completeHandler() - loader disabled : ' + loader);
	}
	
	private function openHandler(event:Event):void
	{
		trace("openHandler: " + event);
	}
	
	private function progressHandler(event:ProgressEvent):void
	{
		//trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
	}
	
	private function httpStatusHandler(event:HTTPStatusEvent):void
	{
		trace("httpStatusHandler: " + event);
	}
	
	private function onNetStatus(event:NetStatusEvent):void
	{
		//trace("onNetStatus: " + event);
	}
	
	private function onError(event:ErrorEvent):void
	{
		trace("onError: " + event.type);
	}
	
	private function onAsyncError(event:AsyncErrorEvent):void
	{
		trace("onAsyncError: " + event);
	}	
	
	private function securityErrorHandler(event:SecurityErrorEvent):void
	{
		trace("securityErrorHandler: " + event);
	}	
	
	private function ioErrorHandler(event:IOErrorEvent):void
	{
		trace("ioErrorHandler: " + event);
		_faultback('failure');
	}
	
}//
}//