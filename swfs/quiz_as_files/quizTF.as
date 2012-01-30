/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	True False question
*/

//Establish a True/False quiz question.
var refreshRevs:Number = 0;
update_tf_question();

//Sets all the attributes of the multiple choice component
function update_tf_question(){
	var tempObj:Object = this.truefalse;
	questionObj = tempObj;
	//Set question text
	var questionText_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "questionText");
	tempObj.Question = questionText_xmlnode.firstChild.nodeValue;
	
	//Set Question parameters
	var quest_params = set_question_params(currentQuestion_xmlnode,tempObj)
	
	//Set Feedback
	tempObj.ButtonLabels4 = "Reset";
	var feedback_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild,"feedback");
	do_feedback(feedback_xmlnode,tempObj)
	
	//set correct response
	var correctResp:String = currentQuestion_xmlnode.attributes.correctResp;
	tempObj.Correct_Response = (correctResp.toLowerCase() == "true")
	quizIntID.push(setInterval(refreshRadios,100));
}

function refreshRadios(){
	refreshRevs++
	if (refreshRevs > 4){
		//clearInterval(quizIntID);
		var popped = quizIntID.pop();
		clearInterval(popped);
	}
	for(var i:Number = 1; i<=8;i++){
		if (playerMain_mc.presentation["Template_Radio" + i]._visible == true){
			//refresh component
			playerMain_mc.presentation["Template_Radio" + i].invalidate();
		}
		
	}
	
}

