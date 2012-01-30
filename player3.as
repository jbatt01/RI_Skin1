/*
Flash Companion, Copyright 2004, 2005, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications made to this page for version 1.3:
		- Added code for quiz module.
		- Added function to change navigation for quiz module
		- Moved glossary function from naration.fla to this page in order to make it global
		- Updated loadCurrentPage function to check for a quiz and change navigation
		- In disabling next button we now check to see if the page is a quiz
		- Moved loadCurrentPage() call the player.fla. This accounts for the pre-loader.
		- Changed code for the loading of index to account for new ScrollPane Component. Updated tocSetSelection to work with new component.
		- Changed references to main timeline with Global variable.
		- Added a variable to track content pages for CleanCourse.
	Modifications made to code for version 1.3.5:
		- Updated several functions that were not getting the reference to the index content correct. These functions were used to restrict navigation.
		- Added the topicPageComplete function to correct navigation restriction.
		- Added apiPageComplete function. Call this function when you want to indicate a page is complete. Uses updateStateArray to write this information.
	Modifications made to code for version 2.0:
		- Added transitions for pages
		- Added functions to link to other pages
		- Added Code for Audio button
		- Added Code for Exit button
		- Changed Code so different functionality would work for detatched menu as well.
		- Added code for changing color of styles
	Modification made to code for version 2.2 Interim Release:
		- Change goBackPage and goNextPage so that we can hide certain pages from navigation.
		- Add code to track media pages to fix a bug in the media controller.
		- Hiding and showing next and back buttons added
		- Added ability to resize SWFs
	Modifications made to code for version 3.
		- Added ability to auto navigate a course.
*/
//Keep track of when glossary is loaded
var glossaryLoaded:Boolean = false; 
//page Completed Array and other arrays to hold state information that is generated in toc.as
var page_comp_array:Array;
var select_array:Array = new Array();
var nMaxSelected:Number = 0;
var aPageCompleted:Boolean = false;//Used to determine when template pages have sent pageComplete command
var tranIntID:Number;
//Keep track of current and total page
var total_pages:Number = 0;
//Keeps track of audio
var g_audioOn:Boolean = true;
var g_globalSound:Sound = new Sound();
var g_audioVolume:Number = g_globalSound.getVolume();
var resizeInterval1:Number;
var resizeInterval2:Number;
var aPageCompleteID:Number;
//Object for index
if (detatchedMenu) {//Set in player.fla
	var topic_index_shell:Object = indexName_mc.topic_index_shell;
}
//Use to persist the index or narration when the menu is detached.
var persistIndex:Boolean = false;
//Keep track of most recent quiz
//Added 3/2/2005 for quiz module
var recentQuiz_xmlnode:XMLNode;
//Added to fix bug with media controller
var mediaTemplateRunning:Boolean = false;
//Variables used for hiding and showing navigation buttons
var backButtonHidden:Boolean = false;
var nextButtonHidden:Boolean = false;
//Variable for hiding mask on media templates
var sentShowPageObjects:Boolean = false;
//Import Class for Tooltips
import Tooltips;
var toolTipObj:Tooltips = new Tooltips   (this);
//Media controller variable
var showMediaController:Boolean = false;
//AutoNav ID var
var autoNavID:Number;


stop();
//CleanCourse tracking Variable
var cc_pageName;
//Check to see if you need to hide buttons and page numbering
if (root_xmlnode.attributes.narration == "false") {
	index_read_mc._visible = false;//hide index and read button
	if (readIndexSeparate) {
		//index_btn_mc._visible = false;
		read_btn_mc._visible = false;
	} else {
		read_btn_mc._visible = false;
	}
}
if (root_xmlnode.attributes.glossary == "false") {
	glossary_btn._visible = false;//hide glossary button
}
var page_numbering:Boolean = (root_xmlnode.attributes.pageNumbering.toUpperCase() == "FALSE");
if (page_numbering) {
	pageNumber_mc._visible = false;
} else {
	page_numbering = true;
}
var show_audio_btn:Boolean = (root_xmlnode.attributes.audioButton.toUpperCase() == "FALSE");
if (show_audio_btn) {
	audio_onoff_mc._visible = false;
	vol_outline_mc._visible = false;
}
var show_exit_btn:Boolean = (root_xmlnode.attributes.exitButton.toUpperCase() == "FALSE");
if (show_exit_btn) {
	exit_btn._visible = false;
}
//Functions for color change.
//Extend Color object
Color.prototype.setTint = function (r, g, b, amount) {
	var trans = new Object();
	trans.ra = trans.ga = trans.ba = 100 - amount;
	var ratio = amount / 100;
	trans.rb = r * ratio;
	trans.gb = g * ratio;
	trans.bb = b * ratio;
	this.setTransform(trans);
}
//Functions for color change
function convertHexToR(theColor:String){
	return parseInt(getHexNumber(theColor).substr(0,2),16);
}

function convertHexToG(theColor:String){
	return parseInt(getHexNumber(theColor).substr(2,2),16);
}

function convertHexToB(theColor:String){
	return parseInt(getHexNumber(theColor).substr(4,2),16);
}

function getHexNumber(theColor:String){
	if (theColor.indexOf("0x") >= 0) {
		return theColor.substr(2,6);
	} else if (theColor.indexOf("#") >= 0) {
		return theColor.substr(1,6);
	}
}

//Set color of Interface
if (useInterfaceColors) {//This variable is set in the player.fla file for those styles that were built for tinting.
	var satPct:Number = root_xmlnode.attributes.saturationPercent;

	//Change heading color
	var headerColor:String = root_xmlnode.attributes.headerColor;
	headColor = new Color(top_mc);
	headColor.setTint(convertHexToR(headerColor),convertHexToG(headerColor),convertHexToB(headerColor), satPct);
	//Change footer color
	var footerColor:String = root_xmlnode.attributes.footerColor;
	footColor = new Color(bottom_mc);
	footColor.setTint(convertHexToR(footerColor),convertHexToG(footerColor),convertHexToB(footerColor), satPct);
	//Change glossary background
	var backgroundColor:String = root_xmlnode.attributes.backgroundColor;
	backColor = new Color(background_mc);
	backColor.setTint(convertHexToR(backgroundColor),convertHexToG(backgroundColor),convertHexToB(backgroundColor), satPct);
	//Index background
	var indexColor:String = root_xmlnode.attributes.indexColor;
	indxColor = new Color(indexName_mc.index_bkng_mc);
	indxColor.setTint(convertHexToR(indexColor),convertHexToG(indexColor),convertHexToB(indexColor), satPct);
	
	//Button color
	var buttonColor:String = root_xmlnode.attributes.buttonColor;
	if (useButtonTextColor) {//Set in player.fla for styles that use button text color
		var buttonTextColor:String = root_xmlnode.attributes.buttonTextColor;
		if (includePageNumber) {
			if (readIndexSeparate) {
				var theObjects:Array = ["next_mc","back_mc","audio_onoff_mc","index_btn_mc","read_btn_mc","glossary_btn","exit_btn","pageNumber_mc"];
			} else {
				var theObjects:Array = ["next_mc","back_mc","audio_onoff_mc","index_read_mc","glossary_btn","exit_btn","pageNumber_mc"];
			}
		}else {
			if (readIndexSeparate) {
				var theObjects:Array = ["next_mc","back_mc","audio_onoff_mc","index_btn_mc","read_btn_mc","glossary_btn","exit_btn"];
			} else {
				var theObjects:Array = ["next_mc","back_mc","audio_onoff_mc","index_read_mc","glossary_btn","exit_btn"];
			}
		}
		for (var mc in theObjects){
			var theObject:Object = playerMain_mc[theObjects[mc]];
			//trace(theObject);
			for (var obj in theObject){
				if (typeof (theObject[obj]) == "movieclip") { 
					var objName:String = theObject[obj]._name;
					if (objName.toLowerCase().indexOf("text") > -1){
						//trace("text "+objName);
						bt6Color = new Color(theObject[obj]);
						bt6Color.setTint(convertHexToR(buttonTextColor),convertHexToG(buttonTextColor),convertHexToB(buttonTextColor), satPct);
					} else if (objName.toLowerCase().indexOf("back") > -1){
						//trace("back "+objName);
						b6Color = new Color(theObject[obj]);
						b6Color.setTint(convertHexToR(buttonColor),convertHexToG(buttonColor),convertHexToB(buttonColor), satPct);
					}
				} 
			}
		}
		if (includePageNumber) {
			pageNumber_mc.pageNumber_txt.textColor = buttonTextColor;
		}
	} else {
		b1Color = new Color(exit_btn);
		b1Color.setTint(convertHexToR(buttonColor),convertHexToG(buttonColor),convertHexToB(buttonColor), satPct);
		b2Color = new Color(next_mc);
		b2Color.setTint(convertHexToR(buttonColor),convertHexToG(buttonColor),convertHexToB(buttonColor), satPct);
		b3Color = new Color(back_mc);
		b3Color.setTint(convertHexToR(buttonColor),convertHexToG(buttonColor),convertHexToB(buttonColor), satPct);
		b4Color = new Color(audio_onoff_mc);
		b4Color.setTint(convertHexToR(buttonColor),convertHexToG(buttonColor),convertHexToB(buttonColor), satPct);
		b5Color = new Color(glossary_btn);
		b5Color.setTint(convertHexToR(buttonColor),convertHexToG(buttonColor),convertHexToB(buttonColor), satPct);
		if (readIndexSeparate) {
			b6aColor = new Color(index_btn_mc);
			b6aColor.setTint(convertHexToR(buttonColor),convertHexToG(buttonColor),convertHexToB(buttonColor), satPct);
			b6bColor = new Color(read_btn_mc);
			b6bColor.setTint(convertHexToR(buttonColor),convertHexToG(buttonColor),convertHexToB(buttonColor), satPct);
		} else {
			b6Color = new Color(index_read_mc);
			b6Color.setTint(convertHexToR(buttonColor),convertHexToG(buttonColor),convertHexToB(buttonColor), satPct);
		}
	}
	//Index Header
	var indexHeadColor:String = root_xmlnode.attributes.indexHeader;
	ihColor = new Color(indexName_mc.indexHead_mc);
	ihColor.setTint(convertHexToR(indexHeadColor),convertHexToG(indexHeadColor),convertHexToB(indexHeadColor), satPct);
	//Index Footer
	if (includeIndexFooter)
	{
		ifColor = new Color(indexFoot_mc);
		ifColor.setTint(convertHexToR(indexHeadColor),convertHexToG(indexHeadColor),convertHexToB(indexHeadColor), satPct);
	}
}

//Build Course Heading
//heading_txt.html = true;
heading_txt.text = root_xmlnode.attributes.title;
if (useInterfaceColors) {
	heading_txt.textColor = "0x" + getHexNumber(root_xmlnode.attributes.titleFieldColor);
}

//Set state of the index_read button
var theIndexState:Boolean = true; //true if index is showing. False if narration is showning

//Set color of scroll pane and pop-up message and quiz elements
_global.style.setStyle("themeColor","haloBlue");

//Load the course logo
var courseLogoLoad:Boolean = (root_xmlnode.attributes.loadCourseLogo.toUpperCase() == "TRUE")
var logoFileName:String = playerMain_mc.root_xmlnode.attributes.courseLogo;
if(courseLogoLoad || logoFileName !== undefined)
{
	courseLogoLoad = true;
} else {
	courseLogoLoad = false;
}
var logoListener:Object = new Object();
var logoCounter:Number = 0;
logoListener.onLoadError = function(target_mc:MovieClip, errorCode:String) {
	if (logoCounter < 50) 
	{
		logoCounter++;
		logoLoader.loadClip("course_logo.jpg", courselogo);
	}
}

if (courseLogoLoad) {
	
	var logoLoader:MovieClipLoader = new MovieClipLoader();
	logoLoader.addListener(logoListener);
	if (logoFileName !== undefined)
		logoLoader.loadClip(logoFileName, courselogo);
	else
		logoLoader.loadClip("course_logo.swf", courselogo);
}

//Load viral marketing logo
var noViralLogo:Boolean = root_xmlnode.attributes.noLink.toUpperCase();
if (noViralLogo == "FALSE")
{
	//Show the logo
	
	viralLogo_mc._visible = true;
	viralLogo_mc._alpha = 100;
	viralLogo_mc.onRelease = function()
	{
		getURL("http://www.rapidintake.com/powered_by_unison.php","_blank");
	}
} else {
	//Hide the logo
	viralLogo_mc._visible = false;
	viralLogo_mc._alpha = 0;
}

//Load toc data if necessary
load_quiz_for_question_cnt = (playerMain_mc.root_xmlnode.attributes.include_question_cnt.toUpperCase() == "TRUE");
if (load_quiz_for_question_cnt) {
//Load quiz.xml for determining page count
	var t_rootquiz_xmlnode:XMLNode;          // root node of quiz XML
	var t_currentQuiz_xmlnode:XMLNode;        // quiz node     
	
	var quiz_temp_xml:XML = new XML(); //creates the XML object in Flash
	quiz_temp_xml.load("quiz.xml" + getSkipCacheString());     //load the quiz XML data into the XML object
	quiz_temp_xml.onLoad = readTheQuiz;   //execute this function after loading XML
	quiz_temp_xml.ignoreWhite = true;  //ignore white space between tags in the XML file
} 

function readTheQuiz(load_status){
	if (load_status){
		t_rootquiz_xmlnode = quiz_temp_xml.firstChild;
		t_firstQuiz_xmlnode = getFirst(t_rootquiz_xmlnode.firstChild, "quiz");
		t_currentQuiz_xmlnode = t_firstQuiz_xmlnode;
	}
}

//UI Code for next and back buttons
back_mc.onRollOver = function() {
	this.gotoAndStop("over");
}

back_mc.onRollOut = function() {
	this.gotoAndStop("up");
}

back_mc.onRelease = function() {
	goBackPage();
	this.gotoAndStop("over");
}

back_mc.onPress = function() {
	//Fix focus bug
	playerMain_mc.back_mc._focusrect = false;
	Selection.setFocus(playerMain_mc.back_mc);
	this.gotoAndStop("down");
}

next_mc.onRollOver = function() {
	this.gotoAndStop("over");
}

next_mc.onRollOut = function() {
	this.gotoAndStop("up");
}

next_mc.onRelease = function() {
	goNextPage();
	this.gotoAndStop("over");
}

next_mc.onPress = function() {
	//Correct focus bug
	playerMain_mc.next_mc._focusrect = false;
	Selection.setFocus(playerMain_mc.next_mc);
	this.gotoAndStop("down");
}

//UI Code for index read button
if (readIndexSeparate) {
	index_btn_mc.onRollOver = function(){
		this.gotoAndStop("index_ov");
	}
	index_btn_mc.onRollOut = function(){
		this.gotoAndStop("index_up");
	}
	index_btn_mc.onPress = function(){
		this.gotoAndStop("down");
	}
	index_btn_mc.onRelease = function(){
		showIndex();
		playerMain_mc.theIndexState = true;
	}
	index_btn_mc.onReleaseOutside = function() {
		this.gotoAndStop("index_up");
	}
	
	read_btn_mc.onRollOver = function(){
		this.gotoAndStop("read_ov");
	}
	read_btn_mc.onRollOut = function(){
		this.gotoAndStop("read_up");
	}
	read_btn_mc.onPress = function(){
		this.gotoAndStop("down");
	}
	read_btn_mc.onRelease = function(){
		showNarration();
		playerMain_mc.theIndexState = false;
	}
	read_btn_mc.onReleaseOutside = function() {
		this.gotoAndStop("read_up");
	}
} else {
	index_read_mc.onRollOver = function(){
		if (playerMain_mc.theIndexState){
			this.gotoAndStop("read_ov");
		} else {
			this.gotoAndStop("index_ov");
		}
	}
	
	index_read_mc.onRollOut = function(){
		if (playerMain_mc.theIndexState){
			this.gotoAndStop("read_up");
		} else {
			this.gotoAndStop("index_up");
		}
	}
	
	index_read_mc.onRelease = function(){
		if (playerMain_mc.theIndexState) { //check state 
			this.gotoAndStop("index_ov");
			playerMain_mc.theIndexState = false;
			showNarration();
		} else {
			this.gotoAndStop("read_ov");
			playerMain_mc.theIndexState = true;
			showIndex();
		}
	}
	
	index_read_mc.onPress = function(){
		if (playerMain_mc.theIndexState){
			this.gotoAndStop("index_down");
		} else {
			this.gotoAndStop("read_down");
		}
	}
	
	index_read_mc.onReleaseOutside = function() {
		if (playerMain_mc.theIndexState){
			this.gotoAndStop("read_up");
		} else {
			this.gotoAndStop("index_up");
		}
	}
}

//UI Code for audio button
audio_onoff_mc.onRollOver = function(){
	if (g_audioOn){
		this.gotoAndStop("off_ov");
	} else {
		this.gotoAndStop("on_ov");
	}
}

audio_onoff_mc.onRollOut = function(){
	if (g_audioOn){
		this.gotoAndStop("off_up");
	} else {
		this.gotoAndStop("on_up");
	}
}

audio_onoff_mc.onRelease = function(){
	if (g_audioOn) { //check state 
		this.gotoAndStop("on_ov");
		g_audioOn = false;
		setAudio("off");
	} else {
		this.gotoAndStop("off_ov");
		g_audioOn = true;
		setAudio("on");
	}
}

audio_onoff_mc.onPress = function(){
	if (g_audioOn) { //check state 
		this.gotoAndStop("on_down");
	} else {
		this.gotoAndStop("off_down");
	}
}

audio_onoff_mc.onReleaseOutside = function() {
	if (g_audioOn){
		this.gotoAndStop("off_up");
	} else {
		this.gotoAndStop("on_up");
	}
}

//UI code for Glossary button and Exit button
if (useAllMovieClips){
	glossary_btn.onRollOver = function(){
		this.gotoAndStop("over");
	}
	glossary_btn.onRollOut = function(){
		this.gotoAndStop("up");
	}
	glossary_btn.onRelease = function(){
		this.gotoAndStop("down");
		showGlossary();
	}
	glossary_btn.onReleaseOutside = function(){
		this.gotoAndStop("up");
	}
	
	exit_btn.onRollOver = function(){
		this.gotoAndStop("over");
	}
	exit_btn.onRollOut = function(){
		this.gotoAndStop("up");
	}
	exit_btn.onRelease = function(){
		this.gotoAndStop("down");
		exitCourse();
	}
	exit_btn.onReleaseOutside = function(){
		this.gotoAndStop("up");
	}
} else { 
	glossary_btn.onRelease = function(){
		showGlossary();
	}
	
	exit_btn.onRelease = function(){
		exitCourse();
	}
}

// add the media controller
controller_mc.loadMovie("media_control.swf")

//Load the Index
topic_index_shell.loadScrollContent("toc.swf");
//Check to see if content was loaded.
topic_index_shell.onComplete = function() {
	if (showPreLoader) {
		pctLoad = 95;
		preloader_mc.bar_mc._xscale = pctLoad;
		preloader_mc.percent_txt.text = pctLoad + "%";
		preloader_mc.status_txt.text = "Loading index...";
	}
	playerMain_mc.gotoAndStop(6);
}

// load the movie for the currently selected page
function loadCurrentPage(){
	sentShowPageObjects = false; //Variable for hiding mask on media templates
	//Check to see if first page is hidden.
	if (currentPage_xmlnode.attributes.nonNavPage.toUpperCase() == "TRUE" && !navigateToPage){
		currentPage_xmlnode = getNextNavPage(currentPage_xmlnode);
		tocSetSelection();
	} else {
		navigateToPage = false;
	}
	//trace(currentTopic_xmlnode.childNodes);
	
	var loadPerc:Number = currentPage_xmlnode.attributes.loadPercentage;
	if (loadPerc == 0) {
		playerMain_mc.showMediaController = false;
	} else {
		playerMain_mc.showMediaController = true;
	}
	
	//get path to movie
	contentMoviePath = currentPage_xmlnode.attributes.file;
	//Deals with problem of media pages not loading completely when autoMediaPlay is off.
	if ((contentMoviePath.toLowerCase().indexOf("audio")> -1) || (contentMoviePath.toLowerCase().indexOf("video")> -1)){
		mediaTemplateRunning = true;
	} else {
		mediaTemplateRunning = false;
	}
	//Set variable for CleanCourse WBT Viewer
	cc_pageName = contentMoviePath + " - " + currentPage_xmlnode.attributes.title;
	if (showPageTitle){
		page_title_txt.text = currentPage_xmlnode.attributes.title;
	}
	//Find out if it is a quiz and change navigation buttons accordingly
	//Added 3/3/2005 by SWH for quiz module
	var pType:String = currentPage_xmlnode.attributes.pType;
	if (pType == "quiz") {
		quizNavigation();
		//Page numbering
		if (page_numbering) {
			if (currentPage_xmlnode.attributes.pageNum != undefined) {
				pageNumber_mc.displayPageNumbers(currentPage_xmlnode.attributes.pageNum,total_pages);
			}
		}
	} else {
		resetNavigation();
		//Page numbering
		if (page_numbering) {
			if (currentPage_xmlnode.attributes.pageNum != undefined) {
				pageNumber_mc.displayPageNumbers(currentPage_xmlnode.attributes.pageNum,total_pages);
			}
		}
	}
	
	// see if we are on the first page
	if (firstPage_xmlnode == currentPage_xmlnode)
	{
		//Change focus for accessibility
		//Selection.setFocus(next_mc);
		// we are, disable the back button
		back_mc.gotoAndStop("disable");
		back_mc.enabled = false;
		
		// enable the next button as needed 
		if (!next_mc.enabled)
		{
			next_mc.enabled = true;
			next_mc.gotoAndStop("up");
		}
	}
	else if ((lastPage_xmlnode == currentPage_xmlnode) && (pType != "quiz"))
	{
		//Change focus for accessibility
		//Selection.setFocus(back_mc);
		// we are on the last page, disable the next button
		next_mc.enabled = false;
		next_mc.gotoAndStop("disable");
		
		// enable the back button as needed
		if (!back_mc.enabled)
		{
			back_mc.enabled = true;
			back_mc.gotoAndStop("up");
		}
	}
	else
	{
		// we are on a page in the middle, enable back/prev as needed
		if (!back_mc.enabled)
		{
			back_mc.enabled = true;
			back_mc.gotoAndStop("up");
		}
		if (!next_mc.enabled)
		{
			next_mc.enabled = true;
			next_mc.gotoAndStop("up");
		}
	}
	
	// remember the bookmark
	apiSetBookmark(contentMoviePath);
	
	//Check to see if movie is a raptivity template
	var isRaptivity:Boolean = (currentPage_xmlnode.attributes.raptivity.toUpperCase() == "TRUE");
	if (isRaptivity){
		presentation._lockroot = true;
	}else{
		presentation._lockroot = false;
	}
	// show the clip
	//loadMovie(contentMoviePath,presentation);
	
	var movie_mcl:MovieClipLoader = new MovieClipLoader();
	var mclListener:Object = new Object();
	//When picture loads, position it.
	mclListener.onLoadInit = function(target_mc:MovieClip){
		//Get New Image Size
		if (currentPage_xmlnode.attributes.resizeSWF.toUpperCase() == "TRUE"){
			if (target_mc._height > 0){
				resizeSWFMovie(target_mc)
			} else {
				resizeInterval2 = setInterval(resizeSWFMovie,100,target_mc);
			}
		}
	}
	movie_mcl.addListener(mclListener);
	
	movie_mcl.loadClip(contentMoviePath,presentation)
	//Second resize attempt because of bug in IE that doesn't send onLoadInit
	if (currentPage_xmlnode.attributes.resizeSWF.toUpperCase() == "TRUE"){
			resizeInterval1 = setInterval(resizeSWFMovie,100,playerMain_mc.presentation);
	}
	//Page Transition
	tranMask_mc._visible = false;
	enterPageTransition();
	
	//Hide index if detached
	if (hideAndShowIndex && visibleIndex) {//**************Camtasia*************
		doClosingIndex(); //This custom function needs to be created in the Player.fla file of styles that support it.
	} else if (detatchedMenu) {
		if (persistIndex){
			if (narrationIndexSeparate){
				narration_mc.updateNarration();
			} else if (!playerMain_mc.theIndexState){
				showNarration();
			}
		} else {
			indexName_mc._visible = false;
			if (narrationIndexSeparate){
				narration_mc.unloadMovie();
			}
		}
		persistIndex = (root_xmlnode.attributes.persIndex.toUpperCase() == "TRUE");
	} else {
		if (!playerMain_mc.theIndexState) {
			showNarration();
		}
	}
	//Reposition media controller if necessary
	if ((controller_mc._x < -1000) && (controller_mc.controllerX != undefined)){
		controller_mc._x = controller_mc.controllerX
		controller_mc._y = controller_mc.controllerY
	}
	// Reset Page Completion
	aPageCompleteID = setInterval(reset_aPageCompleted,1000)
	//Check Page Complete for PowerPoint Template
	var usePageComplete:Boolean = playerMain_mc.root_xmlnode.attributes.pageComplete.toLowerCase() == "true";
	var sendPageComplete:Boolean = playerMain_mc.currentPage_xmlnode.attributes.sendPageCompletePPT.toLowerCase() == "true";
	if (usePageComplete && sendPageComplete){ //Is the page complete method being used
		playerMain_mc.apiPageComplete();
	}
	var hideButtons:Boolean = playerMain_mc.currentPage_xmlnode.attributes.hideNavButtons.toUpperCase() == "TRUE";
	if (hideButtons){
		hideBackButton();
		hideNextButton();
	}
}

function reset_aPageCompleted()
{
	clearInterval(aPageCompleteID)
	playerMain_mc.aPageCompleted = false;
}

function resizeSWFMovie(target_mc){
	clearInterval(resizeInterval1);
	clearInterval(resizeInterval2);
	if(currentPage_xmlnode.attributes.newWidth === undefined || currentPage_xmlnode.attributes.newWidth === null || currentPage_xmlnode.attributes.newWidth == ""){
		var newW:Number = playerMain_mc.presentSizeW;
	} else {
		var newW:Number = currentPage_xmlnode.attributes.newWidth;
	}
	if (currentPage_xmlnode.attributes.newHeight === undefined || currentPage_xmlnode.attributes.newHeight === null || currentPage_xmlnode.attributes.newHeight == ""){
		var newH:Number = playerMain_mc.presentSizeH;
	} else {
		var newH:Number = currentPage_xmlnode.attributes.newHeight;
	}
	//Get Existing Image Size
	if (currentPage_xmlnode.attributes.origHeight === undefined || currentPage_xmlnode.attributes.origHeight === null || currentPage_xmlnode.attributes.origHeight == ""){
		var pictH:Number = target_mc._height;
	} else {
		var pictH:Number = currentPage_xmlnode.attributes.origHeight;
	}
	if (currentPage_xmlnode.attributes.origWidth === undefined || currentPage_xmlnode.attributes.origWidth === null || currentPage_xmlnode.attributes.origWidth == ""){
		var pictW:Number = target_mc._width;
	} else {
		var pictW:Number = currentPage_xmlnode.attributes.origWidth;
	}
	
	//trace("target_mc height: " + target_mc._height + " target_mc width: " + target_mc._width)
	//trace("newH: " + newH + "  newW: " + newW + " pictH: " + pictH + " pictW: " + pictW);
	
	
	if (newH > 0 && pictH > 0 && newW > 0 && pictW > 0){
		//Determing Percentage
		newH = Math.round((newH/pictH)*100);
		newW = Math.round((newW/pictW)*100);
		//trace("scaleH: " + newH + "  scaleW: " + newW);
		//Change size
		if (currentPage_xmlnode.attributes.keepProportions.toUpperCase() == "TRUE"){//Check to see if we should maintain proportions
			if (newW <= newH) {
				target_mc._xscale = newW;
				target_mc._yscale = newW;
			} else {
				target_mc._xscale = newH;
				target_mc._yscale = newH;
			}
		} else {
			target_mc._xscale = newW;
			target_mc._yscale = newH;
		}
	}
}

// handle a click on the back button
function goBackPage()
{
	// set the current page and topic
	currentPage_xmlnode = getPrevNavPage(currentPage_xmlnode);
	currentTopic_xmlnode = currentPage_xmlnode.parentNode;

	// update the table of contents
	tocSetSelection(); 
	
	//load the movie
	loadCurrentPage();
}

function goNextPage()
{	
	var nextPg_xmlnode:XMLNode = getNextNavPage(currentPage_xmlnode);
	//trace(nextPg_xmlnode);
	if(nextPg_xmlnode != null){//Accounts for restricted Navigation
		// set the current page and topic
		currentPage_xmlnode = nextPg_xmlnode;
		currentTopic_xmlnode = nextPg_xmlnode.parentNode;

		// update the table of contents
		tocSetSelection();
		
		//load the movie
		loadCurrentPage();
	}	
}

//PREVIOUS PG and NEXT PG functions used by goNextPage and goBackPage
//Separated out in version 2.2 so hidden pages can be accounted for
function getNextNavPage(nextPage_xmlnode:XMLNode){
	// get the next sibling
	nextPageSib_xmlnode = nextPage_xmlnode.nextSibling;
	
	// see if the next sibling exists
	if (nextPageSib_xmlnode != null)
	{
		//Make sure topic is selectable
		if(nextPageSib_xmlnode.nodeName == "topic") {
			//trace(currentPage_xmlnode.parentNode);
			if (!topicPageComplete(nextPage_xmlnode.parentNode)){
				alertLearner();
				return;
			}
			makeSelectable(nextPageSib_xmlnode);
		}
		//In case it returns null store the original value
		tempPageSib_xmlnode = nextPageSib_xmlnode;
		// it does, get the first page for this sibling
		nextPageSib_xmlnode = getFirst(nextPageSib_xmlnode, "page");
		//If it returns null because of empty topic
		if (nextPageSib_xmlnode == null || nextPageSib_xmlnode == undefined || nextPageSib_xmlnode == "")
		{
			return getNextNavPage(tempPageSib_xmlnode);
		}
	}
	else
	{
		// it does not, see if the current topic is complete
		if (!topicComplete(nextPage_xmlnode.parentNode))
		{
			// the topic is not complete, warn and quit
			alertLearner();
			return;
		}
		// there is no next sibling, look up through parent topics
		for (var curTopic_xmlnode:XMLNode = nextPage_xmlnode.parentNode;
			 curTopic_xmlnode != null;
			 curTopic_xmlnode = curTopic_xmlnode.parentNode)
		{
			// see if the higher level topic is complete
			if (!topicComplete(curTopic_xmlnode))
			{
				// the topic is not complete, warn and quit
				alertLearner();
				return;
			}			
			
			// get the next sibling for this topic
			var nextTopic_xmlnode = curTopic_xmlnode.nextSibling;
			
			// see if this next sibling exists
			if (nextTopic_xmlnode != null)
			{
				// it does, find the fist page in this topic
				nextPageSib_xmlnode = getFirst(nextTopic_xmlnode, "page");
				
				// make sure this topic is selectable
				makeSelectable(nextTopic_xmlnode);
				
				// we found the next node so stop looking
				break;
			}
		}
	}
	//Check to see if page is hidden
	//trace("isTocEntry: " + nextPage_xmlnode.parentNode.attributes.isTocEntry + " - nonNavPage: " + nextPage_xmlnode.attributes.nonNavPage)
	if ((nextPageSib_xmlnode.attributes.nonNavPage.toUpperCase() == "TRUE") || (nextPageSib_xmlnode.parentNode.attributes.showTopicPages.toUpperCase() == "FALSE")){
		return(getNextNavPage(nextPageSib_xmlnode))
	} else {
		return(nextPageSib_xmlnode);
	}
}

function getPrevNavPage(prevPageO_xmlnode:XMLNode){
	// get the previous page

	prevPage_xmlnode = prevPageO_xmlnode.previousSibling;
	// see if their is a previous page in this topic
	if (prevPage_xmlnode == null)
	{
		// there is no previous page, look up through parent topics
		for (var curTopic_xmlnode:XMLNode = prevPageO_xmlnode.parentNode;
			 curTopic_xmlnode != null;
			 curTopic_xmlnode = curTopic_xmlnode.parentNode)
		{
			// get the previous sibling for this topic
			var prevTopic_xmlnode = curTopic_xmlnode.previousSibling;
			
			// see if this previous sibling exists
			if (prevTopic_xmlnode != null)
			{
				// it does, find the last page in this topic
				prevPage_xmlnode = getLast(prevTopic_xmlnode, "page");
				break;
			}
		}
	}
	if(prevPage_xmlnode.nodeName == "topic") {//Is it a topic?
		//trace(currentPage_xmlnode.parentNode);
		//In case it returns null store the original value:
		tempPageSib_xmlnode = prevPage_xmlnode;
		// it is, get the last page for the topic
		prevPage_xmlnode = getLast(prevPage_xmlnode, "page");
		//Returns null because of an empty topic.
		if (prevPage_xmlnode == null || prevPage_xmlnode == undefined || prevPage_xmlnode == "")
		{
			prevPage_xmlnode = getLast(tempPageSib_xmlnode.lastChild.previousSibling, "page");
			if (prevPage_xmlnode == null || prevPage_xmlnode == undefined || prevPage_xmlnode == "")
			{
				prevPage_xmlnode = getLast(tempPageSib_xmlnode.previousSibling, "page");
			}
		}
	}

	//Check to see if page is hidden
	//trace("isTocEntry: " + prevPage_xmlnode.parentNode.attributes.isTocEntry + " - nonNavPage: " + prevPage_xmlnode.attributes.nonNavPage)
	if ((prevPage_xmlnode.attributes.nonNavPage.toUpperCase() == "TRUE") || (prevPage_xmlnode.parentNode.attributes.showTopicPages.toUpperCase() == "FALSE")){
		return(getPrevNavPage(prevPage_xmlnode))
	} else {
		return(prevPage_xmlnode);
	}
}

//called from read button
function showNarration() {
	// hide the toc label and scrollpane
	if (narrationIndexSeparate) {
		narration_mc.loadMovie("narration.swf");
	} else {
		topic_index_shell._visible = false;
		if (detatchedMenu) {
			indexName_mc._visible = true;
			indexName_mc.narration_mc.loadMovie("narration.swf");
		} else {
			indexName_mc._visible = false;
			// show the narration scrollpane and load it
			narration_mc.loadMovie("narration.swf");
		}
	}
}

function showIndex(){
	// hide the narration scrollpanel
	if (!narrationIndexSeparate) {
		if (detatchedMenu) {
			indexName_mc.narration_mc.unloadMovie();
		} else {
			narration_mc.unloadMovie();
		}
	}
	// show the toc label and scrollpane
	topic_index_shell._visible = true;
	indexName_mc._visible = true;
}

function showGlossary() {
	glossary_mc.loadMovie("glossary.swf");
}

// set the selection in the table of contents
function tocSetSelection()
{
	// see if the scroll pane movie clip is defined
	var indexObj:Object = topic_index_shell.getScrollContent();
	if (indexObj != undefined)
	{
		// it is, call the toc function
		indexObj.tocSetSelection();
	}
}

// true if the passed topic is complete
function topicComplete(curTopic_xmlnode:XMLNode)
{
	// see if the scroll pane movie clip is defined
	var indexObj:Object = topic_index_shell.getScrollContent();
	if (indexObj != undefined){
		// it is, see if this topic must be completed
		
		if (curTopic_xmlnode.attributes.nav == "complete")
		{
			// it must, return the completion status
			return indexObj.topicComplete(curTopic_xmlnode);
		}
	}
	
	// always return true if there is no TOC function available
	return true;
}

// true if the passed if pages in topic are complete
function topicPageComplete(curTopic_xmlnode:XMLNode)
{
	// see if the scroll pane movie clip is defined
	var indexObj:Object = topic_index_shell.getScrollContent();
	if (indexObj != undefined)
	{
		// it is, see if this topic must be completed
		if (curTopic_xmlnode.attributes.nav == "complete")
		{
			// it must, return the completion status
			return indexObj.topicPageComplete(curTopic_xmlnode);
		}
	}
	
	// always return true if there is no TOC function available
	return true;
}

// make this topic selectable in the TOC
function makeSelectable(curTopic_xmlnode:XMLNode)
{
	// see if the scroll pane movie clip is defined
	var indexObj:Object = topic_index_shell.getScrollContent();
	if (indexObj != undefined)
	{
		// it is, call the function
		indexObj.makeSelectable(curTopic_xmlnode,false);
	}	
}

// alert the learner
function alertLearner()
{
	import mx.controls.Alert;
	alertHandler = function (evt){
					// nothing to do. Just close Alert
	}
	Alert.show("You must complete the current topic before you can move to the next topic.", "Incomplete Topic Alert", Alert.OK, this, alertHandler, "stockIcon", Alert.OK);
}

//Added for Quiz functionality SWH 3/3/05
//Changes navigation buttons to work with a quiz
function quizNavigation() {
	back_mc.onRelease = function() {
		this.gotoAndStop("over");
		presentation.goBackPage();
	}
	next_mc.onRelease = function() {
		this.gotoAndStop("over");
		presentation.goNextPage();
	}
}
function resetNavigation() {
	back_mc.onRelease = function() {
		this.gotoAndStop("over");
		goBackPage();
	}
	next_mc.onRelease = function() {
		this.gotoAndStop("over");
		goNextPage();
	}
}

//Makes glossary links possible
//Moved to main player from navigation.fla to make it global SWH 3/3/05
_global.glossary = function(theTerm:String){
	//trace(theTerm)
	if (glossaryLoaded) {//Is the glossary already open?
		glossary_mc.scrollTerms(theTerm);
	} else {
		showGlossary();
		playerMain_mc.onEnterFrame = function () {
			//trace(playerMain_mc.glossary_mc.getBytesLoaded() + "/" + playerMain_mc.glossary_mc.getBytesTotal());
			if (glossaryLoaded){//Is glossary loaded yet?
				delete playerMain_mc.onEnterFrame;
				glossary_mc.scrollTerms(theTerm);//show term definition
			}
		}
	}
}

//Determine page completion
//This function can be called from a content movie to indicate when the movie has been viewed.
function apiPageComplete(){
	//Check if we should using page complete
	//trace("pageComplete");
	var usePageComplete:Boolean = root_xmlnode.attributes.pageComplete == "true";
	if (usePageComplete) {
		var indexObj:Object = topic_index_shell.getScrollContent();//reference to index movie
		//Get suspend data
		if (page_comp_array == undefined) {//Does the page complete array already exist?
			//Doesn't exist yet so get visited array
			page_comp_array = new Array();
			var suspend_str:Array = apiGetState("toc");
			if (suspend_str != undefined && suspend_str != "") {
				var suspend_array:Array = suspend_str.split(":");
				page_comp_array = suspend_array[0].split(",");
				nMaxSelected = suspend_array[1] - 0;
				select_array = suspend_array[2].split(",");
			} else {
				if (indexObj != undefined){//Make sure object is there then get arrays from the index
					page_comp_array = indexObj.visited_array;
					nMaxSelected = indexObj.nMaxSelect;
					select_array = indexObj.selectable_array;
				}
			}
			
		}
		//Update Array
		if (indexObj != undefined){
			// it is, get clip
			var item_mc = indexObj[currentPage_xmlnode.attributes.mc_str];
			var saveit:Boolean = false;
			if (page_comp_array[item_mc.nIndex] == "0"){
				page_comp_array[item_mc.nIndex] = "1";
				//Show checkmark
				indexObj.setCheckmark(item_mc);
				//Update topic complete
				if (currentPage_xmlnode.parentNode.attributes.nav.toUpperCase() == "COMPLETE"){
					indexObj.makeNextSelectable()
				}
				//assign to state array
				updateStateArray();
			}
		}
	}
	// AUTO NAVIGATION//
	var autoNav:Boolean = root_xmlnode.attributes.autoNavigation == "true";
	if (autoNav)
	{
		autoNavID = setInterval(autoNavGoNext,2000);
	}
}

function autoNavGoNext()
{
	clearInterval(autoNavID);
	var pType:String = currentPage_xmlnode.attributes.pType;
	if ((lastPage_xmlnode != currentPage_xmlnode) && (pType != "quiz"))
	{
		goNextPage();
	
		controller_mc.loadMovie("media_control.swf")
		
	}
}

// update the state information for the table of contents
//	item_mc - the new item
function updateStateArray() {
	//Update Arrays in TOC
	var indexObj:Object = topic_index_shell.getScrollContent();//reference to index movie
	indexObj.visited_array = page_comp_array;
	indexObj.selectable_array = select_array;
	// save visited array : max selectable : selectable array
	apiSetState("toc",page_comp_array.join(",") + ":" + nMaxSelected + ":" + select_array.join(","));
}

//This function is called from an HTML link.
//Lets you go to a page in the course
//pageTitle is the title of the page you want to access or the linkID of that page.
//Defined as a global so it is accessible from any page.
_global.goToPage = function(pageTitle:String){
	//Find the correct node
	if (findNodePageTitle(topics_xmlnode,pageTitle)){
		//trace(currentPage_xmlnode)
		//Select the page in the index.
		tocSetSelection();
		navigateToPage = true;
		//Call function to load current page.
		loadCurrentPage();
	}
	//Make navigation buttons active if necessary
	var showButtons:Boolean = playerMain_mc.currentPage_xmlnode.attributes.hideNavButtons.toUpperCase() != "TRUE";
	//trace(showButtons)
	if (playerMain_mc.backButtonHidden && showButtons){
		playerMain_mc.back_mc._visible = true;
		playerMain_mc.backButtonHidden = false;
	}
	if (playerMain_mc.nextButtonHidden && showButtons){
		playerMain_mc.next_mc._visible = true;
		playerMain_mc.nextButtonHidden = false;
	}
}

//Uses the page title or linkID to determine the page and set the current node.
//Then calls the load page function.
//Similar to findMovieNode function in player2.as but uses the title.
function findNodePageTitle(start_xmlnode:XMLNode,pgTitle:String){
	var done:Boolean = false;
	var returnValue:Boolean = false;
	// see if this is a topic or topics node
	if (start_xmlnode.nodeName != "page"){
		// it is, loop through the children of this node
		// until we find the node with this movie
		for (var cur_xmlnode:XMLNode = start_xmlnode.firstChild;
			 cur_xmlnode != null && !done;
			 cur_xmlnode = cur_xmlnode.nextSibling)
		{
			// look down this node for the movie
			done = findNodePageTitle(cur_xmlnode, pgTitle);
		}
	}else{
		// it is a page, see if this page contains the movie
		if (start_xmlnode.attributes.linkID.toUpperCase() == pgTitle.toUpperCase()){//First check link ID
			currentPage_xmlnode = start_xmlnode;
			currentTopic_xmlnode = currentPage_xmlnode.parentNode;
			// we found the movie so return true
			return true;
		} else if (start_xmlnode.attributes.title.toUpperCase() == pgTitle.toUpperCase()){
			currentPage_xmlnode = start_xmlnode;
			currentTopic_xmlnode = currentPage_xmlnode.parentNode;
			// we found the movie so return true
			return true;
		}
	}
	// did not find the node with the movie
	return done;
}

//Used to turn audio off and on -- Could be expanded for volume
function setAudio(theStatus){
	if (theStatus.toUpperCase() == "ON") {
		g_globalSound.setVolume(g_audioVolume);
	} else if (theStatus.toUpperCase() == "OFF") {
		g_globalSound.setVolume(0);
	} else if (!isNaN(theStatus)) {
		g_globalSound.setVolume(theStatus);
	}
}

//Exit Course Function
//Exit Course Function
var closeIntervalID:Number;
_global.exitCourse = function(){
	if(data_tracking == "SCORM1.2" || data_tracking == "SCORM1.3") {
		apiSendCommit();
		apiSendFinish();
	} else if (data_tracking == "AICC") {
		apiSendFinish();
	}
	closeIntervalID = setInterval(closeTheCourse,500);
}

function closeTheCourse(){
	clearInterval(closeIntervalID)
	if (playerMain_mc._url.indexOf(".exe") > -1 || playerMain_mc._url.indexOf(".hqx") > -1){
		//heading_txt.text = playerMain_mc._url;
		//getURL("javascript:top.close();")
		fscommand("quit")
	} else {
		getURL("javascript:window.open('javascript:window.close();','_self','');");
	}
	
}

//Functions for the hiding and showing of navigation buttons
function hideBackButton(){
	back_mc._visible = false;
	backButtonHidden = true;
}

function hideNextButton(){
	
	next_mc._visible = false;
	nextButtonHidden = true;
	//trace(next_mc._visible)
}

function showBackButton(){
	back_mc._visible = true;
	backButtonHidden = false;
}

function showNextButton(){
	next_mc._visible = true;
	nextButtonHidden = false;
}

//Transitions
#include "transitions.as"

//Accessibility
#include "fc_accessibility.as"