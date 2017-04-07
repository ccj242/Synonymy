/**
 * Get startWord and endWord based on the PASSWORD if in challenge mode
*/

package com.model
{
	import com.Constants;
	
	import org.osflash.signals.DeluxeSignal;
	import org.osflash.signals.Signal;
	
	
	public class NewGameWordGenerator
	{
		private var charsArray:Array = ["0","1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", 
							"H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
		
		private var cnt1:int;
		private var cnt2:int;
		private var row2:int
		private var startWord:String;
		private var endWord:String;
		private var startWordVector:String;
		private var endWordVector:String;
		private var testPhase:int;
		
		private var _difficulty:String;
		private var _password:String;
		private var _pw10:int;
		
		private var service:DataService = new DataService();
		
		public var newGameWordsGeneratedSignal:DeluxeSignal = new DeluxeSignal();
		//public var failedVerisimilitudeSignal:Signal = new Signal();
		
		public function NewGameWordGenerator(difficulty:String, password:String, countRow1:int, countRow2:int)
		{
			_difficulty = difficulty;
			_password = password;
			cnt1 = countRow1;
			cnt2 = countRow2;
			
			var pw10:int = getBase10Number(_password);
			trace("NewGameWordGenerator() - resolve password(36) to base10 : " + pw10);
			
			resolvePassword(pw10);
		}
		
		private function getBase10Number(base36String:String):int
		{			
			return base36Decode(_password, charsArray); //back to original base10 value generated in NewGameController from base36			
		}
		
		private function resolvePassword(pw10:int):void
		{
			_pw10 = pw10;
			var row1:int;		
			
			//CALCULATE OUR VARIABLE
			//X = passcode(base10) mod ((# of words in difficulty column) * (# of words in startword column)) [make this latter a variable in case we expand the database]
			
			var varX:int = _pw10 % (cnt2 * cnt1);
			trace("NewGameWordGenerator() - varX : " + varX);			
			
			//DERTERMINE ROW TO SELECT IN BOTH STARTWORD and DIFFICULTY columns
			
			//startword: (displacement from the top, starting at zero) = X(described above) / (# of words in difficulty column)
						
			row1 = Math.ceil(varX / cnt2);
			
			//goalword(displacement from the top, starting at zero) = X(described above) mod (# of words in difficulty column)			
						
			row2 = varX % cnt2;
			
			trace("STARTWORD retrieve row num : " + row1);
			trace(_difficulty + " retrieve row num : " + row2);

			service.dataReturnedSignal.addOnce(onReturnStartWord);
			service.queryDatabase("SELECT rowid, STARTWORD FROM "+Constants.GOAL_DIFFICULTY_TABLE+" LIMIT  "+row1+",1;");
		}		
		
		private function onReturnStartWord(dataObj):void
		{
			for each(var row:Object in dataObj.data)
			{
				startWord = row.STARTWORD;
				trace("*** STARTWORD row[rowid] : " + row["rowid"] + " / startWord : " + startWord);
			}
			
			service.dataReturnedSignal.addOnce(onReturnEndWord);
			service.queryDatabase("SELECT rowid, "+_difficulty+" FROM "+Constants.GOAL_DIFFICULTY_TABLE+" LIMIT  "+row2+",1;");
		}
		
		private function onReturnEndWord(dataObj)
		{
			for each(var row:Object in dataObj.data)
			{
				endWord = row[_difficulty];
				trace("*** ENDWORD row[rowid] : " + row["rowid"] + " / endword : " + endWord);
			}
			
			testPhase = 1;
			
			
			//CHECK THAT WORDS DON'T MATCH			
			if(endWord != startWord)
				testVerisimilitude(startWord);
			else
			{
				trace("*** FAIL FAIL FAIL :: ENDWORD endWord : " + endWord + " / startWord : " + startWord);
				
				//failedVerisimilitudeSignal.dispatch();
				failedVerisimilitude();
			}
		}
		
		private function failedVerisimilitude():void
		{
			var new_pw10:int = _pw10 * 2 + 4;			
			resolvePassword(new_pw10);
		}
		
		private function testVerisimilitude(word:String):void
		{
			//trace("word : " + word);
			
			service.dataReturnedSignal.addOnce(onTestResultsReturned);
			service.queryDatabase("SELECT * FROM "+Constants.SYNONYMS_TABLE+" WHERE KeyWord LIKE '"+word+"';");
		}		
		
		private function onTestResultsReturned(dataObj:Object):void
		{
			var testWord:String = endWord;
			if(testPhase == 2)
				testWord = startWord;
			
			//trace("NewGameWordGenerator.onTestResultsReturned() - testPhase : " + testPhase);
			//trace("NewGameWordGenerator.onTestResultsReturned() - testWord : " + testWord);
			
			var arr:Array = new Array;
			for each(var row:Object in dataObj.data)
			{				
				for each(var item:String in row)
				{
					if(item == row.KeyWord)
					{
						//trace("		- KeyWord : " + item);
					}
					else if(item == row.KeyWordVector)
					{
						if(testPhase == 1)
						{
							//trace("		- KeyWordVector : " + item);
							
							// GET VECTOR DATA FOR STARTWORD
							startWordVector = item
						}
						else
						{
							//trace("END WORD VECTOR : " + item);
							
							endWordVector = item;
						}
						
					}
					else if(item == row.Size)
					{
						//trace("		- START WORD SIZE : " + item);
					}
					else if(item != null)
					{
						var wrd:Array = item.split("$");
						arr.push(wrd[0]);
						
						//trace("		- Match : " + wrd[0]);
					}
					else
					{
						//do nothing
					}
				}
			}
						
			// 1) check startword not in endword syns array
			var index:int = arr.indexOf(testWord);
			
			if(index >= 0)
			{
				//testVerisimilitude FAILED");
				//failedVerisimilitudeSignal.dispatch();
				
				failedVerisimilitude();
			}
			else
			{				
				if(testPhase == 1)
				{
					trace("NewGameWordGenerator - START WORD ARRAY : " + arr.toString());
					
					// 2) check endword not in startword syns array
					testPhase = 2;
					testVerisimilitude(endWord);
				}
				else
				{
					trace("NewGameWordGenerator - VERISIMILITUDE SUCCESSFUL");
					trace("NewGameWordGenerator - GOAL WORD ARRAY : " + arr.toString());
					
					//testVerisimilitude successful
					newGameWordsGeneratedSignal.dispatch(startWord, endWord, _password, startWordVector, endWordVector, arr);					
				}
			}
		}
		
		// hexatridecimal --> int
		// convert to base10
		public function base36Decode(str:String, arr:Array):int
		{
			var strArray:Array = str.split("");
			var result:int = 0;
			var pow:int = 0;
			for (var i:int=strArray.length-1; i>=0; i--)
			{
				var c:String = strArray[i];
				var pos:int = arr.indexOf(c);
				
				if (pos > -1)
					result += pos * Math.pow(arr.length, pow);
				else
					return -1;
				
				pow++;
			}
			return result;
		}
	}
}