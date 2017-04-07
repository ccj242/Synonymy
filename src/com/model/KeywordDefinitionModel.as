package com.model
{
	import com.Constants;
	
	import org.osflash.signals.DeluxeSignal;
	
	
public class KeywordDefinitionModel
{
	private var numItems:int=4;
	
	public var service:DataService = new DataService();
	public var keywordDefinitionSignal:DeluxeSignal = new DeluxeSignal();

	public function KeywordDefinitionModel()
	{		
	}
	
	public function queryDatabase(keyWord:String=null):void
	{
		//trace("KeywordDefinitionModel :: queryDatabase() - keyWord : " + keyWord);
				
		var stmtText:String = "SELECT * FROM "+Constants.DEFINITIONS_TABLE+" WHERE KeyWord LIKE '"+keyWord+"';";	
		
		service.dataReturnedSignal.addOnce(queryResult);
		service.queryDatabase(stmtText);
	}
	
	private function queryResult(dataObj:Object)
	{	
		var defString:String="";
		var num:int = 0;
		for each(var row:Object in dataObj.data)
		{			
			for each(var item:String in row)
			{
				//trace("		- num : " + num);
				
				if(item != null && item != row.KeyWord && item != row.Syllab)
				{
					if(num < numItems)
					{
						//trace("num < numItems");
						defString += item + " \n";
					}
					else
					{
						//trace("num == numItems");
						break;
					}
					++num;
				}				
			}
		}
		keywordDefinitionSignal.dispatch(defString);
	}
	
}
}