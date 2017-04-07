package com.controller
{
	import com.Constants;
	import com.model.DataService;
	
	import flash.geom.Vector3D;
	
	import org.osflash.signals.DeluxeSignal;
	
	
	/**
	 * This is loaded each time a Synonym is selected (in WordBlockView)
	 * 
	 * This class handles all of the 3D vector logic
	 * 
	 */

public class SFXController
{	
	private var _topView:Object;
	private var currentWord:String;
	private var currentWordVector:String;
	
	private var previousWord:String;
	private var previousWordVector:String;
	
	private var endWord:String;
	private var endWordVector:String;
		
	private var F:int; // frequency
	
	private var service:DataService = new DataService();
	
	public var specialEffectsControllerUpdated:DeluxeSignal = new DeluxeSignal();
		
	public function SFXController(topView:Object)
	{
		_topView = topView;
		
		currentWord = _topView.gameDataVO.currentWord;
		currentWordVector = _topView.gameDataVO.currentWordVector;
		
		previousWord = _topView.gameDataVO.previousWord;
		previousWordVector = _topView.gameDataVO.previousWordVector;
		
		endWord = _topView.gameDataVO.endWord;
		endWordVector = _topView.gameDataVO.endWordVector;
		
		/*trace("SFXController() - currentWord : " + currentWord);
		trace("SFXController() - currentWordVector : " + currentWordVector);
		
		trace("SFXController() - previousWord : " + previousWord);
		trace("SFXController() - previousWordVector : " + previousWordVector);
		
		trace("SFXController() - endWord : " + endWord);
		trace("SFXController() - endWordVector : " + endWordVector);*/
	}
	
	public function calculateVectorDistance():void
	{		
		//trace("SFXController.calculateVectorDistance() - notification : " + _notification);
		
		service.dataReturnedSignal.addOnce(calculateSpecicalEffects);
		service.queryDatabase("SELECT * FROM Frequency WHERE WORD LIKE '" + currentWord+"'");
	}
		
	public function calculateSpecicalEffects(dataObj:Object):void
	{		
		var frequency:int;
		for each(var row:Object in dataObj.data)
		{
			trace("row.WORD : " + row.WORD + " / row.FREQUENCY : " + row.FREQUENCY);
			
			frequency = int(row.FREQUENCY);
		}
				
		// F = 13-(frequency/2.5)^0.66257
		
		F = 13 - Math.pow(frequency/2.5, 0.66257);
		if(F > 12)
			F = 12;
		if(F < 0)
			F = 0;
		
		//trace("F - frequency adjusted : " + F);
		
		var Vend:Array = endWordVector.split(",");
		var vectEndWd:Vector3D = new Vector3D();
		vectEndWd.setTo(int(Vend[0]), int(Vend[1]), int(Vend[2]));
		//trace("vectEndWd : " + vectEndWd);
		
		var Vcurrent:Array = currentWordVector.split(",");
		var vectCurrentWd:Vector3D = new Vector3D();
		vectCurrentWd.setTo(int(Vcurrent[0]), int(Vcurrent[1]), int(Vcurrent[2]));
		//trace("vectCurrentWd : " + vectCurrentWd);
		
		//((sqrt((x[goalword]-x[keyword])^2+(y[goalword)-y[keyword])^2+(z[goalword)-z[keyword])^2))/100)^1.077
		
		//BLUR ::
		// 1) if GoalWord is in KeyWord Synonyms (i.e. Syn Array position 2) - blur is 0
		// 2)  =((sqrt((x[goal]-x[current])^2+(y[goal]-y[current])^2+(z[goal]-z[current])^2)/100)^.867)-1
		// where MAX is 17 and MIN is 0.5
		
		var nextBlur:Number = ( Math.pow( ( Math.sqrt( Math.pow(vectEndWd.x - vectCurrentWd.x, 2) + Math.pow(vectEndWd.y - vectCurrentWd.y, 2) + Math.pow(vectEndWd.z - vectCurrentWd.z, 2) ) ) / 100 , 0.867) )-1;
		//trace("nextBlur (blur value) : " + nextBlur);
		
		//trace("nextBlur : " + nextBlur);
		
		nextBlur = Math.round(nextBlur*2);
		
		if(nextBlur >= 17)
			nextBlur = 17
		else if(nextBlur <= 0.5)
			nextBlur = 0.5;
		else
		{
			//
		}		
		//trace("nextBlur - range adjusted : " + nextBlur);
			
		var D:int = Math.pow( ( Math.sqrt( Math.pow(vectEndWd.x - vectCurrentWd.x, 2) + Math.pow(vectEndWd.y - vectCurrentWd.y, 2) + Math.pow(vectEndWd.z - vectCurrentWd.z, 2) ) ) / 100 , 1.077);
		//trace("D (distance between words) : " + D);
		
		if(_topView.gameDataVO.endWordIsSynonym)
		{
			D = 36;
		}				
		else if(D >= 35)
		{
			D = 35
		}			
		else if(D < 1)
		{
			D = 1;
		}
		else
		{
			//
		}		
		//trace("D - range adjusted : " + D);		
		
		//PIANO SOUND 
		
		// “Xy” where:
		//X (int: range 1 - 48)
		//  adjusted relative vector distance minus the adjusted Frequency integer from the frequency table
		
		var X:Number = D + F;		
		
		// y: 
		// a - if move is closer to end
		// b - same or worse
		// c - GAME IS WON
		
		var sub:String = "a";
		
		if(_topView.gameDataVO.gameIsWon)
		{
			X = _topView.gameDataVO.previousX;
			sub = "c";
		}
		else if(X < _topView.gameDataVO.previousX) //good move
		{
			sub = "a";
		}
		else if(X >= _topView.gameDataVO.previousX) //bad move
		{
			sub = "b";
		}
		else
		{
			//
		}
		var pianoTrack:String = String(X) + sub;
		
		// caputure X value for next comparison
		_topView.gameDataVO.previousX = X;
		
		//DefinitionView and GamPlayView listen for this
		specialEffectsControllerUpdated.dispatch(nextBlur, pianoTrack);
		
		//trace("DISPATCHING PIANO TRACK SIGNAL - nextBlur : " + nextBlur);
		//trace("DISPATCHING PIANO TRACK SIGNAL - pianoTrack : " + pianoTrack);
		
	}	
	
}
}