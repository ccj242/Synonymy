package com.clipboard
{
	import flash.display.Sprite;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.ClipboardTransferMode;
	
	public class ClipboardUtility extends Sprite
	{
		public function ClipboardUtility()
		{
		}
		
		public function copyText(text:String):void 
		{
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, text);
		}
		
		public function pasteText():String
		{
			if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT))
			{
				return String(Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT));
			} 
			else 
			{
				return null;
			}
		}
		
	}
}