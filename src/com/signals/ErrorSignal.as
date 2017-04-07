package com.signals
{
import org.osflash.signals.DeluxeSignal;

public class ErrorSignal
{
	public var notice:DeluxeSignal;
	private var _error:String;
	
	public function ErrorSignal()
	{			
		notice = new DeluxeSignal(this);
	}
	
	public function dispatchNotice(error:String):void
	{
		trace("ErrorSignal.dispatchNotice() - error : " + error);
		
		_error = error;
		notice.dispatch(_error);
	}
}
}
