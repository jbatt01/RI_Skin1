/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Essay Question
*/

//Establish an essay quiz question.
Template_UserEntry.setStyle( "backgroundColor", "white" );
Template_UserEntry.setStyle("borderStyle","inset");

update_essay_question();

//Sets all the attributes of the component
function update_essay_question(){
	var tempObj:Object = this.essay;
	questionObj = tempObj;
	//Set question text
	var questionText_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "questionText");
	tempObj.Question = questionText_xmlnode.firstChild.nodeValue;
	
	//Set Question parameters
	var quest_params = set_question_params(currentQuestion_xmlnode,tempObj)
	
	//Set Feedback
	var feedback_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild,"feedback");
	do_feedback(feedback_xmlnode,tempObj)
	
	//set responses
	//get responses node
	var responses_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "responses");
	//cycle through responses
	if (responses_xmlnode != null) {
		var exactMatch:String = responses_xmlnode.attributes.exactMatch;
		var caseSensitive:String = responses_xmlnode.attributes.caseSensitive;
		var otherRespCorrect:String = responses_xmlnode.attributes.otherRespCorrect;
		tempObj.Exact_Match = (exactMatch.toLowerCase() == "true");
		tempObj.Case_Sensitive = (caseSensitive.toLowerCase() == "true");
		tempObj.Other_Responses = (otherRespCorrect.toLowerCase() == "true");
		var next_response_xmlnode:XMLNode = responses_xmlnode.firstChild;
		for(var i:Number = 1; i<=5;i++){
			if (next_response_xmlnode != null) {
				//if it exists, add the label
				tempObj["Response" + i] = next_response_xmlnode.firstChild.nodeValue;
				//set correctness
				var correctness:String = next_response_xmlnode.attributes.correct;
				if (correctness != undefined) {
					tempObj["Response_Value" + i] = (correctness.toLowerCase() == "true");
				}
			}
			next_response_xmlnode = next_response_xmlnode.nextSibling;
		}
	}
}

