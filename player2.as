/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3 (For Flash Player 8)
	Updates:	 		Steven Hancock

	Modifications made to this page for version 1.3:
		- Updated onEnterFrame event to work with pre-loader.
		- Updated all data tracking functions to work with SCORM or AICC.
	Modifications made to this page for version 1.3.5:
		- Fixed bookmarking so it would work with template pages (added 2 new variables: book_mark_data & book_mark_page_pos, changed apiSetBookmark function, changed findMovieNode function, added findBookMark function.
		- Updated apiSetState so that lesson_status can be set when all pages have been visited.
		- Fixed the apiGetValue function. Was not returning correctly.
		- Changed so that it didn't set the lesson_status to complete each time a course opened.
		- Updated several functions in order to record page completion and course completion.
	Modifications made to this page for version 2:
		- Added ability to track bookmarking and state information to a Flash Cookie.
		- Added SCORM1.3 RTE code.
		- Changed SCORM initialization code.
		- This file was changed to use the Player 8 External Interface. Therefore, works with more browsers.
	Modifications made to this page for version 2.2:
		- Added alert for page bookmarking.
		- Changed some of the communication.
	Modifications made for version 3
		- Improved certain SCORM calls.
*/

// make sure the SCORM loader clip is playing
sl_mc.play();

// globals used to get the LMS data
var nScormIndex:Number = 0; // index into the array of data values
var scormData_array:Array;  // an array of the LMS data we will need in the SCO
var scormValue_array:Array; // the values of the LMS data
var state_array:Array = new Array();  // an array to hold the state information
var _sSep = '`';            // separator to store suspend_data
var loader_cnt:Number = 14;	//Controls advancement of preloader. We start at 14 because that is 30% (30% has loaded already.)
var data_tracking:String; 	//SCORM or AICC
var book_mark_data:String;	//Stores bookmark data for function that discovers correct node
var book_mark_page_pos:Number; //Stores page position for book mark function
var AICC_bookmark:String;	//All AICC_ variables are for AICC tracking.
var AICC_state:String;
var AICC_userid:String;
var AICC_username:String;
var AICC_lessonstatus:String;
var AICC_URL:String;
var AICC_SID:String;
//variable for controlling hidden pages
var navigateToPage:Boolean = false;

//SCORM Variables
var fc_waitTime:Number = 3;
var fc_date:Date = new Date();
var fc_startTime:Number = fc_date.getTime();

//Flash Cookie variables
var COOKIE_bookmark:String;
var COOKIE_state:String;
var bookmark_found:Boolean = false;
//Get method of tracking
data_tracking = root_xmlnode.attributes.tracking.toUpperCase();
//Import Alert Class
import mx.controls.Alert;

// uncomment to get timing information
//var start_date:Date;
//var start_time:Number;
//start_date = new Date();
//start_time = start_date.getTime();

// set our read variable to a non-loaded value
//scormData_txt._visible = false;
//This is used for AICC and SCORM
scormData = "--";

// intialize the array to hold the SCORM names
if (data_tracking == "SCORM1.3") {
	scormData_array = new Array(
	'cmi.location',//*
	'cmi.suspend_data',//*
	'cmi.interactions._count',//*
	
	/* ONLY LOAD THE DATA WE NEED TO SAVE LOADING TIME */	
	'cmi.mode',//*
	'cmi.completion_status',//*
	'cmi.credit',//*
	'cmi.entry',//*
	'cmi.learner_id',//*
	'cmi.learner_name',//*
	'cmi.objectives._count',//*
	'cmi.launch_data',//*
	'cmi.scaled_passing_score',//*
	'cmi.max_time_allowed',//*
	'cmi.time_limit_action',//*
	
	/* LEAST IMPORTANT DATA BELOW */
	'cmi.score.max',//*
	'cmi.score.min',//*
	'cmi.score.raw',//*
	'cmi.total_time',//*
	'cmi.learner_preference.audio_level',//*
	'cmi.learner_preference.language',//*
	'cmi.learner_preference.delivery_speed',//*
	'cmi.learner_preference.audio_captioning',//*
	'cmi.comments_from_learner._children',//*
	'cmi.comments_from_lms._children',//*
	'cmi.score._children',//*
	'cmi.interactions._children',//*
	'cmi.objectives._children',//*
	'cmi.learner_preference._children',//*
	
	/*SCORM RTE 1.3 Specific*/
	'cmi.completion_threshold',
	'cmi.progress_measure',
	'cmi.score.scaled',
	'cmi.success_status');
} else {
	scormData_array = new Array(
	'cmi.core.lesson_location',
	'cmi.suspend_data',
	'cmi.interactions._count',
	
	/* ONLY LOAD THE DATA WE NEED TO SAVE LOADING TIME */	
	'cmi.core.lesson_mode',
	'cmi.core.lesson_status',
	'cmi.core.credit',
	'cmi.core.entry',
	'cmi.core.student_id',
	'cmi.core.student_name',
	'cmi.objectives._count',
	'cmi.launch_data',
	'cmi.student_data.mastery_score',
	'cmi.student_data.max_time_allowed',
	'cmi.student_data.time_limit_action',
	
	/* LEAST IMPORTANT DATA BELOW */
	'cmi.core.score.max',
	'cmi.core.score.min',
	'cmi.core.score.raw',
	'cmi.core.total_time',
	'cmi.student_preference.audio',
	'cmi.student_preference.language',
	'cmi.student_preference.speed',
	'cmi.student_preference.text',
	'cmi.comments',
	'cmi.comments_from_lms',
	'cmi.core._children',
	'cmi.core.score._children',
	'cmi.interactions._children',
	'cmi.objectives._children',
	'cmi.student_data._children',
	'cmi.student_preference._children');
}

// intialize the array to hold the SCORM data
scormValue_array = new Array(scormData_array.length);

// see if we want to use SCORM tracking
if(data_tracking == "SCORM1.2" || data_tracking == "SCORM1.3")
{
	// we do, start the SCORM data loading process
	//fscommand("LMSGetValue", scormData_array[nScormIndex] + ",scormData");
	//Added by Rapid Intake for AICC 3/17/05 SWH
} else if(data_tracking == "AICC"){
	var start_param:String = root_xmlnode.attributes.login_file+";"+root_xmlnode.attributes.activity_ID+";"+root_xmlnode.attributes.activity_name;
	for (var i=0; i<scormValue_array; i++)//Load array with blank values. We don't retrieve as many values for AICC
		scormValue_array[i] = "";
	fscommand("CMIInitialize");
	if (root_xmlnode.attributes.login_file !== undefined){
		fscommand("MM_StartSession", start_param);//Goes to login if necessary.
	}
} else if (data_tracking.toUpperCase() == "COOKIE"){//Tracking Using Flash Cookie
	//trace("cookie");
	var data_cookie_so:SharedObject = SharedObject.getLocal("fc_suspend_data");
	for (var i=0; i<scormValue_array; i++)//Load array with blank values. We don't retrieve as many values for AICC
		scormValue_array[i] = "";
	//Retrieve data from cookie
	COOKIE_bookmark=data_cookie_so.data.bookmark;
	COOKIE_state = data_cookie_so.data.suspend;
	//trace(COOKIE_bookmark);
	//trace(COOKIE_state);
	scormValue_array[0] = COOKIE_bookmark;
	scormValue_array[1] = COOKIE_state;
	loadState();
	playSCO();
} else {
	// we do not, init the value array and continue with the course.
	for (var i=0; i<scormValue_array; i++)
		scormValue_array[i] = "";
	gotoAndStop(5);
}

//Used for SCORM tracking. Make sure API is initialized before starting communication
import flash.external.ExternalInterface;
if(data_tracking == "SCORM1.2" || data_tracking == "SCORM1.3"){
	sl_mc.onEnterFrame = function(){
		var APIFound = ExternalInterface.call("APIOK");
		var LMSInitialized = ExternalInterface.call("isSCOInitialized");
		if (LMSInitialized && APIFound){
			//Initialized so start processing SCORM data.
			startEnterFrame();
		} else {//Check to see how long. After so much time display alert.
			var fc_date2:Date = new Date();
			var fc_startTime2:Number = fc_date2.getTime();
			//trace(fc_startTime + " : " + fc_startTime2);
			if ((fc_startTime2 - fc_startTime) >= (fc_waitTime * 1000)){
				delete sl_mc.onEnterFrame;
				//Display an alert
				
		
				// Define action after alert confirmation.
				var SCORMHandler:Function = function (evt_obj:Object) {
					if (evt_obj.detail == Alert.YES) {
					  //trace("start stock app");
						for (var i=0; i<scormValue_array; i++){
							scormValue_array[i] = "";
						}
						gotoAndStop(5);
					}
				};
				
				// Show alert dialog box.
				var alertBox = Alert.show("The SCORM API was not found. Communication will not occur. Do you want to continue?", "SCORM Error", Alert.YES | Alert.NO, this, SCORMHandler, "stockIcon", Alert.YES);
				alertBox.move(350,150);
			}
		}
	}
} else if (data_tracking == "AICC") {
	//trace("AICC2");
	//scormData_txt.text = "here it is: " + AICC_bookmark + AICC_state;
	if (root_xmlnode.attributes.useCMIResults.toUpperCase() != "FALSE"){
		sl_mc.onEnterFrame = function(){
			if ((AICC_bookmark !== undefined) && (AICC_state !== undefined)){//GEt the state and location info
				delete sl_mc.onEnterFrame;
				scormValue_array[0] = AICC_bookmark;
				scormValue_array[1] = AICC_state;
				scormValue_array[4] = AICC_lessonstatus;
				scormValue_array[7] = AICC_userid;
				scormValue_array[8] = AICC_username;
				fscommand("MM_cmiSetLessonStatus", "i");
				
				loadState();
				playSCO();
			} else {
				var fc_date2:Date = new Date();
				var fc_startTime2:Number = fc_date2.getTime();
				//trace(fc_startTime + " : " + fc_startTime2);
				if ((fc_startTime2 - fc_startTime) >= (fc_waitTime * 1000)){
					delete sl_mc.onEnterFrame;
					//Display an alert
			
					// Define action after alert confirmation.
					var SCORMHandler:Function = function (evt_obj:Object) {
						if (evt_obj.detail == Alert.YES) {
						  //trace("start stock app");
							for (var i=0; i<scormValue_array; i++){
								scormValue_array[i] = "";
							}
							gotoAndStop(5);
						}
					};
					
					// Show alert dialog box.
					var alertBox = Alert.show("Previous launch data was not received from the LMS. Do you want to continue?", "Communication Error", Alert.YES | Alert.NO, this, SCORMHandler, "stockIcon", Alert.YES);
					alertBox.move(350,150);
				}
			}
		}
	} else {
		sl_mc.onEnterFrame = function(){
			if ((AICC_URL !== undefined) && (AICC_SID !== undefined)){//GEt the state and location info
				delete sl_mc.onEnterFrame;
				
				fscommand("MM_cmiSetLessonStatus", "i");
				
				loadState();
				playSCO();
			} else {
				var fc_date2:Date = new Date();
				var fc_startTime2:Number = fc_date2.getTime();
				//trace(fc_startTime + " : " + fc_startTime2);
				if ((fc_startTime2 - fc_startTime) >= (fc_waitTime * 1000)){
					delete sl_mc.onEnterFrame;
					//Display an alert
			
					// Define action after alert confirmation.
					var SCORMHandler:Function = function (evt_obj:Object) {
						if (evt_obj.detail == Alert.YES) {
						  //trace("start stock app");
							for (var i=0; i<scormValue_array; i++){
								scormValue_array[i] = "";
							}
							gotoAndStop(5);
						}
					};
					
					// Show alert dialog box.
					var alertBox = Alert.show("Session ID and URL not received. Do you want to continue?", "Communication Error", Alert.YES | Alert.NO, this, SCORMHandler, "stockIcon", Alert.YES);
					alertBox.move(350,150);
				}
			}
		}
	}
}

// process the enter frame events until all of the SCORM data is loaded
function startEnterFrame() {
	sl_mc.onEnterFrame = function() {
	trace(scormData);
		//Update Pre-loader
		if (showPreLoader) {
			loader_cnt++;
			if (loader_cnt > 40) {
				loader_cnt = 40;
			}
			var loader_amount:Number = Math.ceil((loader_cnt/40) * 80);
			preloader_mc.bar_mc._xscale = loader_amount;
			preloader_mc.percent_txt.text = loader_amount + "%";
			preloader_mc.status_txt.text = "Loading SCORM data...";
		}
		// see if we have received the data
		if(data_tracking == "SCORM1.2" || data_tracking == "SCORM1.3"){
			if (scormData != "--"){
				// we have, insert it in the value array
				scormValue_array[nScormIndex] = scormData;
				
				// reset the value
				scormData = "--";
				
				// increment the count
				nScormIndex++;
				
				// see if we have processed all of the data
				if (nScormIndex == scormData_array.length)
				{
					// we have, stop the events
					delete sl_mc.onEnterFrame;
					
					// break out the suspend_data into our state array
					loadState();
					
					// uncomment to get timing
					//var now_date:Date = new Date();
					//var now_time:Number = now_date.getTime();
					//var elapsed:Number = now_time - start_time;
					//fscommand("LMSSetValue", 'cmi.core.lesson_location,' + elapsed);
					var lesson_status:String = apiGetCompletion();
					if (scormValue_array[3] != "review"){
						if (lesson_status != "passed" && lesson_status != "completed"){
							apiSetCompletion(false,"incomplete");
						}
					}
					if (data_tracking == "SCORM1.2") {
						var errmsg = ExternalInterface.call("SCOSetValue","cmi.core.exit","suspend");
						apiSendCommit()
					} else if (data_tracking == "SCORM1.3"){
						var errmsg = ExternalInterface.call("SCOSetValue","cmi.exit","suspend");
						apiSendCommit()
					}
					// Load the bookmark and go to the next frame
					playSCO();
				}else{
					// more SCORM data to get, get the next one
					scormData = ExternalInterface.call("SCOGetValue",scormData_array[nScormIndex]);
				}
			} else {
				// more SCORM data to get, get the next one
				scormData = ExternalInterface.call("SCOGetValue",scormData_array[nScormIndex]);
			}
		}
	}
};

// gets the bookmark and starts playing the SCO
function playSCO()
{
	// get the SCORM bookmark
	var sMovie:String = apiGetBookmark();
	
	// see if we got a bookmark
	if (sMovie != "" && sMovie !== undefined && sMovie != null && sMovie != "null" && sMovie != "0")
	{
		//**********************************************Bookmarking fix for Learn.com
		if (sMovie.indexOf(".swf") > -1){
			var tempArray:Array = sMovie.split("=");
			if (tempArray.length > 1){
				sMovie = tempArray[1];
			} else {
				sMovie = tempArray[0];
			}
			//Display an alert for bookmark.
			// Define action after alert confirmation.
			var BookmarkHandler:Function = function (evt_obj:Object) {
				if (evt_obj.detail == Alert.YES) {
					// Yes, return to bookmark
					book_mark_page_pos = 0;//Counter for bookmark position. Used to find position for pages named the same.
					findMovieNode(topics_xmlnode, sMovie);
					navigateToPage = true;
					gotoAndPlay(5);
				} else if (evt_obj.detail == Alert.NO) {
					gotoAndPlay(5);
				}
			};
			
			// Show alert dialog box.
			var alertBookmark = Alert.show("This course has been bookmarked. Do you want to return to the last page you visited?", "Course Bookmark", Alert.YES | Alert.NO, this, BookmarkHandler, "stockIcon", Alert.YES);
			alertBookmark.move(350,150);
				
		} else {
			gotoAndPlay(5);
		}		
		
	} else {
		gotoAndPlay(5);
	}
}

// find the node the contains the movie
function findMovieNode(start_xmlnode:XMLNode, sMovie)
{
	var done:Boolean = false;
	var book_mark_array:Array = sMovie.split("|");
	// see if this is a topic or topics node
	if (start_xmlnode.nodeName != "page")
	{
		// it is, loop through the children of this node
		// until we find the node with this movie
		for (var cur_xmlnode:XMLNode = start_xmlnode.firstChild;
			 cur_xmlnode != null && !done;
			 cur_xmlnode = cur_xmlnode.nextSibling)
		{
			// look down this node for the movie
			done = findMovieNode(cur_xmlnode, sMovie);
		}
	}
	else
	{
		// it is a page, see if this page contains the movie
		if (book_mark_array[0].indexOf(start_xmlnode.attributes.file) > -1){
			// it does, check position
			if (book_mark_page_pos == book_mark_array[1]){
				currentPage_xmlnode = start_xmlnode;
				currentTopic_xmlnode.parentNode;
			
				// we found the movie so return true
				return true;
			} else {
				book_mark_page_pos++;
			}
		}
	}

	// did not find the node with the movie
	return done;
}

// get the bookmark
function apiGetBookmark()
{
	// core.lesson_location is in the 0 position
	// it is the bookmark, return it
	var newBookMark:String = scormValue_array[0];
	var subArray:Array = newBookMark.split("~");
	var tmp_str:String = "";
	for (var i:Number=0;i < subArray.length-1;i++)
	{
		tmp_str = tmp_str +  subArray[i] + "\\";
	}
	tmp_str = tmp_str +  subArray[subArray.length-1];

	return tmp_str;//scormValue_array[0];
}

function replaceSlash(page_str:String,loc:Number)
{
	var subArray:Array = page_str.split("\\");
	var tmp_str:String = "";
	for (var i:Number = 0;i < subArray.length-1;i++)
	{
		tmp_str = tmp_str + subArray[i] + "~";
	}
	tmp_str = tmp_str + subArray[subArray.length-1];
	page_str = tmp_str;
	return page_str;
}
	
// set the bookmark
//	page_str - the string containing the bookmark (must be < 128 bytes)
function apiSetBookmark(page_str){
	book_mark_page_pos = 0;
	findBookMark(topics_xmlnode,page_str);
	//Change the \ to a ~ so the bookmark is kept.
	var loc = book_mark_data.indexOf("\\");
	if (loc > -1)
	{
		book_mark_data = replaceSlash(book_mark_data,loc);
	}
	// store the bookmark
	scormValue_array[0] = book_mark_data;
	if (data_tracking == "SCORM1.2") {
		var errmsg = ExternalInterface.call("SCOSetValue","cmi.core.lesson_location",book_mark_data);
	} else if (data_tracking == "SCORM1.3") {
		var errmsg = ExternalInterface.call("SCOSetValue","cmi.location",book_mark_data);
	} else if (data_tracking == "AICC"){
		fscommand("CMISetLocation", book_mark_data);
	}  else if (data_tracking.toUpperCase() == "COOKIE") {
			data_cookie_so.data.bookmark = book_mark_data;
			data_cookie_so.flush();
			//trace("wrote cookie");
	}
	apiSendCommit()
}

//find correct node before bookmarking
function findBookMark(start_xmlnode:XMLNode,page_str:String) {
	var done:Boolean = false;
	// see if this is a topic or topics node
	if (start_xmlnode.nodeName != "page"){
		// it is, loop through the children of this node
		// until we find the node with this movie
		for (var cur_xmlnode:XMLNode = start_xmlnode.firstChild;
			 cur_xmlnode != null && !done;
			 cur_xmlnode = cur_xmlnode.nextSibling)
		{
			// look down this node for the movie
			done = findBookMark(cur_xmlnode, page_str);
		}
	}else{
		// it is a page, see if this page contains the movie
		if (start_xmlnode.attributes.file == page_str){
			// it does, set the current movie and topic
			//trace(page_str + " : " + book_mark_page_pos);
			if(currentPage_xmlnode == start_xmlnode) {
				book_mark_data = page_str + "|" + book_mark_page_pos;
				//trace(book_mark_data);
				return true;
			}else{
				book_mark_page_pos++;
			}
		}
	}
	return done;
}

// get the suspend data
function apiGetSuspendData()
{
	return scormValue_array[1];
}

// set the suspend data
function apiSetSuspendData(suspend_str)
{
	scormValue_array[1] = suspend_str;
	
	if (data_tracking == "SCORM1.2" || data_tracking == "SCORM1.3") {
		var errmsg = ExternalInterface.call("SCOSetValue","cmi.suspend_data",suspend_str);
	} else if (data_tracking == "AICC"){
		fscommand("CMISetData", suspend_str);
	} else if (data_tracking.toUpperCase() == "COOKIE") {
		data_cookie_so.data.suspend = suspend_str;
		data_cookie_so.flush();
	}
}

// get the count of interactions
function apiGetIntCount()
{
	return scormValue_array[2];
}

// set the count of interactions
// since we do not get this from the LMS again, we fake the count
function apiSetIntCount(nNum)
{
	scormValue_array[2] = nNum + "";
}

/*
* return the current hours:minutes:seconds given a data object
*/
function getHMS(dateNow)
{
	var hh = dateNow.getHours();
	var mm = dateNow.getMinutes();
	var ss = dateNow.getSeconds();
	if (hh < 10) hh = "0" + hh;
	if (mm < 10) mm = "0" + mm;
	if (ss < 10) ss = "0" + ss;
	return hh + ":" + mm + ":" + ss;
}

//Returns the date for AICC and SCORM1.3
function getYMD(dateNow,SCORM)
{
	var yy = dateNow.getFullYear();
	var mm = dateNow.getMonth() + 1;
	var dd = dateNow.getDate();
	if (mm < 10) mm = "0" + mm;
	if (dd < 10) dd = "0" + dd;
	if (SCORM){
		return yy + "-" + mm + "-" + dd;
	}else{
		return yy + "/" + mm + "/" + dd;
	}
}

///Returns the date in Date type format (SCORM 1.3)
function getDateType(dateNow){
	return getYMD(dateNow,true) + "T" + getHMS(dateNow);
}


/*
* Load the suspend data into our state array
*/
function loadState()
{
	/* get the suspend_data */
	var sSuspend = apiGetSuspendData();
	
	/* load the data into a temp array */
	var aParts = sSuspend.split(_sSep);
	
	/* loop through the array */
	for (var i=0; i<aParts.length; i=i+2)
	{
		/* see if we have an id */
		if (aParts[i] != "")
		{
			/* we do, copy the data to the state array */
			state_array[ aParts[i] ] = aParts[i+1];
		}
	}
}

/*
* Set the state in suspend data 
* we do this by flattening the data stored in the state array
*/
function saveState()
{
	/* buffer for the state arrray */
	var sSuspend = "";
	
	/* loop through the array */
	for (var i in state_array)
	{
		sSuspend += i + _sSep + state_array[i] + _sSep;
	}
	/* see if there is any data to set */
	if (sSuspend != "")
	{	
		/* there is, store this with SCORM */
		apiSetSuspendData(sSuspend);
	}
}


/* *************************** */
/* FUNCTIONS FOR LOADED MOVIES */
/* *************************** */

/*
* Remember a state value associated with this id
* The state information is held in a javascript array
*/
function apiSetState(sId,sValue)
{
	/* set the state in our state arrat */
	state_array[sId] = sValue;
	
	/* write out the data to LMS */
	saveState();
	
	/*Check completion status*/
	checkComplete(sValue);
}
/*
Passed a string that represents either visited pages
or pages marked complete using apiPageComplete()
Checks for completion and sends message to LMS.
*/
function checkComplete(sValue) {
	if (sValue != undefined){
		// Check to see if all pages are visited. If so submit completed status.
		if (sValue != ""){
			var usePageComplete:Boolean = root_xmlnode.attributes.pageComplete == "true";
			var completion:String = root_xmlnode.attributes.completion.toLowerCase();
			//Check to see if using PageComplete method or simply visit page method
			if (!usePageComplete){
				if (completion != undefined && completion != "" && completion != "none"){
					//Check the completion
					doCompletion(sValue,completion);
				}
			} else {
				if (completion != undefined && completion != "" && completion != "none"){//for this method set completion if not already set.
					completion = "completed"
				}
				//Check the completion
				doCompletion(sValue,completion);
			}
		}
	}
}

//Cycles through visited array to chec completion
function doCompletion(sValue,completion){
	// break it apart (visited array)
	var suspend_array:Array = sValue.split(":");
	var visit_array:Array = suspend_array[0].split(",");
	if (visit_array.length > 0) {
		var course_complete:Boolean = true;
		for (i = 0;i < visit_array.length;i++){
			//Has the page been visited?
			if (visit_array[i] != "1"){
				course_complete = false;
			}
		}
	} else {
		var course_complete:Boolean = false;//default to not complete if array doesn't exist;
	}
	//trace(visit_array);
	//trace(course_complete);
	if (course_complete){//Every page visited?
		apiSetCompletion(true,completion);//record it
	}
}

/*
* Get the state value of this id
*/
function apiGetState(sId)
{
	/* see if there is an ID in the state array */
	if (state_array[sId])
	{
		/* there is, return it */
		return state_array[sId];
	}
	else
	{
		/* there is no ID, return an empty string */
		return "";
	}
}

//Used for Flash Learning Interactions
function sendInteractionInfo(intData){
	var errmsg = ExternalInterface.call("MM_cmiSendInteractionInfo",intData);
}

/*
* set the interaction data for a question - SCORM 1.2
* This function will set:
* cmi.interactions.n.id
* cmi.interactions.n.type
* cmi.interactions.n.student_response
* cmi.interactions.n.correct_responses.0.pattern
* cmi.interactions.n.result
* cmi.interactions.n.time
* cmi.interactions.n.weighting
* cmi.interactions.n.latency
*/
function apiSetInteraction(sId,sType,sResponse,sCorrect,sResult,sWeight,sTime)
{
	if (data_tracking == "SCORM1.2" || data_tracking == "SCORM1.3") {//Added by Rapid Intake 3/17/05 SWH
		/* get the count of interactions from the LMS */
		var sNum = apiGetIntCount();
	
		/* tell the LMS about the interaction */
		var sInt = "cmi.interactions." + sNum + ".";
		var errmsg = ExternalInterface.call("SCOSetValue",sInt + "id",sId);
		errmsg = ExternalInterface.call("SCOSetValue",sInt + "type",sType);
		if (data_tracking == "SCORM1.2") {
			errmsg = ExternalInterface.call("SCOSetValue",sInt + "student_response",sResponse);
		} else if (data_tracking == "SCORM1.3") {
			errmsg = ExternalInterface.call("SCOSetValue",sInt + "learner_response",sResponse);
		}
		errmsg = ExternalInterface.call("SCOSetValue",sInt + "correct_responses.0.pattern",sCorrect);
		errmsg = ExternalInterface.call("SCOSetValue",sInt + "result",sResult);
		var dateNow = new Date();
		if (data_tracking == "SCORM1.2") {
			errmsg = ExternalInterface.call("SCOSetValue",sInt + "time",getHMS(dateNow));
		} else if (data_tracking == "SCORM1.3") {
			errmsg = ExternalInterface.call("SCOSetValue",sInt + "timestamp",getDateType(dateNow));
		}
		if (sWeight!=null) errmsg = ExternalInterface.call("SCOSetValue",sInt + "weighting",sWeight);
		if (sTime!=null)   errmsg = ExternalInterface.call("SCOSetValue",sInt + "latency",sTime);
		
		/* increment the interaction count */
		apiSetIntCount(sNum - 0 + 1);
	} else if (data_tracking == "AICC"){
		var sep:String = ";"
		var dateNow:Date = new Date();
		var aicc_data:String = getYMD(dateNow) + sep + getHMS(dateNow) + sep + sId + sep + objId + sep + sType + sep + sCorrect + sep + sResponse + sep + sResult + sep + sWeight + sep + sTime;
		fscommand("MM_cmiSendInteractionInfo",aicc_data);
	}
}

// set the  score
//	nMin - the minimum score (normalized between 0-100)
//	nMax - the maximum score (normalized between 0-100)
//	nRaw - the learner's score (normalized between 0-100)
function apiSetScore(nMin,nMax,nRaw,sResult)
{
	if (data_tracking == "SCORM1.2") {
		errmsg = ExternalInterface.call("SCOSetValue","cmi.core.score.min",nMin);
		errmsg = ExternalInterface.call("SCOSetValue","cmi.core.score.max",nMax);
		errmsg = ExternalInterface.call("SCOSetValue","cmi.core.score.raw",nRaw);
	} else if (data_tracking == "SCORM1.3") {
		errmsg = ExternalInterface.call("SCOSetValue","cmi.score.min",nMin);
		errmsg = ExternalInterface.call("SCOSetValue","cmi.score.max",nMax);
		errmsg = ExternalInterface.call("SCOSetValue","cmi.score.raw",nRaw);
		errmsg = ExternalInterface.call("SCOSetValue", "cmi.score.scaled",sResult);
	} else if (data_tracking == "AICC"){
		fscommand("CMISetScore", nRaw);
	}
	apiSendCommit()
}
//Set success status
//sStatus - the success status - "passed", "failed", or "unknown"
//Only used for SCORM RTE 1.3
function apiSetSuccess(sStatus){
	if (data_tracking == "SCORM1.3") {
		errmsg = ExternalInterface.call("SCOSetValue","cmi.success_status",sStatus);
		scormValue_array[31] = sStatus;
	}
}

//Get the completion status
function apiGetSuccess() {
	return scormValue_array[31];
}

// set the completion status
//	bComplete - true is SCO is complete - a normal exit is needed
//	            false if SCO is incomplete - a suspended exit is needed
//	sStatus - the completion status - "completed", "incomplete", "passed", or "failed"
function apiSetCompletion(bComplete,sStatus)
{
	if (data_tracking == "SCORM1.2") {//Added by Rapid Intake 3/18/05 SWH
		/* see if the SCO is complete */
		if (bComplete)
		{
			/* it is, set the completion status to normal */
			errmsg = ExternalInterface.call("SCOSetValue","cmi.core.lesson_status",sStatus);
			errmsg = ExternalInterface.call("SCOSetValue","cmi.core.exit,"+"");
		}
		else
		{
			/* not complete, set the status  and the exit to suspend */
			errmsg = ExternalInterface.call("SCOSetValue","cmi.core.lesson_status",sStatus);
			errmsg = ExternalInterface.call("SCOSetValue","cmi.core.exit","suspend");
		}
		scormValue_array[4] = sStatus;
	} else if (data_tracking == "SCORM1.3"){
		if (bComplete)
		{
			/* it is, set the completion status to normal */
			errmsg = ExternalInterface.call("SCOSetValue","cmi.completion_status",sStatus);
			errmsg = ExternalInterface.call("SCOSetValue","cmi.exit","normal");
		}
		else
		{
			/* not complete, set the status  and the exit to suspend */
			errmsg = ExternalInterface.call("SCOSetValue","cmi.completion_status",sStatus);
			errmsg = ExternalInterface.call("SCOSetValue","cmi.exit","suspend");
		}
		scormValue_array[4] = sStatus;
	} else if (data_tracking == "AICC"){
		fscommand("MM_cmiSetLessonStatus", sStatus);
		scormValue_array[4] = sStatus;
	}
	apiSendCommit()
}

//Get the completion status
function apiGetCompletion() {
	return scormValue_array[4];
}

//Commit data
function apiSendCommit(){
	if (data_tracking == "SCORM1.2" || data_tracking == "SCORM1.3") {
		var errmsg = ExternalInterface.call("SCOCommit");
	}
}

//Finish SCO
function apiSendFinish(){
	if (data_tracking == "SCORM1.2" || data_tracking == "SCORM1.3") {
		var errmsg = ExternalInterface.call("SCOFinish");
		//apiSendCommit()
	} else if (data_tracking == "AICC"){
		fscommand("CMIExitAU")
	}
}

// set a SCORM data item
function apiSetValue(sData, sValue)
{
	errmsg = ExternalInterface.call("SCOSetValue",sData,sValue);
}

// get a SCORM data item
function apiGetValue(sData)
{
	// look through the array of data items until we find the name
	for (var i=0; i<scormValue_array.length; i++)
	{
		// see if we found it
		if (scormData_array[i] == sData)
		{
			// we did, return the value
			return scormValue_array[i];
		}
	}
	
	// we did not find it, so return an empty char string
	return "";
}