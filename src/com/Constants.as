package com
{

	public class Constants
	{
		//swiping strings
		public static const SWIPE_LEFT = "swipeLeft";
		public static const SWIPE_RIGHT = "swipeRight";
		public static const SWIPE_UP = "swipeUp";
		public static const SWIPE_DOWN = "swipeDown";		
		
		//button names
		public static const NEW_GAME:String = "newGame";
		public static const CONTINUE:String = "continue";
		public static const TUTORIAL:String = "tutorial";
		public static const MORE:String = "more";	
		public static const MUSIC_TOGGLE:String = "toggleMusic";
		public static const COLOR_TOGGLE:String = "toggleColor";
		public static const CLOSE:String = "close";		
		
		//view names as strings
		public static const MENU_VIEW:String = "MenuView";
		public static const GAME_VIEW:String = "GameView";
		public static const MORE1_VIEW:String = "More1View";
		public static const MORE2_VIEW:String = "More2View";
		public static const MORE3_VIEW:String = "More3View";
		public static const TUTORIAL_VIEW:String = "TutorialView";
		public static const DEFINITION_VIEW:String = "DefinitionView";
		public static const SUCCESSVIEW:String = "SuccessView";
		public static const SUCCESS_SUB1_VIEW:String = "SuccessSub1View";
		public static const SUCCESS_SUB2_VIEW:String = "SuccessSub2View";
		
		//sound commands
		public static const PAUSE_SOUND:String = "pauseSound";
		public static const PLAY_SOUND:String = "playSound";
		public static const PLAY_EFFECTS_ONLY:String = "playEffectsOnly";
		public static const STRUM_SOUND:String = "strumSound";
		public static const PIANO_SOUND:String = "pianoSound";
		
		//challenge mode + new game signals
		public static const BUTTON_DOWN:String = "buttonDown";
		public static const BUTTON_UP:String = "buttonUp";
		public static const BUTTON_OFF:String = "buttonOff";
		
		//dataRetrieved signals		
		public static const IN_GAME_QUERY:String = "inGameQuery";
		public static const NEW_GAME_QUERY:String = "newGameQuery";
		public static const DEFINITION_QUERY:String = "definitionQuery";	
		public static const STARTWORD_ARRAY_QUERY:String = "startWordArrayQuery";
		public static const ENDWORD_ARRAY_QUERY:String = "endWordArrayQuery";
		public static const COLOR_ARRAY_QUERY:String = "colorArrayQuery";
		
		//datbase and table names
		public static const COLOR_TABLE:String = "Color";
		public static const SYNONYMS_TABLE:String = "Synonyms";
		public static const GOAL_DIFFICULTY_TABLE:String = "GoalDifficulty";
		public static const FREQUENCY_TABLE:String = "Frequency";		
		public static const DEFINITIONS_TABLE:String = "Definitions";
		public static const USERS_TABLE:String = "Users";
		public static const WEEKLY_CHALLENGE_TABLE:String = "**backend**";
		public static const CURRENT_EMAIL:String = "**backend**";
		public static const RESULTS_STORAGE:String = "**backend**";
		public static const DATABASE_NAME:String = "DatabaseLITE.sqlite";				
		public static const BASE_URL:String = "http://www.synonymy-game.com/";
		public static const PHP_SEND:String = "**backend**";
		public static const PHP_REQUEST:String = "**backend**";
		public static const WEEKLY_CHALLENGE_REQUEST:String = "**backend**";
		
		//Goal Difficulty Table column lengths
		
		// VALUES NEED TO BE UPDATED WHENEVER UPDATING 'GaolDIfficulty' table in database
		public static const GOAL_DIFFICULTY_TABLE_COLUMN_LENGTHS_ARRAY:Array = [400, 602, 1169, 1780, 3033, 7572]; //easiest, easy, medium, hard, hardest, startword
		public static const DIFFICULTY_ARRAY:Array=["EASIEST", "EASY","MEDIUM","HARD","HARDEST"];
		public static const DIFFICULTY_COLOR_ARRAY = [0x009966,0xCC6633,0xCCCC33,0xCC0099,0xCC3300];
		
		//background video name
		public static const VIDEO_BACKGROUND:String = "background12_4.mp4";
		public static const VIDEO_TUTORIAL:String = "tutorial.mp4";
		public static const SERVER_VIDEO_TUTORIAL:String = "http://synonymy-game.com/media/tutorial.mp4";
		public static const SERVER_VIDEO_TUTORIAL_2:String = "http://synonymy-game.com/media/tutorial2.mp4";
	}
}