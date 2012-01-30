/*
Flash Companion, Copyright 2004, 2005, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications made to this page for version 1.3.5:
		- Fixed mispelling of variable weight in set_questions_param function to fix weighting problem.
	Modifications made to this page for version 2.1:
		- Added code to include quiz questions in page count.
	Modifications made to this page for version 3:
		- Fixed caching issue
		- Added audio functions for audio questions.
*/

// stop on frame one until we have loaded the XML
stop();

// Global values pointing to XML nodes
var clip_num:Number = 0;				//Mumber for attaching components
var rootquiz_xmlnode:XMLNode;          // root node of quiz XML
var firstQuiz_xmlnode:XMLNode;        // first quiz node
var currentQuiz_xmlnode:XMLNode;        // quiz node     
var firstQuestion_xmlnode:XMLNode;    	// first quiz question
var currentQuestion_xmlnode:XMLNode;  // current question
var lastQuestion_xmlnode:XMLNode;		//last question
var feedback_set:Boolean;				//Global Quiz feedback set
var feedback_provide:Boolean;			//Provide feedback
var feedback_tries:Number;				//Tries allowed
var feedback_initPrompt:String;			//Initial prompt
var feedback_evalPrompt:String;			//Evaluate prompt
var feedback_correct:String;			//Correct Feedback
var feedback_incorrect:String;			//Incorrect Feedback
var feedback_triestext:String;			//Tries feedback
var num_questions:Number;				//Number of questions in quiz
var current_question:Number = 0;		//Current question
var show_results:Boolean;				//Display the results page at end of quiz
var on_intro_page:Boolean = false;			//Indicates if intro page is being shown. Used for navigation
var questionObj:Object;					//Question object currently showing
var random_quiz:Boolean;				//Determines whether quiz is random or not
var random_quiz_array:Array = new Array();			//Array of quiz questions
var on_results_page:Boolean = false;	//Indicates if results page is being shown. Used for navigation.
var include_question:Boolean			//Indicates if question pages should be included in the overall page numbering.
var question_numbering:Boolean;		//Indicates if Questions should be numbered
var quizIntID:Array = new Array();	//Array used to store IDs for setIntevarl that refreshes components.

include_question = (playerMain_mc.root_xmlnode.attributes.include_question_cnt.toUpperCase() == "TRUE");

var quiz_xml:XML = new XML(); //creates the XML object in Flash
quiz_xml.ignoreWhite = true;  //ignore white space between tags in the XML file

if (playerMain_mc.currentQuizString)
{//Preview feature.
    quiz_xml.parseXML("<root><questions>" + playerMain_mc.currentQuizString + "</questions></root>");//parseXML
    readXML(true);
}
else
{
    var cacheString:String = getSkipCacheString();
	if (cacheString === undefined)
		cacheString = "";
	quiz_xml.load("quiz.xml" + cacheString);     //load the SCO's XML data into the XML object
	//trace("quiz.xml" + getSkipCacheString());
    quiz_xml.onLoad = readXML;   //execute this function after loading XML
}

// readXML - called once XML object is loaded
//	load_boolean - true is the XML file could be loaded
function readXML(load_boolean){
	// see if the XML was loaded
	if (load_boolean){
		//Load Style Sheet
		playerMain_mc.quizCSS = new TextField.StyleSheet();
		playerMain_mc.quizCSS.load("swfs/quiz.css");//Load the style sheet.
		playerMain_mc.quizCSS.onLoad = function(ok) {
			if (!ok) {//Did the style load OK? If it doesn't load, no data loads.
				trace("Error loading CSS file.");
			}
		}
		// get global values from the XML
		rootquiz_xmlnode = quiz_xml.firstChild;
		
		// find out if a quiz has already played. If so get it.
		if (recentQuiz_xmlnode === undefined) {
			firstQuiz_xmlnode = getFirst(rootquiz_xmlnode.firstChild, "quiz");
			currentQuiz_xmlnode = firstQuiz_xmlnode;
		} else {
			currentQuiz_xmlnode = recentQuiz_xmlnode;
		}
		
		// Get the next quiz
		var quiz_name_str:String = playerMain_mc.currentPage_xmlnode.attributes.id;
		var nextQuiz_xmlnode:XMLNode = findQuiz(currentQuiz_xmlnode,quiz_name_str);
		//Did we find something?
		if (nextQuiz_xmlnode == null && recentQuiz_xmlnode !== undefined) {
			//start at top of quiz structure and look again
			firstQuiz_xmlnode = getFirst(rootquiz_xmlnode.firstChild, "quiz");
			currentQuiz_xmlnode = firstQuiz_xmlnode;
			nextQuiz_xmlnode = findQuiz(currentQuiz_xmlnode,quiz_name_str);
		} 
		
		//If we found a quiz node continue with loading of questions
		if (nextQuiz_xmlnode != null) {
			currentQuiz_xmlnode = nextQuiz_xmlnode;
			recentQuiz_xmlnode = currentQuiz_xmlnode;
			num_questions = currentQuiz_xmlnode.attributes.numquestions;//number of questions in quiz
			show_results = (currentQuiz_xmlnode.attributes.showresults.toLowerCase() == "true");
			random_quiz = (currentQuiz_xmlnode.attributes.randomize.toLowerCase() == "true");
			question_numbering = (currentQuiz_xmlnode.attributes.number_questions.toLowerCase() == "true");
			//Get Global Feedback if it exists
			var feedback_xmlnode:XMLNode = matchSiblingNode(currentQuiz_xmlnode.firstChild,"feedback");
			if (feedback_xmlnode != null) {
				feedback_set = set_feedback(feedback_xmlnode);
			}
			//Load Question
			if ((random_quiz) && (currentQuiz_xmlnode.attributes.quizmode.toLowerCase() == "test")) {
				loadRandom();
			} else {
				firstQuestion_xmlnode = getFirst(currentQuiz_xmlnode.firstChild, "question");
				lastQuestion_xmlnode = getLast(currentQuiz_xmlnode.lastChild, "question");
				currentQuestion_xmlnode = firstQuestion_xmlnode;
			}
			//Now go to frame that represents question type or the intro
			var intro_page:String = currentQuiz_xmlnode.attributes.intro;
			if (intro_page !== undefined && intro_page != null && intro_page != "") {
				on_intro_page = true;
				gotoAndStop(intro_page);
			} else {
				current_question++;
				showQuestionStart();
			}
		}
		//Display XML parsing Errors
		if (quiz_xml.status != 0) {
			var errorMessage:String;
			switch (quiz_xml.status) {
				case -2 :
				  errorMessage = "A CDATA section was not properly terminated.";
				  break;
				case -3 :
				  errorMessage = "The XML declaration was not properly terminated.";
				  break;
				case -4 :
				  errorMessage = "The DOCTYPE declaration was not properly terminated.";
				  break;
				case -5 :
				  errorMessage = "A comment was not properly terminated.";
				  break;
				case -6 :
				  errorMessage = "An XML element was malformed.";
				  break;
				case -7 :
				  errorMessage = "Out of memory.";
				  break;
				case -8 :
				  errorMessage = "An attribute value was not properly terminated.";
				  break;
				case -9 :
				  errorMessage = "A start-tag was not matched with an end-tag.";
				  break;
				case -10 :
				  errorMessage = "An end-tag was encountered without a matching start-tag.";
				  break;
				default :
				  errorMessage = "An unknown error has occurred.";
				  break;
			}
			trace("The XML file did not parse correctly -- status: "+quiz_xml.status+" ("+errorMessage+")");
		}
		
	} else {
		trace("XML file didn't load: " + quiz_xml.status);
	}
}

//Displays the question
function showQuestion(){
	var qType:String = currentQuestion_xmlnode.attributes.qtype;
	var quiz_mode:String = currentQuiz_xmlnode.attributes.quizmode;
	//Check to see if we need to send apiPageComplete for a quiz without results page.
	var recordStatus:String = currentQuiz_xmlnode.attributes.recordStatus.toLowerCase();
	if (recordStatus == "apipassfail" || recordStatus == "apicompleted"){
		var showResults:Boolean = currentQuiz_xmlnode.attributes.showresults.toLowerCase() == "false"
		var numQuestions:Number = currentQuiz_xmlnode.attributes.numquestions
		if (showResults && current_question == numQuestions){
			playerMain_mc.apiPageComplete();
		}
	}
	if (playerMain_mc.firstPage_xmlnode == playerMain_mc.currentPage_xmlnode){
		// we are on the first page, disable the back button
		var intro_page:String = currentQuiz_xmlnode.attributes.intro;
		if ((intro_page == undefined) && (current_question == 1)){
			playerMain_mc.back_mc.enabled = false;
			playerMain_mc.back_mc.gotoAndStop("disable");
		} else if ((current_question >= 1) && (quiz_mode.toLowerCase() != "test")) {
			playerMain_mc.back_mc.enabled = true;
			playerMain_mc.back_mc.gotoAndStop("up");
		}
	}
	if (quiz_mode.toLowerCase() == "test") {
		playerMain_mc.back_mc.enabled = false;
		playerMain_mc.back_mc.gotoAndStop("disable");
	}
	//Update Page Numbering
	//Also updates page number in goNextPage function for the results page.
	if(include_question){
		playerMain_mc.pageNumber_mc.displayPageNumbers((playerMain_mc.currentPage_xmlnode.attributes.pageNum+current_question),playerMain_mc.total_pages);
	}
	gotoAndStop(qType);
	//Number questions
	if(question_numbering){
		question_count_txt._visible = true;
		question_count_txt.styleSheet = playerMain_mc.quizCSS;
		question_count_txt.html = true;
		question_count_txt.htmlText = "<p class = 'questioncount'>Question " + current_question + " of " + num_questions + "</p>";
	} else {
		question_count_txt._visible = false;
	}
}

//Displays the question
function showQuestionStart(){
	var qType:String = currentQuestion_xmlnode.attributes.qtype;
	var quiz_mode:String = currentQuiz_xmlnode.attributes.quizmode;
	//Check to see if we need to send apiPageComplete for a quiz without results page.
	var recordStatus:String = currentQuiz_xmlnode.attributes.recordStatus.toLowerCase();
	if (recordStatus == "apipassfail" || recordStatus == "apicompleted"){
		var showResults:Boolean = currentQuiz_xmlnode.attributes.showresults.toLowerCase() == "false"
		var numQuestions:Number = currentQuiz_xmlnode.attributes.numquestions
		if (showResults && current_question == numQuestions){
			playerMain_mc.apiPageComplete();
		}
	}
	
	if (playerMain_mc.firstPage_xmlnode == playerMain_mc.currentPage_xmlnode){
		// we are on the first page, disable the back button
		var intro_page:String = currentQuiz_xmlnode.attributes.intro;
		if ((intro_page == undefined) && (current_question == 1)){
			playerMain_mc.back_mc.enabled = false;
			playerMain_mc.back_mc.gotoAndStop("disable");
		} else if ((current_question >= 1) && (quiz_mode.toLowerCase() != "test")) {
			playerMain_mc.back_mc.enabled = true;
			playerMain_mc.back_mc.gotoAndStop("up");
		}
	}
	if (quiz_mode.toLowerCase() == "test") {
		playerMain_mc.back_mc.enabled = false;
		playerMain_mc.back_mc.gotoAndStop("disable");
	}
	gotoAndStop("reset");
}

//returns a node that matches the id attribute
//quiz_xmlnode - a quiz node
//name_str - the id attribute to look for
function findQuiz(quiz_xmlnode:XMLNode, name_str:String){
	//see if the node matches the name string
	for (var current_xmlnode:XMLNode = quiz_xmlnode;
			 current_xmlnode != null;
			 current_xmlnode = current_xmlnode.nextSibling)
		{
			if (current_xmlnode.attributes.id == name_str) {
				return current_xmlnode;
			}
		}
}

//Sets feedback for quiz or individual question
//Returns true is successful
//feedback_xmlnode - a feedback node
function set_feedback(feedback_xmlnode:XMLNode){
	//Establish global feedback variables
	var provide:String = feedback_xmlnode.attributes.provide;
	if (provide != undefined){
		feedback_provide = (provide.toLowerCase() == "true");
	} else {
		feedback_provide = true;
	}
	feedback_tries = Number(feedback_xmlnode.attributes.tries);
	//trace(feedback_xmlnode);
	feedback_initPrompt = get_nodeValue(feedback_xmlnode,"initPrompt");
	feedback_evalPrompt = get_nodeValue(feedback_xmlnode,"evalPrompt");
	feedback_correct = get_nodeValue(feedback_xmlnode,"correctFeedback");
	feedback_incorrect = get_nodeValue(feedback_xmlnode,"incorrectFeedback");
	feedback_triestext = get_nodeValue(feedback_xmlnode,"triesFeedback");
	return true;
}

//Sets individual feedback for a question. If it exists it overrides the global feedback
//Returns true if successful
//feedback_xmlnode - a feedback node
//qtypeObj - Object that will hold all the component parameters
function do_feedback(feedback_xmlnode:XMLNode,qtypeObj:Object){
	//Override Feedback?
	var overrideFeedbackB:Boolean = (currentQuestion_xmlnode.attributes.overrideFeedback.toLowerCase() == "true")
	//Set Feedback option
	var provide:String = feedback_xmlnode.attributes.provide;
	if(overrideFeedbackB){
		if(provide != undefined){ //Is there a feedback setting for this question
			qtypeObj.Feedback = (provide.toLowerCase() == "true");
			//this[qtype].Feedback = provide; //Set feedback
		} else if(feedback_provide != undefined) {//Is global setting available
			qtypeObj.Feedback = feedback_provide; //Set feedback
		}
	} else {
		if(feedback_provide != undefined) {//Is global setting available
			qtypeObj.Feedback = feedback_provide; //Set feedback
		}
	}

	//Set Tries option
	var tries = feedback_xmlnode.attributes.tries;
	if(overrideFeedbackB){
		if(tries != undefined && tries != null && tries != ""){ //Is there a feedback setting for this question
			qtypeObj.Num_Of_Tries = tries; //Set feedback
		} else if(feedback_tries != undefined && feedback_tries != null && feedback_tries != "") {//Is global setting available
			qtypeObj.Num_Of_Tries = feedback_tries; //Set feedback
		}
	} else {
		if(feedback_tries != undefined && feedback_tries != null && feedback_tries != "") {//Is global setting available
			qtypeObj.Num_Of_Tries = feedback_tries; //Set feedback
		}
	}
	
	//Set Initial Prompt
	var prompt = get_nodeValue(feedback_xmlnode,"initPrompt");
	if(overrideFeedbackB){
		//trace(prompt)
		if(prompt != undefined && prompt != "" && prompt != null){ //Is there a feedback setting for this question
			qtypeObj.Initial_Feedback = prompt; //Set feedback
		} else if(feedback_initPrompt != undefined && feedback_initPrompt != null && feedback_initPrompt != "") {//Is global setting available
			qtypeObj.Initial_Feedback = feedback_initPrompt; //Set feedback
		} else {
			qtypeObj.Initial_Feedback = "";
		}
	} else {
		if (feedback_initPrompt != undefined && feedback_initPrompt != null && feedback_initPrompt != ""){
			qtypeObj.Initial_Feedback = feedback_initPrompt; //Set feedback
		}
	}
	
	//Set evaluation Prompt
	var prompt = get_nodeValue(feedback_xmlnode,"evalPrompt");
	if(overrideFeedbackB){
		if(prompt != undefined && prompt != "" && prompt != null){ //Is there a feedback setting for this question
			qtypeObj.Evaluate_Feedback = prompt; //Set feedback
		} else if(feedback_evalPrompt != undefined && feedback_evalPrompt != null && feedback_evalPrompt != "") {//Is global setting available
			qtypeObj.Evaluate_Feedback = feedback_evalPrompt; //Set feedback
		} else {
			qtypeObj.Evaluate_Feedback = ""; //Set feedback
		}
	} else {
		if (feedback_evalPrompt != undefined && feedback_evalPrompt != null && feedback_evalPrompt != ""){
			qtypeObj.Evaluate_Feedback = feedback_evalPrompt; //Set feedback
		}
	}
	
	//Set Correct Feedback
	var prompt = get_nodeValue(feedback_xmlnode,"correctFeedback");
	if(overrideFeedbackB){
		if(prompt != undefined && prompt != "" && prompt != null){ //Is there a feedback setting for this question
			qtypeObj.Correct_Feedback = prompt; //Set feedback
		} else if(feedback_correct != undefined && feedback_correct != null && feedback_correct != "") {//Is global setting available
			qtypeObj.Correct_Feedback = feedback_correct; //Set feedback
		} else {
			qtypeObj.Correct_Feedback = ""; //Set feedback
		}
	} else {
		if (feedback_correct !== undefined && feedback_correct != null && feedback_correct != ""){
			qtypeObj.Correct_Feedback = feedback_correct; //Set feedback
		}
	}
	
	//Set Incorrect Feedback
	var prompt = get_nodeValue(feedback_xmlnode,"incorrectFeedback");
	if(overrideFeedbackB){
		if(prompt != undefined && prompt != "" && prompt != null){ //Is there a feedback setting for this question
			qtypeObj.Incorrect_Feedback = prompt; //Set feedback
		} else if(feedback_incorrect != undefined && feedback_incorrect != null && feedback_incorrect != "") {//Is global setting available
			qtypeObj.Incorrect_Feedback = feedback_incorrect; //Set feedback
		} else {
			qtypeObj.Incorrect_Feedback = ""; //Set feedback
		}
	} else {
		if (feedback_incorrect !== undefined && feedback_incorrect != null && feedback_incorrect != ""){
			qtypeObj.Incorrect_Feedback = feedback_incorrect; //Set feedback
		}
	}
	
	//Set Tries Feedback
	var prompt = get_nodeValue(feedback_xmlnode,"triesFeedback");
	if(overrideFeedbackB){
		if(prompt != undefined && prompt != "" && prompt != null){ //Is there a feedback setting for this question
			qtypeObj.Tries_Feedback = prompt; //Set feedback
		} else if(feedback_triestext != undefined && feedback_triestext != null && feedback_triestext != "") {//Is global setting available
			qtypeObj.Tries_Feedback = feedback_triestext; //Set feedback
		} else {
			qtypeObj.Tries_Feedback = ""; //Set feedback
		}
	} else {
		if (feedback_triestext !== undefined && feedback_triestext != null && feedback_triestext != ""){
			qtypeObj.Tries_Feedback = feedback_triestext; //Set feedback
		}
	}
}

//Take a parent node, find the child node and return the nodeValue
//node_xmlnode - parent node
//node_name - name of node
function get_nodeValue(node_xmlnode:XMLNode,node_name:String){
	//find the node
	var the_node_xmlnode:XMLNode = matchSiblingNode(node_xmlnode.firstChild,node_name)
	//trace(the_node_xmlnode);
	//if found return the value
	if (the_node_xmlnode != null) {
		return the_node_xmlnode.firstChild.nodeValue;
	} else {
		return null;
	}
}

//Set Question Parameters
//questionText_xmlnode - a question node
function set_question_params(question_xmlnode:XMLNode,quest_name_obj:Object) {
	var qid = question_xmlnode.attributes.id;//Interaction ID
	if (qid != undefined) {
		quest_name_obj.Interaction_ID = qid
		//this[quest_name_str].Interaction_ID = qid
	}
	var oid = question_xmlnode.attributes.objectiveID;//Objective ID
	if (oid != undefined) {
		quest_name_obj.Objective_ID = oid
	}
	var tracking = (question_xmlnode.attributes.tracking.toLowerCase() == "true");//Track Data?
	if (tracking != undefined) {
		quest_name_obj.Tracking = tracking
	}
	var weight = question_xmlnode.attributes.weight;//Weight of question
	if (weight != undefined) {
		quest_name_obj.Weighting = weight
	}
	var reset = question_xmlnode.attributes.resetBtn;//Reset button for drag and drop
	if (reset !== undefined) {
		Template_ResetButton._visible = (reset == "true");
	}
	return true;
}

//Function used to establish settings for regular drag and drop questions
function update_ddreg_question(){
	var tempObj:Object = this.dragdropreg;
	questionObj = tempObj;
	//Set question text
	var questionText_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "questionText");
	dragdropreg.Question = questionText_xmlnode.firstChild.nodeValue;
	
	//Set Question parameters
	var quest_params = set_question_params(currentQuestion_xmlnode,tempObj)
	
	//Set Feedback
	var feedback_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild,"feedback");
	do_feedback(feedback_xmlnode,tempObj)
}

//Function used to establish settings for hot spot questions
function update_hotspot_question(){
	var tempObj:Object = this.hotspot1;
	questionObj = tempObj;
	//Set question text
	var questionText_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "questionText");
	hotspot1.Question = questionText_xmlnode.firstChild.nodeValue;
	
	//Set Question parameters
	var quest_params = set_question_params(currentQuestion_xmlnode,tempObj)
	
	//Set Feedback
	var feedback_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild,"feedback");
	do_feedback(feedback_xmlnode,tempObj)
}

//Function used to establish settings for hot object questions
function update_hotobject_question(){
	var tempObj:Object = this.hotobject1;
	questionObj = tempObj;
	//Set question text
	var questionText_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "questionText");
	hotobject1.Question = questionText_xmlnode.firstChild.nodeValue;
	
	//Set Question parameters
	var quest_params = set_question_params(currentQuestion_xmlnode,tempObj)
	
	//Set Feedback
	var feedback_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild,"feedback");
	do_feedback(feedback_xmlnode,tempObj)
}



//Changes the navigation so it will move through the questions in a quiz when previous button is clicked.
function goBackPage() {
	//Pause Sound
	pauseQuestionAudio();
	g_audioPlaying = "none";
	g_audioPaused = false;
	//First check whether the quiz is test or review
	var quiz_mode:String = currentQuiz_xmlnode.attributes.quizmode;
	if (quiz_mode.toLowerCase() != "test") {
		var intro_page:String = currentQuiz_xmlnode.attributes.intro;
		if (on_results_page){
			on_results_page = false;
			gotoAndStop("reset");
			if (playerMain_mc.lastPage_xmlnode == playerMain_mc.currentPage_xmlnode){
				// we are on the last page, enable the next button since it was disabled
				playerMain_mc.next_mc.enabled = true;
				playerMain_mc.next_mc.gotoAndStop("up");
			}
		} else if ((current_question >= 1) && (currentQuestion_xmlnode != firstQuestion_xmlnode)) {
			var next_xmlnode:XMLNode = matchPreviousSiblingNode(currentQuestion_xmlnode.previousSibling,"question");
			if (next_xmlnode != null) {
				currentQuestion_xmlnode = next_xmlnode;
				current_question--;
				gotoAndStop("reset");//Navigate to reset frame, so questions can reset before next question
			} else {
				resetNavigation();
				playerMain_mc.goBackPage()
			}
		} else if ((currentQuestion_xmlnode == firstQuestion_xmlnode) && (intro_page !== undefined) && (!on_intro_page)){
			on_intro_page = true;
			current_question--;
			gotoAndStop(intro_page);
			if (playerMain_mc.firstPage_xmlnode == playerMain_mc.currentPage_xmlnode){
				// we are on the first page, disable the back button
				playerMain_mc.back_mc.enabled = false;
				playerMain_mc.back_mc.gotoAndStop("disable");
			}
		} else {
			resetNavigation();
			playerMain_mc.goBackPage();
		}
	} else {
		resetNavigation();
		playerMain_mc.goBackPage();
	}
}

function checkFormat(string){
	var newFormat = string.toString().split(";").toString();
	return newFormat;
}

// Check the string and remove any trailing commas or semi-colons

function removeChar (string){
	var stringFormat = string.toString();
	var len = stringFormat.length;
	var i=0;
	while (i < len) {
		if(stringFormat.substr(len-1,1) == "," || stringFormat.substr(len-1,1) == ";"){
			stringFormat = stringFormat.slice(0,len-1)
			len = stringFormat.length;
			continue;
		}
		else{
			break;
		}
	}
	return stringFormat;
}

//Changes the navigation so it will move through the questions in a quiz when next button is clicked.
function goNextPage() {
	//Pause Sound
	pauseQuestionAudio();
	g_audioPlaying = "none";
	g_audioPaused = false;
	//This variable is used to determine if they are on the last question or it is set to randomize
	var end_of_quiz:Boolean = (random_quiz || (currentQuestion_xmlnode != lastQuestion_xmlnode));
	if (on_intro_page) {//If they are on the intro page, navigation is different.
		on_intro_page = false;
		current_question++;
		showQuestion();
	} else if (on_results_page) {
		playerMain_mc.apiSendCommit();
		on_results_page = false;
		resetNavigation();
		playerMain_mc.goNextPage();
	} else if ((current_question < num_questions) && (end_of_quiz)) {
		//Automatically check question if next button clicked.
		//trace(SessionArray[session].scoreFlag + "  " + SessionArray[session].answerFlag);
		if ((!SessionArray[session].scoreFlag) && (SessionArray[session].answerFlag)) {
			questionObj.checkQuestion();
		} else if ( SessionArray[session].interaction_type == 'F' ){
			var router = SessionArray[session];
			var rValueRef = new Array();
			var i=0,j=0,count=0;

			// Collect user data from parameter Objects and build Arrays for evaluation
			for(var x in router.response){
				rValueRef[i] = router.response[x];
				i++;
			}
			rValueRef = rValueRef.reverse();
			
			router.correct_response = "{"+checkFormat(removeChar(rValueRef))+"}";
		}
		//find next question
		if((random_quiz) && (currentQuiz_xmlnode.attributes.quizmode.toLowerCase() == "test")) {
			var new_num:Number = randRange(0,(random_quiz_array.length - 1))
			var templist:Array = random_quiz_array.splice(new_num,1);
			var next_xmlnode:XMLNode = templist[0];
		} else {
			var next_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.nextSibling,"question");
		}
		//Display next question
		if (next_xmlnode != null) {
			currentQuestion_xmlnode = next_xmlnode;
			current_question++;
			playerMain_mc.apiSendCommit();
			gotoAndStop("reset");//Navigate to reset frame, so questions can reset before next question
		} else if (show_results){
			//Update Page Numbering
			if(include_question){
				playerMain_mc.pageNumber_mc.displayPageNumbers((playerMain_mc.currentPage_xmlnode.attributes.pageNum+current_question+1),playerMain_mc.total_pages);
			}
			playerMain_mc.apiSendCommit();
			gotoAndStop("results");
			//resetNavigation();
			if (playerMain_mc.lastPage_xmlnode == playerMain_mc.currentPage_xmlnode){
				// we are on the last page, disable the next button
				playerMain_mc.next_mc.enabled = false;
				playerMain_mc.next_mc.gotoAndStop("disable");
			}
		} else {
			resetNavigation();
			playerMain_mc.goNextPage();
		}
	} else if (show_results) {		
		//automatically check question if next button clicked.
		if ((!SessionArray[session].scoreFlag) && (SessionArray[session].answerFlag)) {
			questionObj.checkQuestion();
		} else if ( SessionArray[session].interaction_type == 'F' ){
			var router = SessionArray[session];
			var rValueRef = new Array();
			var i=0,j=0,count=0;

			// Collect user data from parameter Objects and build Arrays for evaluation
			for(var x in router.response){
				rValueRef[i] = router.response[x];
				i++;
			}
			rValueRef = rValueRef.reverse();
			
			router.correct_response = "{"+checkFormat(removeChar(rValueRef))+"}";
		}
		//Update Page Numbering
		if(include_question){
			playerMain_mc.pageNumber_mc.displayPageNumbers((playerMain_mc.currentPage_xmlnode.attributes.pageNum+current_question+1),playerMain_mc.total_pages);
		}
		playerMain_mc.apiSendCommit();
		gotoAndStop("results");
		if (playerMain_mc.lastPage_xmlnode == playerMain_mc.currentPage_xmlnode){
			// we are on the last page, disable the next button
			playerMain_mc.next_mc.enabled = false;
			playerMain_mc.next_mc.gotoAndStop("disable");
		}
		//resetNavigation();
	} else {
		resetNavigation();
		playerMain_mc.goNextPage();
	}
}

function resetNavigation() {
	playerMain_mc.back_mc.onRelease = function() {
		playerMain_mc.goBackPage();
	}
	playerMain_mc.next_mc.onRelease = function() {
		playerMain_mc.goNextPage();
	}
}

//If the quiz is to be random, this function is used to load questions
function loadRandom() {
	firstQuestion_xmlnode = getFirst(currentQuiz_xmlnode.firstChild, "question");
	lastQuestion_xmlnode = getLast(currentQuiz_xmlnode.lastChild, "question");
	var cnt:Number = 0;
	for (var cur_xmlnode = firstQuestion_xmlnode;cur_xmlnode != null;cur_xmlnode = cur_xmlnode.nextSibling){
		if (cur_xmlnode.nodeName == "question") {
			//Place the question node into the array.
			random_quiz_array[cnt] = cur_xmlnode;
			cnt++
		}
	}
	//trace(random_quiz_array.length)
	var cur_num:Number = randRange(0,(random_quiz_array.length - 1))
	var templist:Array = random_quiz_array.splice(cur_num,1);
	currentQuestion_xmlnode = templist[0];
	//trace(random_quiz_array.length)
	//trace(currentQuestion_xmlnode);
}
//generates random number
function randRange(min:Number, max:Number):Number {
  var randomNum:Number = Math.round(Math.random()*(max-min))+min;
  return randomNum;
}


//Audio functions for audio question.

var g_audioPlaying:String = "none";//Determine which audio is playing
var g_audioPaused:Boolean = false;
var g_quizSound:Sound = new Sound();

function playQuestionAudio(theButton:String){
	//Check for paused sound.
	if (g_audioPlaying == theButton && g_audioPaused){
		g_quizSound.start(this[g_audioPlaying].pauseTime/1000);
	} else {
		if (g_audioPlaying != "none"){
			this[g_audioPlaying].gotoAndStop("up_play")
		}
		//Play the audio
		g_quizSound.onLoad = function(success:Boolean) {
			if (success) {
				g_quizSound.start();
			}
			g_audioPlaying = theButton;
		};
		// load the sound
		g_quizSound.loadSound(this[theButton].filepath, true);
		//Turn sound on
		playerMain_mc.g_globalSound.setVolume(playerMain_mc.g_audioVolume);
	}
	
	g_audioPaused = false;
	//trace(theButton)
}

function pauseQuestionAudio(){
	g_audioPaused = true;
	this[g_audioPlaying].pauseTime = g_quizSound.position;
	g_quizSound.stop();
	//trace(theButton)
	//trace("pause audio")
}

g_quizSound.onSoundComplete = function(){
	//trace(playerMain_mc.presentation[g_audioPlaying])
	playerMain_mc.presentation[g_audioPlaying].gotoAndStop("up_play");
	g_audioPlaying = "none";
	g_audioPaused = false;
}

//End Audio Functions