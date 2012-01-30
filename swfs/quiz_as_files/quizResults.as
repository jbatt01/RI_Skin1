/*
Flash Companion, Copyright 2004, 2005, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications made to this page for version 1.3.5:
		- converted weighting value to number so it could be added to score and possible. Fixed weighting problem.
		- Added Possible score field.
		- Added code to record lesson_status based on passing score or completing quiz. Also can base it on apiPageComplete function.
	Modifications made to this page for version 2:
		- Included quiz review.
		- Included style sheet.
	Modifications made to this page for version 3:
		- Ability to print.
		- Ability to send email.
*/


stop();
//Include review functionallity
var quizReview:Boolean = (currentQuiz_xmlnode.attributes.incReview.toUpperCase() == "TRUE");
if (quizReview){
	reviewBtn._visible = true;
	reviewBtn.labelPath.styleSheet = playerMain_mc.quizCSS;
	reviewBtn.labelPath.html = true;
	reviewBtn.labelPath.htmlText = "<p class='buttontext'>Review Test</p>";
	reviewBtn.onPress = function()
	{
		gotoAndPlay( 'review' );
	}
	banner_mc._visible = true;
} else {
	reviewBtn._visible = false;
	banner_mc._visible = false;
}

//Determine Score
computeScore();

var correct:Number;
var percent:Number;

playerMain_mc.reviewBtn.tabIndex = 20;

function computeScore() {
	//establish variables
	correct = 0;
	var incorrect:Number = 0;
	var score:Number = 0;
	var possible:Number = 0;
	var score_array:Array = new Array();
	on_results_page = true;
	//Initialize the array
	if (SessionArray[0].result == "C") {
		correct++;
		score = score + Number(SessionArray[0].weighting);
		possible = possible + Number(SessionArray[0].weighting);
	} else {
		incorrect++;
		possible = possible + Number(SessionArray[0].weighting);
	}
	
	score_array.push([SessionArray[0].interaction_id,SessionArray[0].result]);
	//Cycle through session array to get data.
	var notfound:Boolean = true;
	for (var elem = 1; elem < SessionArray.length; elem++) {
		//Set number correct and incorrect
		var intID:String = SessionArray[elem].interaction_id;
		for (var k in score_array) {
			if (score_array[k][0] == intID) {//Is interaction in score array?
				if ((score_array[k][1] == "W") || (score_array[k][1] == undefined)) {
					if (SessionArray[elem].result == "C") {
						score_array[k][1] = "C";
						correct++;
						score = score + Number(SessionArray[elem].weighting);
						incorrect--;
					} else {
						score_array[k][1] = "W";
					}
				} else if (score_array[k][1] == "C") {
					if (SessionArray[elem].result == "W") {
						//Main Score
						score_array[k][1] = "W";
						correct--;
						incorrect++;
						score = score - Number(SessionArray[elem].weighting);
					} else {
						score_array[k][1] = "C";
					}
				}
				notfound = false;
				break;
			}
		}
		if (notfound) { //If not in score array put it there and add the score.
			score_array.push([intID,SessionArray[elem].result])
			if (SessionArray[elem].result == "C") {
				correct++;
				score = score + Number(SessionArray[elem].weighting);
				possible = possible + Number(SessionArray[elem].weighting);
			} else {
				incorrect++;
				possible = possible + Number(SessionArray[elem].weighting);
			}
		}
		notfound = true;
	}
	//trace(score_array.length);
	//display information
	correct_txt.styleSheet = playerMain_mc.quizCSS;
	incorrect_txt.styleSheet = playerMain_mc.quizCSS;
	score_txt.styleSheet = playerMain_mc.quizCSS;
	possible_txt.styleSheet = playerMain_mc.quizCSS;
	percent_txt.styleSheet = playerMain_mc.quizCSS;
	correct_txt.html = true;
	incorrect_txt.html = true;
	score_txt.html = true;
	possible_txt.html = true;
	percent_txt.html = true;
	var textPre:String = "<p class = 'resultvalue'>";
	var textPost:String = "</p>";
	correct_txt.htmlText = textPre + correct + textPost;
	incorrect_txt.htmlText = textPre + incorrect + textPost;
	score_txt.htmlText = textPre + score + textPost;
	possible_txt.htmlText = textPre + possible + textPost;
	percent = Math.round((score/possible)*100);
	percent_txt.htmlText = textPre + percent + "%" + textPost;
	
	//Record information in LMS
	var reportScore = (currentQuiz_xmlnode.attributes.reportScore.toLowerCase() == "true")
	if (reportScore)
	{
		var nMin = currentQuiz_xmlnode.attributes.minscore;
		var nMax = currentQuiz_xmlnode.attributes.maxscore;
		if ((nMin !== undefined) && (nMax !== undefined)) {
			
		} else {
			nMin = 0;
			nMax = 100;
		}
		if (playerMain_mc.data_tracking == "SCORM1.2") {
			playerMain_mc.apiSetScore(nMin,nMax,percent);
		} else if (playerMain_mc.data_tracking == "SCORM1.3") {
			playerMain_mc.apiSetScore(nMin,nMax,percent,percent/100);
		} else if (playerMain_mc.data_tracking == "AICC"){
			playerMain_mc.apiSetScore(nMin,nMax,percent);
		}
	}
	var recordStatus:String = currentQuiz_xmlnode.attributes.recordStatus.toLowerCase();
	//Should we record lesson status once quiz is complete?
	if (recordStatus == "passfail" || recordStatus == "apipassfail"  || recordStatus == "passincomplete") {//Yes record pass/fail
		var passScore:Number = Number(currentQuiz_xmlnode.attributes.passingScore);
		if (percent >= passScore){//did they pass?
			if (recordStatus == "apipassfail") {
				playerMain_mc.apiPageComplete();
			} else {
				if (playerMain_mc.data_tracking == "SCORM1.2" || playerMain_mc.data_tracking == "AICC") {
					playerMain_mc.apiSetCompletion(true,"passed");
				} else if (playerMain_mc.data_tracking == "SCORM1.3") {
					var scormStatus:Boolean = (currentQuiz_xmlnode.attributes.passComplete.toUpperCase() == "TRUE")
					playerMain_mc.apiSetSuccess("passed")
					if (scormStatus){
						playerMain_mc.apiSetCompletion(true,"completed");
					}
				}
			}
			status_txt.styleSheet = playerMain_mc.quizCSS;
			status_txt.html = true;
			status_txt.htmlText = "<p class = 'success'>" + "Congratulations! That is a passing score." + "</p>";
		}else{
			if (recordStatus == "passfail"){
				if (playerMain_mc.data_tracking == "SCORM1.2" || playerMain_mc.data_tracking == "AICC") {
					playerMain_mc.apiSetCompletion(true,"failed");
				} else if (playerMain_mc.data_tracking == "SCORM1.3") {
					var scorm13status:Boolean = (currentQuiz_xmlnode.attributes.failIncomplete.toUpperCase() == "TRUE")
					playerMain_mc.apiSetSuccess("failed")
					if (scorm13status){
						playerMain_mc.apiSetCompletion(true,"incomplete");
					}
				}
				
			}
			if (recordStatus == "passincomplete" && playerMain_mc.data_tracking == "SCORM1.2"){
				playerMain_mc.apiSetCompletion(true,"incomplete");
			}
			status_txt.styleSheet = playerMain_mc.quizCSS;
			status_txt.html = true;
			status_txt.htmlText = "<p class = 'failure'>" + "Sorry, that is not a passing score." + "</p>";
		}
	} else if (recordStatus == "completed") {//Yes, record completed
		playerMain_mc.apiSetCompletion(true,"completed");
		//trace("sent completion");
	} else if (recordStatus == "apicompleted") {
		playerMain_mc.apiPageComplete();
	}
	//trace("score: " + score + " -- " + "possible: " + possible);
	//trace(score_array);
	//playerMain_mc.back_mc.enabled = false;
	//playerMain_mc.back_mc.gotoAndStop("disable");
}

//Ability to print:
#include "quiz_as_files/printResults.as"