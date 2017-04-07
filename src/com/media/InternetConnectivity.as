package com.media
{
import com.Constants;

import flash.events.StatusEvent;
import flash.net.URLRequest;

import air.net.URLMonitor;

import org.osflash.signals.DeluxeSignal;
import org.osflash.signals.Signal;

/**
 * ...
 * This Class can be used anytime to check internet connectivity
 * Example: Check if streaming video is possible
 * 
 *
 */

public class InternetConnectivity
{
	private var monitor:URLMonitor;
	private var _listeningObject:Object;
	public var internetConnectivitySignal:DeluxeSignal = new DeluxeSignal();
	
	public function InternetConnectivity(listeningObj:Object=null)
	{		
		_listeningObject = listeningObj;
		
		monitor = new URLMonitor(new URLRequest(Constants.SERVER_VIDEO_TUTORIAL));
		monitor.addEventListener(StatusEvent.STATUS, checkHTTP);
		monitor.start();
	}
		
	private function checkHTTP(e:StatusEvent):void
	{
		if (monitor.available)
		{			
			//trace("InternetConnectivity() - INTERNET IS AVAILABLE");
			internetConnectivitySignal.dispatch(true);
		} 
		else
		{
			//trace("InternetConnectivity() - NO INTERNET");
			
			if(_listeningObject)
				_listeningObject.noInternetConnectivitySignal.dispatch();
			else
				internetConnectivitySignal.dispatch(false);
		}
		monitor.stop();
	}
}
}