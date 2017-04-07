package com 
{	
import com.controller.NewGameController;
import com.controller.SFXController;
import com.controller.SendStoredResults;
import com.controller.SetLocalEmailController;
import com.controller.WeeklyPopupController;
import com.greensock.TweenLite;
import com.greensock.easing.Sine;
import com.greensock.plugins.BlurFilterPlugin;
import com.greensock.plugins.TweenPlugin;
import com.media.InternetConnectivity;
import com.media.SoundFXPlayer;
import com.model.DataService;
import com.model.GameDataVO;
import com.model.GamePlayTimer;
import com.model.UserModel;
import com.model.UserVO;
import com.view.DefinitionView;
import com.view.GameView;
import com.view.HelpScreenView;
import com.view.MenuView;
import com.view.More1View;
import com.view.More2View;
import com.view.More3View;
import com.view.PurchasePopupView;
import com.view.SuccessView;
import com.view.TutorialView;
import com.view.WeeklyPopupView;

import flash.desktop.NativeApplication;
import flash.display.MovieClip;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TransformGestureEvent;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.ui.Keyboard;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

import org.osflash.signals.DeluxeSignal;
import org.osflash.signals.Signal;

public class Synonymy extends MovieClip
{	
	private var msg:MsgMC;
	private var container:MovieClip;
	private var blurMenu = true; //blur menu once when app opens
	private var menuView:MenuView;
	private var more1View:More1View;
	private var more2View:More2View;
	private var more3View:More3View;
	private var tutorialView:TutorialView;
	private var definitionView:DefinitionView;
	private var successView:SuccessView;
	private var gameView:GameView;
	public 	var soundFXPlayer:SoundFXPlayer; // singleton ( instantiated in setStage() )
	private var gamePlayBgTint:TintLayerMC;
	private var helpScreen:HelpScreenView;
	private var weeklyPopupView:WeeklyPopupView;
	private var purchasePopupView:PurchasePopupView;
	
	private var gamePlayTimer:GamePlayTimer = new GamePlayTimer();
	public 	var isSwipeGesture:Boolean; // gives precedence to swipe gesture over game play touch events 
	public 	var isTransitionInProgress:Boolean; // stop events as current view transitions to new view --> tween complete
	private var _isPreventSwipe:Boolean; // if KeywordDefinitionView, or another popup is displayed we must stop swiping
	private var _isScrolling:Boolean; // if user is touch scrolling content, we need to prevent swiping
	private var CURRENT_VIEW:String;
	public 	var PREV_VIEW:String
	public 	var SCREEN_RATIO_FACTOR:Number;
	public 	var CURRENT_GAME_BLOCK_NUM:int;
	public 	var TOTAL_GAME_BLOCK_NUMS:int;
	
	// singleton : userName, password, colorsArray, difficultyArray, difficultyNum, challengeMode, audioStatus
	public 	var userVO:UserVO = new UserVO();
	
	// singleton 
	public 	var gameDataVO:GameDataVO = new GameDataVO();
	
	public 	var SCORE:int;
	public 	var DURATION:int;
	
	public 	var appWidth:Number;
	public 	var appHeight:Number;
	public 	var _stage:*;
	
	public 	var userModel:UserModel = new UserModel(this); // singleton
	
	private var newGameController:NewGameController;
	private var isNewGame:Boolean; // used to tell Definition view that it is a new game
	private var getChallengeModeSelector:Boolean // used to get challenge mode text selector when returning from more1View via challenge mode button
	
	public 	var gamePlaySwipeSignal:DeluxeSignal = new DeluxeSignal();
	public 	var scrollingEventSignal:DeluxeSignal = new DeluxeSignal();
	public 	var gameNextWordSignal:DeluxeSignal = new DeluxeSignal();
	
	public 	var letterCornerSelectionSignal:DeluxeSignal = new DeluxeSignal();
	
	public 	var viewLoadedSignal:DeluxeSignal = new DeluxeSignal();
	public 	var leaveDefinitionViewSignal:DeluxeSignal = new DeluxeSignal();		
	public 	var swipeingPreventsTouchEvent:DeluxeSignal = new DeluxeSignal(); // stop a game touch event if swiping
	public 	var showNewViewSignal:DeluxeSignal = new DeluxeSignal(); // added to support arrow buttons on more view
	public 	var openPurchasePopupSignal:DeluxeSignal = new DeluxeSignal(); //used to open purchase popup from anywhere
	public 	var closePurchasePopupSignal:Signal = new Signal(); //used to close purchase popup
		
	public 	var gameWonSignal:DeluxeSignal = new DeluxeSignal();
	public 	var gameWinningPianoTrack:String;
	
	public 	var gameDataUpdated:Signal = new Signal();
	
	public 	var getMenuSignal:Signal = new Signal();
	
	public 	var getHelpScreenSignal:Signal = new Signal();
	public 	var closeHelpScreenSignal:Signal = new Signal();	
		
	public 	var keyboardForTextField:Boolean; // used for desktop version to stop keyboard navigation event handler when keyboard is open
		
	private var goalWordAnimation:GoalWordAnimation;
	private var goalWordAnimBG:TintLayerMC;
		
	private var popupCheckNum:int = 0; // check against weeklyChallengeCheckFrequency
	private var weeklyChallengeCheckFrequency:int = 10; // increments each time MainMenu is viewed while game not in progress
	
	private var noInternet:Boolean; // this is set and unset right after use - currently used for WeeklyPopup
	public 	var weeklyPopupVisible:Boolean;
	
	public	var CURRENT_PURCHASE_POPUP_FRAME:int = -1; // track last viewed frame of popup to continue to cycle through
	public 	var SHORT_VIDEO:Boolean = false;	// shorter version is better for reduced bundle size
	public 	var DESKTOP_VERSION:Boolean = false; // also used in WordBlockView to determine touch event type
	public 	var AD_VERSION:Boolean = true; // toggle between full and add version (SynonymyLite) (**** THIS AD VERSION DOES NOT USE AD MOB ANE ***)	
	
	
	/**
	 * ...
	 * @author Mike Bromley
	 * 
	 * FULL VERSION OF SYNONYMY.
	 * Deploys to Desktop as Well as IOS and Android.
	 * Contains logic for both FULL and LITE versions but...
	 * Does not Use ADMOB ANE
	 * 
	 */
	
	public function Synonymy()
	{
		scrollingEventSignal.add(viewingScrollableContent);
		
		getHelpScreenSignal.add(showHelpScreen);
		closeHelpScreenSignal.add(closeHelpScreen);
		
		var screenWidth:Number = Capabilities.screenResolutionX;
		var screenHeight:Number = Capabilities.screenResolutionY;
		
		if(screenWidth > screenHeight)
			SCREEN_RATIO_FACTOR = 1.777778 / (screenWidth / screenHeight);
		else
			SCREEN_RATIO_FACTOR = 1.777778 / (screenHeight / screenWidth);
		
		//trace("Capabilities.screenResolutionX : " + Capabilities.screenResolutionX);
		//trace("Capabilities.screenResolutionY : " + Capabilities.screenResolutionY);
		
		trace("SCREEN_RATIO_FACTOR : " + SCREEN_RATIO_FACTOR);
		trace("****Capabilities.os : " + Capabilities.os);
		
		if(Capabilities.os.indexOf("Windows") >= 0)
		{
			//trace("Windows");
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, appDeactivated);
		}
		else if(Capabilities.os.indexOf("Linux") >= 0)
		{
			trace("Android");
				
			// Add back button control
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, androidKeyBoardEvent, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, appDeactivated);
		}
		else if(Capabilities.os.indexOf("Mac") >= 0 || Capabilities.os.indexOf("iPhone") >= 0 || Capabilities.os.indexOf("iPad") >= 0)
		{
			//trace("iPad");
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, appDeactivated);
		}
		else
		{
			//trace("Other Operating System : " + Capabilities.os;
		}		
		
		//Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
				
		//we can check internet connection each time a new view is requested
		//currently only being used for weekly challenge popup on main menu view
		checkInternetConnection();
		
		this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function appDeactivated(e:Event):void
	{
		trace("APP HAS BEEN DEACTIVATED!!!!!");
		NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, appDeactivated);
		NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, appActivated);		
		
		
		backgroundmc.pauseVideo();
		
		trace("Synonymy.appDeactivated() - CURRENT_VIEW : " + CURRENT_VIEW);
		
		if(_isPreventSwipe)
			return;
		
		//if(CURRENT_VIEW != Constants.SUCCESSVIEW)
			//showNewView(Constants.MENU_VIEW);
	}
	
	private function appActivated(e:Event):void
	{
		trace("APP HAS BEEN ACTIVATED!!!!!");
		NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, appDeactivated);
		NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, appActivated);		
		
		backgroundmc.playVideo();
	}
	
	private function androidKeyBoardEvent(e:KeyboardEvent):void
	{		
		if( e.keyCode == Keyboard.BACK )
		{
			e.preventDefault();
			e.stopImmediatePropagation();
			
			trace("ANDROID BACK BUTTON HANDLER");
			
			//don't allow to go back if a popup is open
			if(_isPreventSwipe)
				return;
			
			if(CURRENT_VIEW != Constants.MENU_VIEW)
				showNewView(Constants.MENU_VIEW, Constants.SWIPE_RIGHT);
			else
				trace("ALREADY ON MENU VIEW!!");			
		}
	}
	
	public function set preventSwipe(state:Boolean):void
	{
		_isPreventSwipe = state;
		
		trace("Synonymy.preventSwipe = " + _isPreventSwipe);
	}
	
	private function viewingScrollableContent(isScrolling:Boolean):void
	{
		_isScrolling = isScrolling;
	}
	
	private function init(e:Event):void
	{
		_stage = stage;
		
		this.removeEventListener(Event.ADDED_TO_STAGE, init);
		this.addEventListener(Event.ACTIVATE, onAppActivated);
		this.addEventListener(Event.DEACTIVATE, onAppDeactivated);
		
		TweenPlugin.activate([BlurFilterPlugin]);
		
		//copy database to applicationStorageDirectory and set User variables	
		userModel.service.databaseSetupSignal.addOnce(setUserVariables);
		userModel.setUpDatabase();
	}
	
	private function setUserVariables(setMusicOn:Boolean):void
	{
		if(setMusicOn)
		{
			userVO.audioStatus = 1;
		}
		
		userModel.setUserVariablesCompleteSignal.addOnce(setLocalEMailVar);
		userModel.queryUserTable();
	}
	
	private function setLocalEMailVar():void
	{
		var setLocalEmail:SetLocalEmailController = new SetLocalEmailController();
		setLocalEmail.localEmailUpdatedSignal.add(continueSetup);
		setLocalEmail.getCurrentEmailAddress();
	}
	
	private function continueSetup(email:String):void
	{
		// audio is always on to start
		userVO.audioStatus = 1;
		
		if(email && email.length >0)
			userVO.currentEmail = email;
		
		trace("		CURRENT EMAIL : " + userVO.currentEmail);
					
		/*trace("SETTING USER VARIABLES :: ");
		trace("		DIFFICULTY_NUM : " + userVO.difficultyNum);
		trace("		AUDIO_STATUS : " + userVO.audioStatus);
		trace("		USER_NAME : " + userVO.userName);
		trace("		PASSWORD : " + userVO.password);
		trace("		CHALLENGE_MODE : " + userVO.challengeMode);
		trace("		COLORS_ARRAY : " + userVO.colorsArray);*/
		
					
		//trace("		AUDIO_STATUS : " + userVO.audioStatus);
					
		if(DESKTOP_VERSION)
		{
			trace("		DESKTOP_VERSION - ADD KEYBOARD LISTENERS");
			addKeyboardListeners();
		}
		else
		{
			trace("		ADD SWIPE LOGIC");
			addSwipeLogic();
		}			
		
		gameWonSignal.add(gameWon);
		getMenuSignal.add(removePreviousGame);
		leaveDefinitionViewSignal.add(showGameView);
		showNewViewSignal.add(showNewView);
		
		setStage();
	}
	
	private function setStage():void
	{
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.EXACT_FIT;
		
		appWidth = stage.stageWidth;
		appHeight = stage.stageHeight;
		
		//trace("appWidth : " + appWidth);
		//trace("appHeight : " + appHeight);
		
		backgroundmc.x = 0;
		backgroundmc.y = 0;
		backgroundmc.setUp(appWidth, appHeight);
		backgroundmc.alpha = 1;				
		
		//audioPlayer = new AudioPlayer(this);
		//audioPlayer.init();
		
		soundFXPlayer = new SoundFXPlayer(this);
		soundFXPlayer.init();
		
		TweenLite.to(this, 0, {delay:1.5, onComplete:startupLoadMenu});
		TweenLite.to(gamePreloader, 1, {delay:1.2, alpha:0, onComplete:removePreloader});
	}
	
	private function removePreloader():void
	{
		this.removeChild(gamePreloader);
	}
	
	private function startupLoadMenu():void
	{			
		showNewView(Constants.MENU_VIEW);
	}
	
	// app is minimized
	private function onAppActivated(e:Event)
	{
		//trace("Synonymy.onAppActivated() - CURRENT_VIEW : " + CURRENT_VIEW);
		
		/*if(audioPlayer && userVO.audioStatus)
		{
			audioPlayer.resumeSound();
		}*/
		
		checkInternetConnection();
		
		if(CURRENT_VIEW == Constants.GAME_VIEW || CURRENT_VIEW == Constants.DEFINITION_VIEW)
			setAggStartTime();
	}
	
	private function onAppDeactivated(e:Event)
	{
		//trace("Synonymy.onAppDeactivated() - CURRENT_VIEW : " + CURRENT_VIEW);
		
		/*if(audioPlayer)
		{
			audioPlayer.stopSound();
		}*/
		if(CURRENT_VIEW == Constants.GAME_VIEW || CURRENT_VIEW == Constants.DEFINITION_VIEW)			
			setAggStopTime();
	}
	
	private function setAggStartTime():void
	{
		gamePlayTimer.setAggStartTime();
	}
	
	private function setAggStopTime():void
	{
		gamePlayTimer.setAggStopTime();
	}
	
	private function gameWon(pianoTrack:String):void
	{
		//trace("Synonymy.gameWon()");
		
		gameWinningPianoTrack = pianoTrack;
		
		var service:DataService = new DataService();
		service.dataReturnedSignal.addOnce(getSuccessView);
		service.queryDatabase("SELECT * FROM "+Constants.FREQUENCY_TABLE+" WHERE WORD LIKE '"+gameDataVO.endWord+"';");
	}
	
	private function getSuccessView(dataObj:Object):void
	{		
		var frequency:int;
		for each(var row:Object in dataObj.data)
		{
			frequency = int(row.FREQUENCY);			
		}		
		
		DURATION = gamePlayTimer.getAggregateTime();
		
		//SCORE IS CALCULATED HERE:::
		// 15000e^((-.13*seconds^.21+moves^.365)*difficulty^.32)
		SCORE = 15000*Math.pow(2.71828182845,(-0.13*(Math.pow(DURATION,0.21)+Math.pow(gameDataVO.allWordsArray.length,0.365))*Math.pow(frequency,0.32)));
		
		//trace("*** DURATION : " + DURATION + " / SCORE : " + SCORE);
		
		showNewView(Constants.SUCCESSVIEW, Constants.SWIPE_LEFT);
	}
	
	// called from successView touch event
	private function removePreviousGame():void
	{
		//trace("Synonymy.removePreviousGame()");
		
		resetGameVariables();
		
		showNewView(Constants.MENU_VIEW, Constants.SWIPE_UP);
	}
	
	// called from definitionView touch event
	private function showGameView(nextView:String):void
	{
		//trace("Synonymy.showGameView()");
		if(nextView == Constants.GAME_VIEW)
			showNewView(Constants.GAME_VIEW, Constants.SWIPE_LEFT);
		else if(nextView == Constants.MENU_VIEW)
			showNewView(Constants.MENU_VIEW, Constants.SWIPE_RIGHT);
	}
	
	// called from game play view crumbs touch event
	public function getDefinitionView():void
	{
		//trace("Synonymy.getDefinitionView()");
		showNewView(Constants.DEFINITION_VIEW, Constants.SWIPE_RIGHT);
	}
	
	/**
	 * WEEKLY UP CHECK IS CURRENTLY DONE EACH TIME THE MAIN MENU IS LOADED
	 * THE DATE IS FIRST CHECKED IN THE SQLITE DATABASE. 
	 * IF EXPIRED, NEW DATA IS REQUESTED
	*/	
	
	private function checkWeeklyChallengeData():void
	{
		trace("Synonymy.checkWeeklyChallengeData()");
		
		//don't check if game currently in progress
		if(gameDataVO.currentWord)
			return;
		
		++popupCheckNum
		if(popupCheckNum >= weeklyChallengeCheckFrequency)
			popupCheckNum = 0;		
		trace("Synonymy.checkWeeklyChallengeData() - popupCheckNum : " + popupCheckNum);
		
		//only check once in 10 fn calls - exit function if number not zero
		if(popupCheckNum != 1)
		{
			//enable main menu
			menuView.weeklyProgressActivityComplete();
			return;
		}		
		
		var weeklyUpdateController:WeeklyPopupController = new WeeklyPopupController(this);
		weeklyUpdateController.weeklyPopupDataReturned.addOnce(getWeeklyPopupView);
	}
	
	private function getWeeklyPopupView(weeklyChallengeCode:String, storedEmail:String, difficultyLevel:String, expiryEpochTime:int):void
	{
		trace("Synonymy.getPopupView() - weeklyChallengeCode : " + weeklyChallengeCode + " / storedEmail : " + storedEmail + " / expiryEpochTime : " + expiryEpochTime);
		
		//enable main menu
		menuView.weeklyProgressActivityComplete();
		
		//unable to get new data
		//this is a second check - initially it is checked and var is set: noInternet
		if(weeklyChallengeCode == "dataerror" || weeklyChallengeCode == "useCurrentData")
		{
			trace("*** No Internet *OR* Current Data is Good - DONT SHOW WEEKLY POPUP");			
			return;
		}			
				
		userVO.currentEmail = storedEmail;		
		weeklyPopupView = new WeeklyPopupView(this, weeklyChallengeCode, difficultyLevel, expiryEpochTime);
		weeklyPopupView.proceedWithWeeklyChallengeSignal.addOnce(initWeeklyChallenge);
		this.addChild(weeklyPopupView);
		weeklyPopupView.alpha = 0;
		TweenLite.to(weeklyPopupView, 0.35, {alpha:1});		
	}
	
	private function initWeeklyChallenge(weeklyChallengeCode:String, newDifficultyNum:int):void
	{		
		getNewGameController(weeklyChallengeCode, newDifficultyNum);
	}	
	
	//SWIPE ---------------------------------------------------------------------
	
	private function onSwipe(e:TransformGestureEvent):void
	{
		trace("Synonymy.onSwipe() - e:TransformGestureEvent : " + e);	
		trace("Synonymy.onSwipe() - _isPreventSwipe : " + _isPreventSwipe);			
		trace("Synonymy.onSwipe() - _isScrolling : " + _isScrolling);
		
		//disable swiping if Weekly Popup is visible
		if(weeklyPopupVisible)
			return;
		
		e.stopImmediatePropagation();
		
		if(CURRENT_VIEW == Constants.GAME_VIEW)
			swipeingPreventsTouchEvent.dispatch(true);
		
		isSwipeGesture = true;
		
		if (e.offsetX == 1)
		{ 
			updateView(Constants.SWIPE_RIGHT);
		}
		else if (e.offsetX == -1)
		{
			updateView(Constants.SWIPE_LEFT);
		}
		else if (!_isScrolling && e.offsetY == 1)
		{
			updateView(Constants.SWIPE_DOWN);
		}
		else if (!_isScrolling && e.offsetY == -1)
		{			
			updateView(Constants.SWIPE_UP);
		}
		else
		{			
		}
	}
	
	//UPDATE VIEW ----------------------------------------------------------------
	
	private function updateView(action:String):void
	{
		trace("Synonymy.updateView() - action : " + action);
		trace("Synonymy.updateView() - _isPreventSwipe : " + _isPreventSwipe);
		
		if(_isPreventSwipe)
		{
			isSwipeGesture = false;
			return;
		}				
		
		var newView:String;
		
		switch(action)
		{
			case Constants.SWIPE_RIGHT:
			{				
				switch(CURRENT_VIEW)
				{
					case Constants.MENU_VIEW:
					{
						// "SWIPE RIGHT - MENU_VIEW - Do Nothing";
						break;
					}
					case Constants.MORE1_VIEW:
					{
						// "SWIPE RIGHT - MORE1_VIEW - Do Nothing";
						break;
					}
					case Constants.DEFINITION_VIEW:
					{
						// "SWIPE RIGHT - DEFINITION_VIEW - Return to Menu View";
						newView = Constants.MENU_VIEW;
						break;
					}
					case Constants.GAME_VIEW:
					{
						// "SWIPE RIGHT - GAME_VIEW - Previous Word Block IF ANY or Definition View";						
						if(CURRENT_GAME_BLOCK_NUM == 1)
						{
							newView = Constants.DEFINITION_VIEW;
						}
						else
							gamePlaySwipeSignal.dispatch(int(CURRENT_GAME_BLOCK_NUM-1), action);
						break;
					}
					case Constants.TUTORIAL_VIEW:
					{
						// "SWIPE RIGHT - TUTORIAL_VIEW - Do Nothing";
						break;
					}
					case Constants.MORE2_VIEW:
					{
						// "SWIPE RIGHT - MORE2_VIEW - Return to More 1 View";
						newView = Constants.MORE1_VIEW;
						break;
					}						
					case Constants.MORE3_VIEW:
					{
						// "SWIPE RIGHT - MORE3_VIEW - Return to More 2 View";
						newView = Constants.MORE2_VIEW;
						break;
					}
					case Constants.SUCCESSVIEW:
					{							
						successView.successSwipeEventSignal.dispatch(action);
						break;
					}
				}
				break;
			}
				
			case Constants.SWIPE_LEFT:
			{
				switch(CURRENT_VIEW)
				{
					case Constants.MENU_VIEW:
					{
						//if game is in progress
						if(gameDataVO && gameDataVO.currentWord && gameDataVO.endWordDefn)
						{
							// "SWIPE LEFT - Menu View - Get Definition View";
							newView = Constants.DEFINITION_VIEW;
						}
						else
						{
							// "SWIPE LEFT - Menu View - Do Nothing";
						}
						break;
					}
					case Constants.DEFINITION_VIEW:
					{
						// "SWIPE LEFT - DEFINITION_VIEW - Get Game View";
						newView = Constants.GAME_VIEW;
						break;
					}
					case Constants.GAME_VIEW:
					{
						// "SWIPE LEFT - GAME_VIEW - Next group of words IF ANY";							
						if(CURRENT_GAME_BLOCK_NUM < TOTAL_GAME_BLOCK_NUMS)
							gamePlaySwipeSignal.dispatch(int(CURRENT_GAME_BLOCK_NUM+1), action);
						break;
					}
					case Constants.TUTORIAL_VIEW:
					{
						// "SWIPE LEFT - TUTORIAL_VIEW - Get Menu View";
						//newView = Constants.MENU_VIEW;
						
						//test video playhead location
						
						tutorialView.testTutorialVideoLocation.dispatch();
						
						
						break;
					}
					case Constants.MORE1_VIEW:
					{
						// "SWIPE LEFT - MORE1_VIEW - Get More 2 View";
						newView = Constants.MORE2_VIEW;
						break;
					}
					case Constants.MORE2_VIEW:
					{
						//  "SWIPE LEFT - MORE2_VIEW - Get More 3 View";
						newView = Constants.MORE3_VIEW;
						break;
					}
					case Constants.MORE3_VIEW:
					{
						// "SWIPE LEFT - MORE3_VIEW - Do Nothing";
						break;
					}
					case Constants.SUCCESSVIEW:
					{
						successView.successSwipeEventSignal.dispatch(action);
						break;
					}
				}			
				break;
			}
			case Constants.SWIPE_DOWN:
			{
				if(CURRENT_VIEW == Constants.MORE1_VIEW 
					|| CURRENT_VIEW == Constants.MORE2_VIEW
					|| CURRENT_VIEW == Constants.MORE3_VIEW)
				{
					// "SWIPE DOWN	 - Menu View - Get More 1 View";
					
					if(DESKTOP_VERSION || CURRENT_VIEW == Constants.MORE1_VIEW)
					{
						newView = Constants.MENU_VIEW;
					}
					else
					{
						//disable this swipe for more2 and more3 to prevent conflict with scrolling movie clip
					}
				}
				else
				{				
				}
				break;
			}
			case Constants.SWIPE_UP:
			{
				if(CURRENT_VIEW == Constants.MENU_VIEW)
				{
					// "SWIPE UP - Menu View - Get More 1 View";
					newView = Constants.MORE1_VIEW;
				}
				else if(CURRENT_VIEW == Constants.SUCCESSVIEW)
				{
					successView.successSwipeEventSignal.dispatch(action);
				}
				else
				{				
				}
				break;
			}
		}
		
		if(newView)
			showNewView(newView, action);
		else
			isSwipeGesture = false;
	}
	
	private function showNewView(className:String, swipeAction:String=null):void
	{
		trace("Synonymy.showNewView() - className " + className + " / CURRENT_VIEW : " + CURRENT_VIEW);
		trace("Synonymy.showNewView() - isTransitionInProgress " + isTransitionInProgress);
		
		if(isTransitionInProgress)
		{
			isSwipeGesture = false;
			return;
		}
		
		if(CURRENT_VIEW == className)
			return;
		PREV_VIEW = CURRENT_VIEW;
		CURRENT_VIEW = className;
		
		viewLoadedSignal.addOnce(onNewViewLoaded);
		
		var tempContainer:MovieClip = new MovieClip();
		this.addChild(tempContainer);
		
		switch(className)
		{
			case Constants.MENU_VIEW:
			{
				menuView = new MenuView(this);			
				tempContainer.addChild(menuView);				
				break;
			}
			case Constants.MORE1_VIEW:
			{
				more1View = new More1View(this);			
				tempContainer.addChild(more1View);
				break;
			}
			case Constants.MORE2_VIEW:
			{
				more2View = new More2View(this);			
				tempContainer.addChild(more2View);
				break;
			}
			case Constants.MORE3_VIEW:
			{
				more3View = new More3View(this);			
				tempContainer.addChild(more3View);
				break;
			}
			case Constants.TUTORIAL_VIEW:
			{
				tutorialView = new TutorialView(this);			
				tempContainer.addChild(tutorialView);
				break;
			}
			case Constants.DEFINITION_VIEW:
			{			
				definitionView = new DefinitionView(this);
				tempContainer.addChild(definitionView);
				break;
			}
			case Constants.SUCCESSVIEW:
			{			
				successView = new SuccessView(this);
				tempContainer.addChild(successView);
				break;
			}
			case Constants.GAME_VIEW: 
			default:
			{
				gameView = new GameView(this);
				tempContainer.addChild(gameView);
				break;
			}
		}
		
		// Aggregate Timer
		if(gamePlayTimer.startTime >= 0)
		{
			if(className != Constants.GAME_VIEW && className != Constants.DEFINITION_VIEW)
			{
				//trace("SETTING STOP TIME");
				
				setAggStopTime();
			}
		}
		else
		{
			if(className == Constants.GAME_VIEW || className == Constants.DEFINITION_VIEW)
			{
				//trace("SETTING START TIME");
				
				setAggStartTime();
			}
		}
		
		transitionToNewView(tempContainer, swipeAction);
	}
	
	private function transitionToNewView(tempContainer:MovieClip, swipeAction:String):void
	{
		//trace("Synonymy.transitionToNewView() - tempContainer : " + tempContainer + " / swipeAction : " + swipeAction);
		
		var _x:Number=0;
		var _y:Number=0;
		switch(swipeAction)
		{
			case Constants.SWIPE_DOWN:
			{
				_y = appHeight;
				break;
			}
			case Constants.SWIPE_UP:
			{
				_y = -appHeight;
				break;
			}
			case Constants.SWIPE_LEFT:
			{
				_x = -appWidth;	
				break;
			}
			case Constants.SWIPE_RIGHT:
			{
				_x = appWidth;	
				break;
			}
		}
		
		if(container)
		{				
			isTransitionInProgress = true;
											
			if(CURRENT_VIEW == Constants.SUCCESSVIEW)
			{
				TweenLite.to(container, 0.5, {alpha:0});
				TweenLite.from(tempContainer, 0.75, { alpha:0, blurFilter:{blurX:80, blurY:80, quality:1}, onComplete:onTransitionOutComplete, onCompleteParams:[tempContainer] });
			}
			else
			{
				//play sound
				if(isNewGame && CURRENT_VIEW == Constants.GAME_VIEW)
				{
					isNewGame = false;
					
					var sfxController:SFXController = new SFXController(this);
					sfxController.specialEffectsControllerUpdated.add(playPianoSound);
					sfxController.calculateVectorDistance();
					
					//tween gaol word from definition view title location to crumbs on game view
					if(!goalWordAnimation)
					{
						goalWordAnimBG = new TintLayerMC();
						this.addChild(goalWordAnimBG);
						goalWordAnimBG.alpha=0;
						
						goalWordAnimation = new GoalWordAnimation;
						goalWordAnimation.textMC.txt.text = gameDataVO.endWord;
						goalWordAnimation.scaleX = goalWordAnimation.scaleY = 2;
						goalWordAnimation.x = 80;
						goalWordAnimation.y = 40;						
						this.addChild(goalWordAnimation);
						goalWordAnimation.alpha=0;
						
						TweenLite.to(goalWordAnimBG, 0.5, {alpha:1});
						TweenLite.to(goalWordAnimation, 0.5, {alpha:1, onComplete:animateGoalWord});
					}					
				}
				else
				{
					soundFXPlayer.playSound(Constants.STRUM_SOUND);
				}
				
				TweenLite.to(container, 0.35, {x:_x, y:_y});
				TweenLite.from(tempContainer, 0.35, { x:-_x, y:-_y, onComplete:onTransitionOutComplete, onCompleteParams:[tempContainer] });
			}
		}
		else // when app first loaded and there is no previous container
		{				
			container = new MovieClip();
			container = tempContainer;
			tempContainer = null;
		}		
	}
	
	private function animateGoalWord():void
	{
		if(!goalWordAnimation)
			return;
		
		TweenLite.to(goalWordAnimation, 1, {delay:0.2, x: 600, y:900, scaleX:1, scaleY:1, blurFilter:{blurX:6, blurY:6, quality:1}, onComplete:fadeOutGoalWord});
	}
	
	private function fadeOutGoalWord():void
	{
		if(!goalWordAnimation)
			return;
		
		TweenLite.to(goalWordAnimBG, 0.35, {alpha:0});
		TweenLite.to(goalWordAnimation, 0.35, {alpha:0, onComplete:removeGoalWordAnimation});
	}
	
	private function removeGoalWordAnimation():void
	{
		if(!goalWordAnimation)
			return;
		
		this.removeChild(goalWordAnimBG);		
		this.removeChild(goalWordAnimation);
		goalWordAnimation = null;
	}
	
	private function playPianoSound(nextBlur:int, pianoTrack:String):void
	{
		soundFXPlayer.playSound(Constants.PIANO_SOUND, pianoTrack);
	}
	
	private function onTransitionOutComplete(tempContainer:MovieClip):void
	{		
		destroyCurrentView();		
		container = new MovieClip();
		container = tempContainer;
		tempContainer = null;
		
		isSwipeGesture = false;
		isTransitionInProgress = false;
					
		// this code is run
		// display the text selector when menuVIiew tween-in is completed 
		if(CURRENT_VIEW == Constants.MENU_VIEW && getChallengeModeSelector)
		{
			getChallengeModeSelector = false;
			userVO.challengeMode = 1;
			
			blurContainer();
			
			TweenLite.to(this, 0.35, {onComplete:displayChallengeModeSelector});
		}
	}
	
	private function displayChallengeModeSelector():void
	{
		menuView.touchSignal.dispatch(Constants.NEW_GAME);
	}
	
	private function onNewViewLoaded(obj:Object):void
	{
		trace("Synonymy.onNewViewLoaded() - obj : " + obj);
		
		if(!gamePlayBgTint)
		{
			gamePlayBgTint = new TintLayerMC();
			this.addChild(gamePlayBgTint);			
		}
		gamePlayBgTint.visible = false;
								
		switch(obj)
		{				
			case menuView:
			{
				menuView.touchSignal.add(onTouchEvent);
				
				if(blurMenu) // used to set menu to blur state and then unblur it when app first loads
				{
					blurMenu = false;
					menuView.addStartupCover();
					TweenLite.to(menuView, 0, {blurFilter:{blurX:40, blurY:40, quality:1}, onComplete:unblurMenu});
				}
				
				//CHECK FOR NEW WEEKLY POPUP DATA
				
				if(noInternet)
				{
					trace("NO INTERNET SO DON'T LOOK FOR WEEKLY CHALLENGE DATA");
					
					menuView.weeklyProgressActivityComplete();
				}
				else
				{
					trace("HAVE INTERNET SO CHECK FOR WEEKLY CHALLENGE DATA");
					checkWeeklyChallengeData();		
				}				
				resetInternetVar();
				
				break;
			}
			case tutorialView:
			{
				tutorialView.returnToMenuView.add(showNewView);
				break;
			}
			case definitionView:
			{
				if(goalWordAnimation)
					removeGoalWordAnimation();
				
				if(PREV_VIEW == Constants.MENU_VIEW && AD_VERSION && isNewGame) //isNewGame set to false at GameView
				{						
					displayPurchasePopup();
				}
				break;
			}				
			case successView:
			{
				if(AD_VERSION)
				{						
					displayPurchasePopup();					
				}
				break;
			}				
			case gameView:
			{
				gamePlayBgTint.visible = true;
				gamePlaySwipeSignal = new DeluxeSignal();
				gameNextWordSignal = new DeluxeSignal();
				letterCornerSelectionSignal = new DeluxeSignal();
				break;
			}
			case more1View:
			{					
				more1View.gotoMenuAndDisplaySelector.add(mainMenuWithSelectorVisible);
				break;
			}
			case more2View:
				break;
			case more3View:
			{
				more3View.returnToMenuView.add(showNewView);
				break;
			}			
			default:
			{
				break;
			}
		}
	}		
	
	private function unblurMenu():void
	{
		TweenLite.to(menuView, 1.5, {blurFilter:{blurX:0, blurY:0, quality:1}, onComplete:removeTransparentCover});
	}
	
	private function removeTransparentCover():void
	{
		if(menuView)
		{
			menuView.unblurTweenComplete();			
		}
	}
	
	private function mainMenuWithSelectorVisible():void
	{
		getChallengeModeSelector = true;
		showNewView(Constants.MENU_VIEW, Constants.SWIPE_DOWN);
	}		
	
	/**
	 * These touch events are all called from Menu View buttons
	 * */
	private function onTouchEvent(command:String):void
	{			
		var className:String;
		var action:String;
		
		switch(command)
		{
			case Constants.MORE:
			{
				className = Constants.MORE1_VIEW;
				action = Constants.SWIPE_UP;
				break;
			}
			case Constants.TUTORIAL:
			{
				className = Constants.TUTORIAL_VIEW;
				action = Constants.SWIPE_RIGHT;
				break;
			}			
			case Constants.NEW_GAME:
			{				
				trace("NEW_GAME - CHALLENGE_MODE : " + userVO.challengeMode + " / PASSWORD : " + userVO.password);
				
				getNewGameController();
				
				break;
			}
			case Constants.CONTINUE:
			default:
			{
				if(gameDataVO.currentWord)
				{
					className = Constants.DEFINITION_VIEW;
					action = Constants.SWIPE_LEFT;
				}
				break;
			}
		}
		
		if(className)
			showNewView(className, action);
	}
	
	// called to start a new game - touch event or weekly challenge popup which passes in a challenge code
	//IF ARGS ARE NOT NULL IT IS FROM CHALLENGE POPUP
	private function getNewGameController(weeklyCode:String=null, newDifficultyNum:int=NaN):void
	{
		if(newDifficultyNum) //IF ARGS ARE NOT NULL
		{
			userVO.difficultyNum = newDifficultyNum;
		}
		
		//trace("NEW_GAME - Synonymy.getNewGameController() - DIFFICULTY : " + userVO.difficultyNum);
		
		resetGameVariables();
		
		newGameController = new NewGameController(this, weeklyCode);
		newGameController.onNewGameGeneratedSignal.addOnce(onNewGameGenerated);
	}
	
	public function resetGameVariables():void
	{
		//reset previous game variables
		gameDataVO = null;
		gameDataVO = new GameDataVO();
		
		DURATION = 0;
		gamePlayTimer = new GamePlayTimer();
		setAggStartTime();		
	}
	
	private function onNewGameGenerated():void
	{			
		isNewGame = true;
		
		gameWinningPianoTrack = null;
		newGameController = null;
		
		showNewView(Constants.DEFINITION_VIEW, Constants.SWIPE_LEFT);
	}
	
	private function destroyCurrentView():void
	{
		if(container)
		{
			while(container.numChildren > 0)
				container.removeChildAt(0);
			
			this.removeChild(container);
			container = null;
		}
	}		
	
	// called from GamePlayView, NewGameController
	public function blurContainer():void
	{			
		TweenLite.to(container, 0.5, {blurFilter:{blurX:16, blurY:16, quality:1}, alpha:0.7});
	}
	
	public function unBlurContainer():void
	{			
		TweenLite.to(container, 0.5, {blurFilter:{blurX:0, blurY:0, quality:1}, alpha:1, remove:true, onComplete:unblurComplete});
	}
	
	private function unblurComplete():void
	{
		preventSwipe = false;
	}
	
	// called from TutorialView
	public function pauseBackground():void
	{			
		backgroundmc.pauseVideo();
	}
	
	public function playBackground():void
	{			
		backgroundmc.playVideo();
	}
	
	private function errorTextDisplay(_error:String):void
	{
		destroyCurrentView();		
		
		if(!msg){
			msg = new MsgMC;
			msg.txt.text = _error;
			msg.btnClose.addEventListener(MouseEvent.CLICK, closeErrorTextDisplay);
			msg.x = stage.stageWidth/2 - msg.width/2;
			msg.y = stage.stageHeight/2 - msg.height/2;
			this.addChild(msg);
		}
	}
	
	private function closeErrorTextDisplay(e:MouseEvent)
	{		
		this.removeChild(msg);
		msg = null;
		
		CURRENT_VIEW = "";
		showNewView(Constants.MENU_VIEW);
	}
	
	
	//--------------------------
	// User Input Listeners
	
	private function addSwipeLogic():void
	{
		trace("Snyonymy.addSwipeLogic()");
		
		Multitouch.inputMode = MultitouchInputMode.GESTURE;
		this.addEventListener(TransformGestureEvent.GESTURE_SWIPE , onSwipe, true, 10); 
	}
	
	private function addKeyboardListeners():void
	{
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);		
	}
	
	private function keyDownHandler(e:KeyboardEvent):void
	{		
		//trace("KEY EVENT charCode : " + e.charCode);
		trace("KEY EVENT keyCode : " +e.keyCode);
		
		if(keyboardForTextField)
			return;
		
		var actionString:String;
		switch (e.keyCode)
		{
			case 87: //W
				//trace("W key pressed");
				actionString = Constants.SWIPE_DOWN;
				break;			
			case 65: //A
				//trace("A key pressed");
				actionString = Constants.SWIPE_RIGHT;
				break;			
			case 83: //S
				//trace("S key pressed");
				actionString = Constants.SWIPE_UP;
				break;
			case 68: //D
				//trace("D key pressed");
				actionString = Constants.SWIPE_LEFT;
				break;
			case 37: //Left
				//trace("LEFT arrow pressed");
				actionString = Constants.SWIPE_RIGHT;
				break;
			case 38: //Up
				//trace("UP arrow pressed");
				actionString = Constants.SWIPE_DOWN;
				break;
			case 39: //Right
				//trace("RIGHT arrow pressed");
				actionString = Constants.SWIPE_LEFT;
				break;
			case 40: //Down
				//trace("DOWN arrow pressed");
				actionString = Constants.SWIPE_UP;
				break;
			case 73: //I
				//trace("DOWN arrow pressed");
				//actionString = Constants.SWIPE_UP;
				letterSelection_corners("I");
				return;
				break;
			case 74: //J
				//trace("DOWN arrow pressed");
				//actionString = Constants.SWIPE_UP;
				letterSelection_corners("J");
				return;
				break;
			case 75: //K
				//trace("DOWN arrow pressed");
				//actionString = Constants.SWIPE_UP;
				letterSelection_corners("K");
				return;
				break;
			case 85: //U
				//trace("DOWN arrow pressed");
				//actionString = Constants.SWIPE_UP;
				letterSelection_corners("U");
				return;
				break;
		}
		updateView(actionString);
	}
	
	private function letterSelection_corners(letter:String)
	{
		switch(letter)
		{
			case "U":
			{
				trace("TOP LEFT");
				if(CURRENT_VIEW == Constants.MENU_VIEW)
				{
					userVO.challengeMode = 0; //make sure challenge mode if off when useing keys
					onTouchEvent(Constants.NEW_GAME);
				}
				else if(CURRENT_VIEW == Constants.GAME_VIEW)
					letterCornerSelectionSignal.dispatch("topLeft");
			
				break;
			}
			case "I":
			{
				trace("TOP RIGHT");
				if(CURRENT_VIEW == Constants.MENU_VIEW)
					onTouchEvent(Constants.CONTINUE);
				else if(CURRENT_VIEW == Constants.GAME_VIEW)
					letterCornerSelectionSignal.dispatch("topRight");
				break;
			}
			case "J":
			{
				trace("BOTTOM LEFT");
				if(CURRENT_VIEW == Constants.MENU_VIEW)
					onTouchEvent(Constants.TUTORIAL);
				else if(CURRENT_VIEW == Constants.GAME_VIEW)
					letterCornerSelectionSignal.dispatch("bottomLeft");
				break;
			}
			case "K":
			{
				trace("BOTTOM RIGHT");
				if(CURRENT_VIEW == Constants.MENU_VIEW)
					onTouchEvent(Constants.MORE);
				else if(CURRENT_VIEW == Constants.GAME_VIEW)
					letterCornerSelectionSignal.dispatch("bottomRight");
				break;
			}
		}
	}
	
	//SEND STORED DATA (runs asynchronously in background - make sure it does not affect other data functionality)
	private function sendStoredData():void
	{
		var sendStoredResults:SendStoredResults = new SendStoredResults();
		sendStoredResults.init();
	}
	
	//CHECK INTERNET CONNECTION TO SEND BACKED UP DATA
	
	private function checkInternetConnection():void
	{
		trace("***checkInternetConnection()");
		var internetCheck:InternetConnectivity = new InternetConnectivity();
		internetCheck.internetConnectivitySignal.addOnce(internetConnectionTestResult);
	}
	
	private function internetConnectionTestResult(result:Boolean):void
	{
		trace("Snynonymy.internetConnectionTestResult() - result : " + result);
		
		if(!result)
		{
			trace("		*** NO INTERNET");
			noInternet = true;
		}
		else
		{
			trace("		*** HAVE INTERNET");
			sendStoredData();
		}
	}
	
	private function resetInternetVar():void
	{
		noInternet = false;
	}
	
	// HELP SCREEN
	
	private function showHelpScreen():void
	{
		trace("Synonymy.showHelpScreen()");
		
		helpScreen = new HelpScreenView(this);
		this.addChild(helpScreen);
	}
	
	private function closeHelpScreen():void
	{
		this.removeChild(helpScreen);
		helpScreen = null;
	}
	
	// PURCHASE POPUP
	
	//called from More1 as well as this class
	public function displayPurchasePopup():void
	{
		trace("OPEN PURCHASE POPUP");
		
		_isPreventSwipe = true;
		
		purchasePopupView = new PurchasePopupView(this);
		closePurchasePopupSignal.add(closePurchasePopup);
		this.addChild(purchasePopupView);
		
		purchasePopupView.alpha = 0;
		var del:int = 0;
		if(CURRENT_VIEW == Constants.DEFINITION_VIEW)
		{
			del = 1;
		}
		TweenLite.to(purchasePopupView, 0.5, {delay:del, alpha:1});
		
		trace("OPEN PURCHASE POPUP _isPreventSwipe : " + _isPreventSwipe);
	}
	
	
	public function closePurchasePopup():void
	{
		trace("CLOSE PURCHASE POPUP");
		
		_stage.focus = _stage;
		
		if(CURRENT_VIEW != Constants.SUCCESSVIEW)
			_isPreventSwipe = false;
		
		trace("CLOSE PURCHASE POPUP _isPreventSwipe : " + _isPreventSwipe);
		
		if(purchasePopupView)
		{
			this.removeChild(purchasePopupView);
			purchasePopupView = null;
		}
	}
	
}//	
}//
