/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock / Garin Hess

	Modifications made to this page for version 1.3:
		- Changed references to main timeline with Global variable.
		- Added code to force media controller to control media if it exists in the presentation clip. Checks to see if there is a MediaDisplay component named "media_container"
		- Changed the way the width of the bar is determined.
		- Fixed the setFrame number onRelease of scrubber so that the movie would play when released.
	Modifications made to this page for version 1.3.5:
		- Updated determineTime function to record completion of template pages.
		- Updated onEnterFrame so that templates will play even if media controller is hidden.
	Modifications made to this page for version 2
		- Updated to work with captivate movie
		- Add auto play media feature.
*/

var movieHolder:Object = playerMain_mc.presentation;//presentation movie clip that displays content movies
var movieFPS:Number = 12; //Default frame per seconds. Will read this amount from XML file.
var isMedia:Boolean = false; //v 1.3 - flag to determine if clip playing contains audio/video
var mediaHolder:Object //mediaDisplay component in content movie; var set in onEnterFrame code later
var bar_origWidth:Number = loader_mc._width; //Original width of bar

//===========================================================================//
//================= CUSTOMIZED CODE: VIDEO FULLSCREEN =======================//
var controllerX:Number = playerMain_mc.controllerX
var controllerY:Number = playerMain_mc.controllerY
//================= CUSTOMIZED CODE: VIDEO FULLSCREEN =======================//
//===========================================================================//


var useCaptivateController:Boolean; //Determines if the movie being played is a captivate movie.
var captivateInterval:Number;
//trace(this._x + "/" + this._y)



//Custom Color for medial controller
if (playerMain_mc.useInterfaceColors) {//This variable is set in the player.fla file for those styles that were built for tinting.
	var satPct:Number = playerMain_mc.root_xmlnode.attributes.saturationPercent;
	var buttonColor:String = playerMain_mc.root_xmlnode.attributes.buttonColor;
	if (playerMain_mc.useButtonTextColor) {//Set in player.fla for styles that use button text color
		var buttonTextColor:String = playerMain_mc.root_xmlnode.attributes.buttonTextColor;
		var theObjects:Array = ["rewind_mc","play_mc"];
		for (var mc in theObjects){
			var theObject:Object = playerMain_mc.controller_mc[theObjects[mc]];
			//trace(theObject);
			for (var obj in theObject){
				if (typeof (theObject[obj]) == "movieclip") { 
					var objName:String = theObject[obj]._name;
					if (objName.toLowerCase().indexOf("text") > -1){
						//trace("text "+objName);
						bt6Color = new Color(theObject[obj]);
						bt6Color.setTint(playerMain_mc.convertHexToR(buttonTextColor),playerMain_mc.convertHexToG(buttonTextColor),playerMain_mc.convertHexToB(buttonTextColor), satPct);
					} else if (objName.toLowerCase().indexOf("back") > -1){
						//trace("back "+objName);
						b6Color = new Color(theObject[obj]);
						b6Color.setTint(playerMain_mc.convertHexToR(buttonColor),playerMain_mc.convertHexToG(buttonColor),playerMain_mc.convertHexToB(buttonColor), satPct);
					}
				} 
			}
		}
		if (includeTrackWithButtons){
			b3Color = new Color(scrubber_mc);
			b3Color.setTint(playerMain_mc.convertHexToR(buttonTextColor),playerMain_mc.convertHexToG(buttonTextColor),playerMain_mc.convertHexToB(buttonTextColor), satPct);
			b4Color = new Color(loader_mc);
			b4Color.setTint(playerMain_mc.convertHexToR(buttonTextColor),playerMain_mc.convertHexToG(buttonTextColor),playerMain_mc.convertHexToB(buttonTextColor), satPct);
			counter_txt.textColor = buttonTextColor;
		}
		if (includeTrackWithButtonsButtonColor){
			b3Color = new Color(scrubber_mc);
			b3Color.setTint(playerMain_mc.convertHexToR(buttonColor),playerMain_mc.convertHexToG(buttonColor),playerMain_mc.convertHexToB(buttonColor), satPct);
			b4Color = new Color(loader_mc);
			b4Color.setTint(playerMain_mc.convertHexToR(buttonColor),playerMain_mc.convertHexToG(buttonColor),playerMain_mc.convertHexToB(buttonColor), satPct);
		}
		if (hasBackground){
			b7Color = new Color(background_mc);
			b7Color.setTint(playerMain_mc.convertHexToR(buttonColor),playerMain_mc.convertHexToG(buttonColor),playerMain_mc.convertHexToB(buttonColor), satPct);
		}
	} else {
		b1Color = new Color(play_mc);
		b1Color.setTint(playerMain_mc.convertHexToR(buttonColor),playerMain_mc.convertHexToG(buttonColor),playerMain_mc.convertHexToB(buttonColor), satPct);
		b2Color = new Color(rewind_mc);
		b2Color.setTint(playerMain_mc.convertHexToR(buttonColor),playerMain_mc.convertHexToG(buttonColor),playerMain_mc.convertHexToB(buttonColor), satPct);
	}
}

play_mc.onRollOver = function() {
	if (isMedia != true) {//if media component NOT in content movie
		if (movieHolder.playStatus == "Stopped") {
			this.gotoAndStop("over_play");
		} else if (movieHolder.playStatus == "Paused"){
			this.gotoAndStop("over_play");
		} else if (movieHolder.playStatus == "Playing"){
			this.gotoAndStop("over_pause");
		} else {
			this.gotoAndStop("over_play");
		}
	} else {
		if (mediaHolder.playing == true) {
				this.gotoAndStop("over_pause");
		} else {
				this.gotoAndStop("over_play");
		}
	}
}

play_mc.onRollOut = function() {
	if (isMedia != true) {//if media component NOT in content movie
		if (movieHolder.playStatus == "Stopped") {
			this.gotoAndStop("up_play");
		} else if (movieHolder.playStatus == "Paused"){
			this.gotoAndStop("up_play");
		} else if (movieHolder.playStatus == "Playing"){
			this.gotoAndStop("up_pause");
		} else {
			this.gotoAndStop("up_play");
		}
	} else {
		if (mediaHolder.playing == true) {
			this.gotoAndStop("up_pause");
		} else {
			this.gotoAndStop("up_play");
		}
	}
}

play_mc.onPress = function() {
	if (isMedia != true) { //if media component is NOT in content movie
		if (movieHolder.playStatus == "Stopped") {
			if (useCaptivateController) {
				movieHolder.rdcmndResume = 1;
			}else{
				movieHolder.play();
			}
			this.gotoAndStop("down_play");
		} else if (movieHolder.playStatus == "Paused"){
			if (useCaptivateController) {
				movieHolder.rdcmndResume = 1;
			}else{
				movieHolder.play();
			}
			this.gotoAndStop("down_play");
		} else if (movieHolder.playStatus == "Playing"){
			if (useCaptivateController) {
				movieHolder.rdcmndPause = 1;
			}else{
				movieHolder.stop();
			}
			this.gotoAndStop("down_pause");
		} else {
			if (useCaptivateController) {
				movieHolder.rdcmndResume = 1;
			}else{
				movieHolder.play();
			}
			this.gotoAndStop("down_play");
		}
	} else { //if media component IS in content movie
		if (mediaHolder.playing == true) {
				mediaHolder.pause();
				this.gotoAndStop("down_play");
		} else {
				mediaHolder.play();
				this.gotoAndStop("down_pause");
		}
	}
}

play_mc.onRelease = function() {
	if (isMedia != true) { //if media component is NOT in content movie
		if (movieHolder.playStatus == "Stopped") {
			this.gotoAndStop("up_pause");
			movieHolder.playStatus = "Playing"
		} else if (movieHolder.playStatus == "Paused"){
			this.gotoAndStop("up_pause");
			movieHolder.playStatus = "Playing"
		} else if (movieHolder.playStatus == "Playing"){
			this.gotoAndStop("up_play");
			movieHolder.playStatus = "Paused"
		} else {
			this.gotoAndStop("up_pause");
			movieHolder.playStatus = "Playing"
		}
	} else {
		if (mediaHolder.playing == false) {
			mediaHolder.pause();
			this.gotoAndStop("up_play");
		} else {
			mediaHolder.play();
			this.gotoAndStop("up_pause");
		}
	}
}

//Function for rewind button.
rewind_mc.onRollOver = function() {
		this.gotoAndStop("over");
}

rewind_mc.onRollOut = function() {
	this.gotoAndStop("up");
}

rewind_mc.onPress = function() {
	this.gotoAndStop("down");
}

rewind_mc.onRelease = function() {
	this.gotoAndStop("up");
	if (isMedia != true) { //if media component is NOT in content movie
		if (useCaptivateController) {
			movieHolder.rdcmndRewindAndPlay = 1;
		}else{
			movieHolder.gotoAndPlay(2);
		}
		movieHolder.playStatus = "Playing";
	} else { //if media is in content movie, rewind and play media
		mediaHolder.stop();
		mediaHolder.play();
	}
	play_mc.gotoAndStop("up_pause"); //reset Play button to pause image
}

//Scrubber code
//What happens when scrubber is clicked.
scrubber_mc.onPress = function() {
	var sFrame:Number = outline_mc._x;
	var loader_width:Number = outline_mc._width;
	startDrag("scrubber_mc", true, sFrame, scrubber_mc._y, (loader_width + sFrame), scrubber_mc._y);
	if (isMedia != true) { //if no media component in content movie
		if (useCaptivateController) {
			//movieHolder.rdcmndGotoFrame = movieHolder.rdinfoCurrentFrame;
			movieHolder.rdcmndPause = 1;
		}else{
			movieHolder.gotoAndStop(movieHolder._currentframe);
		}
	} else {
		mediaHolder.stop();
	}
	
	scrubber_mc.onEnterFrame = function () {//Change on enter frame so scrubber will update movie
		var startFrame:Number = outline_mc._x;
		if (isMedia != true) {
			if (useCaptivateController) {
				var tFrames:Number = movieHolder.rdinfoFrameCount;
			}else{
				var tFrames:Number = movieHolder._totalframes;
			}
		} else {
			var tFrames:Number = mediaHolder.totalTime;
		}
		var loaderwidth:Number = outline_mc._width;
		var setFrame:Number = ((scrubber_mc._x - startFrame)/loaderwidth)*tFrames;
		setFrame = Math.floor(setFrame);
		if (isMedia != true) {
			if (useCaptivateController) {
				movieHolder.rdcmndGotoFrame = setFrame;
			}else{
				movieHolder.gotoAndStop(setFrame);
			}
		} else {
			mediaHolder.playheadTime = setFrame;
		}
		determineTime();//Update timer
	}
}

//When scrubber is released, update the movie, timer and start playing
scrubber_mc.onRelease = function() {
	stopDrag();
	var startFrame:Number = outline_mc._x;
	if (isMedia != true) {
		if (useCaptivateController) {
			var tFrames:Number = movieHolder.rdinfoFrameCount;
		}else{
			var tFrames:Number = movieHolder._totalframes;
		}
	} else {
		var tFrames:Number = mediaHolder.totalTime;
	}
	var loaderwidth:Number = outline_mc._width;
	var setFrame:Number = ((scrubber_mc._x - startFrame)/loaderwidth)*tFrames;
	setFrame = Math.floor(setFrame);
	//trace(setFrame);
	if (isMedia != true) {
		if (setFrame <= 0) {
			setFrame = 1;
		}
		if (useCaptivateController) {
			movieHolder.rdcmndGotoFrame = setFrame;
			movieHolder.rdinfoCurrentFrame = setFrame;
			captivateInterval = setInterval(startCaptivateMovie,100)
		}else{
			movieHolder.gotoAndPlay(setFrame);
		}
	} else {
		mediaHolder.playheadTime = setFrame;
		mediaHolder.play();
	}
	scrubber_mc.onEnterFrame = function() {//Reset enterFrame to move scrubber
		if (isMedia != true) { //if no media component in content movie
			if (useCaptivateController) {
				var tFrames:Number = movieHolder.rdinfoFrameCount;
				var cFrame:Number = movieHolder.rdinfoCurrentFrame;
			}else{
				var tFrames:Number = movieHolder._totalframes;
				var cFrame:Number = movieHolder._currentframe;
			}
		} else { //if there IS a media component in content movie
			var tFrames:Number = mediaHolder.totalTime;
			var cFrame:Number = mediaHolder.playheadTime;
		}
		var sFrame:Number = outline_mc._x;
		var loader_width:Number = outline_mc._width;
		//cFrame = Math.floor(cFrame);
		scrubber_mc._x = Math.floor(sFrame + (cFrame*loader_width)/tFrames);	
		determineTime();
	}
	if (isMedia != true) {
		movieHolder.playStatus = "Playing";//update play status
	} else {
		playerMain_mc.presentation.loadStatus = "medialoaded";
	}
	play_mc.gotoAndStop("up_pause");//update play button
}

//If they let go outside of the scrubber
scrubber_mc.onReleaseOutside = function() {
	stopDrag();
	var startFrame:Number = outline_mc._x;
	if (isMedia != true) {
		if (useCaptivateController) {
			var tFrames:Number = movieHolder.rdinfoFrameCount;
		}else{
			var tFrames:Number = movieHolder._totalframes;
		}
	} else {
		var tFrames:Number = mediaHolder.totalTime;
	}
	var loaderwidth:Number = outline_mc._width;
	var setFrame:Number = ((scrubber_mc._x - startFrame)/loaderwidth)*tFrames;
	setFrame = Math.floor(setFrame);
	//trace(setFrame);
	if (isMedia != true) {
		if (setFrame <= 0) {
			setFrame = 1;
		}
		if (useCaptivateController) {
			movieHolder.rdcmndGotoFrame = setFrame;
			movieHolder.rdinfoCurrentFrame = setFrame;
			captivateInterval = setInterval(startCaptivateMovie,100)
		}else{
			movieHolder.gotoAndPlay(setFrame);
		}
	} else {
		mediaHolder.playheadTime = setFrame;
		mediaHolder.play();
	}
	scrubber_mc.onEnterFrame = function() {//Reset enterFrame to move scrubber
		if (isMedia != true) { //if no media component in content movie
			if (useCaptivateController) {
				var tFrames:Number = movieHolder.rdinfoFrameCount;
				var cFrame:Number = movieHolder.rdinfoCurrentFrame;
			}else{
				var tFrames:Number = movieHolder._totalframes;
				var cFrame:Number = movieHolder._currentframe;
			}
		} else { //if there IS a media component in content movie
			var tFrames:Number = mediaHolder.totalTime;
			var cFrame:Number = mediaHolder.playheadTime;
		}
		var sFrame:Number = outline_mc._x;
		var loader_width:Number = outline_mc._width;
		//cFrame = Math.floor(cFrame);
		scrubber_mc._x = Math.floor(sFrame + (cFrame*loader_width)/tFrames);	
		determineTime();
	}
	if (isMedia != true) {
		movieHolder.playStatus = "Playing";//update play status
	} else {
		playerMain_mc.presentation.loadStatus = "medialoaded";
	}
	play_mc.gotoAndStop("up_pause");//update play button
}

//Moves scrubber with movie
scrubber_mc.onEnterFrame = function() {
	if (isMedia != true) { //no media component in content movie
		if (useCaptivateController) {
			var tFrames:Number = movieHolder.rdinfoFrameCount;
			var cFrame:Number = movieHolder.rdinfoCurrentFrame;
		}else{
			var tFrames:Number = movieHolder._totalframes;
			var cFrame:Number = movieHolder._currentframe;
		}
	} else { //media component IS in content movie
		var tFrames:Number = mediaHolder.totalTime;
		var cFrame:Number = mediaHolder.playheadTime;
	}
	var sFrame:Number = outline_mc._x;
	var loader_width:Number = outline_mc._width;
	//cFrame = Math.floor(cFrame);
	scrubber_mc._x = Math.floor(sFrame + (cFrame*loader_width)/tFrames);		
	determineTime();
}

//Update the timer display in the media controller.
function determineTime() {
	if (isMedia != true) { //if no media cmooponent in content movie
		var tempFPS:Number = playerMain_mc.currentPage_xmlnode.attributes.fpsec;
		//trace(tempFPS);
		if (tempFPS != undefined) {movieFPS = tempFPS;}
		//trace(movieFPS);
		if (useCaptivateController) {
			var tFrames:Number = movieHolder.rdinfoFrameCount;
			var cFrame:Number = movieHolder.rdinfoCurrentFrame;
		}else{
			var tFrames:Number = movieHolder._totalframes;
			var cFrame:Number = movieHolder._currentframe;
		}
		var tSecs:Number = Math.floor(tFrames/movieFPS);
		var cSecs:Number = Math.floor(cFrame/movieFPS);
	} else { //if media component IS in content movie...then use media class properties to determine time
		var tSecs:Number = Math.floor(mediaHolder.totalTime);
		var cSecs:Number = Math.round(mediaHolder.playheadTime);
	}
	//begin formatting minutes/seconds
	var ccSecs = cSecs;
	var ttSecs = tSecs;
	var tMin:Number = Math.floor(tSecs/60);
	var cMin:Number = Math.floor(cSecs/60);
	var tSecsS:String;
	var cSecsS:String;
	tSecs = tSecs%60;
	if (tSecs <10) {
		tSecsS = "0" + tSecs.toString();
	} else {
		tSecsS = tSecs.toString();
	}
	cSecs = cSecs%60;
	if (cSecs <10) {
		cSecsS = "0" + cSecs.toString();
	} else {
		cSecsS = cSecs.toString();
	}

	counter_txt.text = cMin.toString() + ":" + cSecsS + "/" + tMin.toString() + ":" + tSecsS;
	
	/* Customized code */
	//counter_txt._x = scrubber_mc._x-13;
	//bg_mc._x = counter_txt._x
	
	//Mark page as complete
	var usePageComplete:Boolean = playerMain_mc.root_xmlnode.attributes.pageComplete.toLowerCase() == "true";
	var sendPageComplete:Boolean = playerMain_mc.currentPage_xmlnode.attributes.sendPageComplete.toLowerCase() == "true";
	var engagePg = playerMain_mc.currentPage_xmlnode.attributes.engageSWF.toLowerCase() == "true";
	var captivatePg = playerMain_mc.currentPage_xmlnode.attributes.captivatePage.toUpperCase() == "TRUE";
	//trace(usePageComplete+sendPageComplete + " ccSecs: " + ccSecs)
	if (usePageComplete && ccSecs > 1 && !playerMain_mc.aPageCompleted){ //Is the page complete method being used
		var filePath:String = playerMain_mc.currentPage_xmlnode.attributes.file;
		var lastslash = filePath.lastIndexOf("/");
		filePath = filePath.substring(lastslash +1);//get file name
		if (filePath.substr(0,3).toUpperCase() == "RI_"){//Is this an RI template?
			//trace("cMin: " + cMin + "tMin: " + tMin + "cSecs: " + cSecsS + "tSecs: " + tSecsS)
			if (cMin >= tMin && cSecsS >= tSecsS){//Is the media done playing?
				playerMain_mc.apiPageComplete();
				playerMain_mc.aPageCompleted = true;
			}
		} else if (engagePg){
			if (playerMain_mc.presentation.articulateModAPI.GetElapsedTime() > 0 && playerMain_mc.presentation.articulateModAPI.IsComplete()){
				playerMain_mc.apiPageComplete();
				playerMain_mc.aPageCompleted = true;
			}
		} else if (captivatePg){
			if (movieHolder.rdinfoCurrentFrame >= movieHolder.rdinfoFrameCount)
			{
				playerMain_mc.apiPageComplete();
				playerMain_mc.aPageCompleted = true;
			}
		} else if (sendPageComplete) { //Do they want this sent on default page type
			//trace("cMin: " + cMin + "  tMin: " + tMin + "  cSecsS: " + cSecsS + "  tSecsS: " + tSecsS);
			if (cMin >= tMin && cSecsS >= tSecsS){//Is the media done playing?
				playerMain_mc.apiPageComplete();
				playerMain_mc.aPageCompleted = true;
			}
		}
	} else if(usePageComplete && ttSecs < 2 && !playerMain_mc.aPageCompleted) {
		if (engagePg){
			if (playerMain_mc.presentation.articulateModAPI.GetElapsedTime() > 0 && playerMain_mc.presentation.articulateModAPI.IsComplete()){
				playerMain_mc.apiPageComplete();
				playerMain_mc.aPageCompleted = true;
			}
		} else if (captivatePg){
			if (movieHolder.rdinfoCurrentFrame >= movieHolder.rdinfoFrameCount)
			{
				trace("Botton: " + movieHolder.rdinfoCurrentFrame + " - " + movieHolder.rdinfoFrameCount)
				playerMain_mc.apiPageComplete();
				playerMain_mc.aPageCompleted = true;
			}
		}else if (sendPageComplete) {
			playerMain_mc.apiPageComplete();
			playerMain_mc.aPageCompleted = true;
		}
	} else {
		if (ccSecs > 1 && ccSecs < ttSecs && captivatePg)
		{
			playerMain_mc.aPageCompleted = false;
		}
	}
}

//Pre-loader code
this.onEnterFrame = function(){
	//trace(movieHolder.getBytesTotal() + ":" + movieHolder.getBytesLoaded());
	//Check to see if it is a captivate movie
	useCaptivateController = playerMain_mc.currentPage_xmlnode.attributes.captivatePage.toUpperCase() == "TRUE";
	//trace(this._x + "/" +this.y)
	//check to see if media is playing ni MediaDisplay component named "media_container"
	mediaHolder = playerMain_mc.currentPage_xmlnode.attributes.mediaPath;//media component
	//if (mediaHolder == undefined){
		//If there is no media check for SWF file.
		//mediaHolder = playerMain_mc.presentation.video_container; //media component
	//}
	if (mediaHolder == undefined){
		//If there is no media check for SWF file.
		swfHolder = playerMain_mc.presentation.mediaSWF_mc;
	}
//If SWF Template reset movieHolder
	if (swfHolder !== undefined){
		movieHolder = swfHolder;
	} else {
		movieHolder = playerMain_mc.presentation;
	}
	if (mediaHolder !== undefined) {
		mediaHolder = playerMain_mc.presentation.media_container;
		
		if (mediaHolder == undefined){
			//If there is no media check for SWF file.
			mediaHolder = playerMain_mc.presentation.video_container; //media component
		}
		if (mediaHolder == undefined){
			//If there is no media check for SWF file.
			mediaHolder = playerMain_mc.presentation.video_player; //media component
		}
		
		
		isMedia = true;
	} else {
		isMedia = false;
	}
	
	//This variable determines whether media should auto play.
	var autoPlayMedia:Boolean = (playerMain_mc.currentPage_xmlnode.attributes.autoPlayMedia.toUpperCase() == "FALSE");
	if (autoPlayMedia) {//Accounts for older versions
		autoPlayMedia = false;
	} else {
		autoPlayMedia = true;
	}
	//Check loading percentage
	var loadPerc:Number = playerMain_mc.currentPage_xmlnode.attributes.loadPercentage;
	if (playerMain_mc.showMediaController) {
		this._visible = true;
		if (playerMain_mc.currentPage_xmlnode.attributes.pType != "Video RTMP") //********Video Stream
		{
			//===========================================================================//
			//================= CUSTOMIZED CODE: VIDEO FULLSCREEN =======================//
			if(Stage["displayState"]  == "fullScreen")
			{
				// nothing
			}
			else
			{
				this._x = controllerX;
				this._y = controllerY;
			}			
			//================= CUSTOMIZED CODE: VIDEO FULLSCREEN =======================//
			//===========================================================================//
		}
	} else {
		this._visible = false;
	}
		//if (this._visible == false) {this._visible = true}
	if (isMedia != true) { //if no media component in content movie, base on whole content movie
		var totBytes:Number = movieHolder.getBytesTotal();
		var curBytes:Number = movieHolder.getBytesLoaded();
	} else { //there is a media component---load preloader based on its properties
		var totBytes:Number = mediaHolder.bytesTotal;
		var curBytes:Number = mediaHolder.bytesLoaded;
	}
	if (loadPerc == 100) {loadPerc = 99;}
	loadPerc = loadPerc/100;
	loader_mc._width = bar_origWidth * (curBytes/totBytes)
	//myField.text = loader_mc._width + " = " + bar_origWidth + " * " + curBytes + "/" + totBytes
	if (isMedia != true) {
		//trace("doesn't detect media")
		//trace("playing status = " + mediaHolder.playing)
		//trace("playhead time: " + mediaHolder.playheadTime);
		if(playerMain_mc.mediaTemplateRunning){
			autoPlayMedia = true;
		}
		if ((curBytes/totBytes < loadPerc) && (movieHolder.playStatus != "Playing")) {//Is movie loaded and can we start playing?
			movieHolder.playStatus = "Loading";
			movieHolder.stop();
			play_mc.gotoAndStop("up_play");
		} else if ((curBytes/totBytes >= loadPerc) && (movieHolder.playStatus == "Loading")) {
			if (autoPlayMedia) {
				movieHolder.playStatus = "Playing";
				play_mc.gotoAndStop("up_pause");
				movieHolder.play();
			} else {
				if (useCaptivateController) {
					movieHolder.playStatus = "Pause";
					play_mc.gotoAndStop("up_play");
					movieHolder.rdcmndPause = 1;
					//movieHolder.stop();
				} else {
					movieHolder.playStatus = "Pause";
					play_mc.gotoAndStop("up_play");
					movieHolder.stop();
				}
			}
		} else if (movieHolder.playStatus == undefined) {//If movie loads quickly the status isn't set. This assigns the status.
			movieHolder.playStatus = "Loading";
		} else if (movieHolder.playStatus == "Playing"){
			if (playerMain_mc.currentPage_xmlnode.attributes.engageSWF.toLowerCase() == "true"){
				//trace(movieHolder._currentframe)
				if (movieHolder._currentframe == 3){
					movieHolder.play();
				}
			}
		}
	} else {
		if (!isNaN(curBytes)){
			if ((curBytes/totBytes < loadPerc) && (mediaHolder.playing != true)) {//is media loaded and can we start playing?
				//trace("pausing because " + (curBytes/totBytes*100) + "% is loaded");
				//trace("playhead time: " + mediaHolder.playheadTime);
				//mediaHolder.pause();
				play_mc.gotoAndStop("up_play");
				//movieHolder.hidePageObjects(); //function resides on main timline of template
			} else if ((curBytes/totBytes >= loadPerc) && (playerMain_mc.presentation.loadStatus != "medialoaded")) {
				//playerMain_mc.presentation.showPageObjects(); //function on main timeline of template
				playerMain_mc.presentation.loadStatus = "medialoaded";
				if (autoPlayMedia) {
					//trace("playing because " + Math.round(curBytes/totBytes*100) + "% is loaded")
					play_mc.gotoAndStop("up_pause");
					//trace(mediaHolder.playheadTime);
					mediaHolder.play();
				} else {
					play_mc.gotoAndStop("up_play");
					//mediaHolder.pause();
				}
			}
		}
		var tb:Number = totBytes * (loadPerc);
		if (curBytes > 4 && tb > 4 && curBytes >= tb && playerMain_mc.presentation.myMask._visible == true ){
			playerMain_mc.presentation.showPageObjects();
			playerMain_mc.sentShowPageObjects = true;
		}
	}
	//trace(curBytes + " / " + totBytes);
	
	
	var show_audio_btn:Boolean = (playerMain_mc.root_xmlnode.attributes.audioButton.toUpperCase() == "FALSE");
	
	if(this._visible == false)
	{				
		playerMain_mc.audio_onoff_mc._visible = false;
		playerMain_mc.vol_outline_mc._visible = false;		
	}
	else
	{
		if(!show_audio_btn)
		{
			playerMain_mc.audio_onoff_mc._visible = true;
			playerMain_mc.vol_outline_mc._visible = true;					
		}
	}
	
}
//Accessibility features
playerMain_mc.controller_mc.tabChildren =true;
playerMain_mc.controller_mc.tabEnabled = false;
playerMain_mc.controller_mc.play_mc.tabIndex = 8;
playerMain_mc.controller_mc.play_mc._accProps = new Object();
playerMain_mc.controller_mc.play_mc._accProps.name = "Play or Pause";
playerMain_mc.controller_mc.rewind_mc.tabIndex = 9;
playerMain_mc.controller_mc.rewind_mc._accProps = new Object();
playerMain_mc.controller_mc.rewind_mc._accProps.name = "Rewind";
playerMain_mc.controller_mc.scrubber_mc._accProps = new Object();
playerMain_mc.controller_mc.scrubber_mc._accProps.silent = true;
playerMain_mc.controller_mc.counter_txt._accProps = new Object();
playerMain_mc.controller_mc.counter_txt._accProps.silent = true;
Accessibility.updateProperties();

//Captivate controller
function startCaptivateMovie() {
	playerMain_mc.presentation.rdcmndResume = 1;
	clearInterval(captivateInterval);
}