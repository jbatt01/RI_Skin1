/*
Flash Companion, Copyright 2004, 2005, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications made to this page for version 1.3.5:
		- Changed the function so that it would allow wrapping of the disctractors setting attributes of labelpath.
	Modifications made to version 3
		- Specific feedback.
*/

//Establish a multiple choice quiz question.

var refreshRevs:Number = 0;
update_mcr_question();

//Sets all the attributes of the multiple choice component
function update_mcr_question(){
	var tempObj:Object = this.multiplechoiceR;
	questionObj = tempObj;
	//Set question text
	var questionText_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "questionText");
	tempObj.Question = questionText_xmlnode.firstChild.nodeValue;
	
	//Set Question parameters
	var quest_params = set_question_params(currentQuestion_xmlnode,tempObj)
	
	//Set Feedback
	var feedback_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild,"feedback");
	do_feedback(feedback_xmlnode,tempObj)
	
	//set distractors
	//get distractor node
	var distractor_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "distractors");
	//cycle through distractors
	if (distractor_xmlnode != null) {
		var randomResponse:Boolean = (distractor_xmlnode.attributes.randomize.toUpperCase() == "TRUE");
		var random_response_array:Array = new Array(); //Array of responses
		var next_distractor_xmlnode:XMLNode = distractor_xmlnode.firstChild;
		for(var i:Number = 1; i<=8;i++){
			if (next_distractor_xmlnode != null && next_distractor_xmlnode.firstChild.nodeValue != undefined) {
				//if it exists, add the label
				//check to see if we need to randomize responses
				if (!randomResponse) {//No need to randomize, so establish settings.
					tempObj["Distractor_Label" + i] = next_distractor_xmlnode.firstChild.nodeValue;
					//set correctness
					var correctness = next_distractor_xmlnode.attributes.correct;
					//trace("correctness: " + correctness)
					if (correctness != undefined) {
						tempObj["Correct_Response" + i] = correctness;
					} else {
						tempObj["Correct_Response" + i] = "false";
					}
					//Specific feedback
					var iFeedback = next_distractor_xmlnode.attributes.iFeedback;
					if (iFeedback !== undefined)
						this["Radiobutton"+i].feedback = iFeedback;
					//Check to see if distractor should wrap text.
					var wraptext:Boolean = (next_distractor_xmlnode.attributes.wrap.toLowerCase() == "true");
					if (wraptext) {
						this["Radiobutton"+i].labelPath.multiline=true;
						this["Radiobutton"+i].labelPath.wordWrap=true;
						this["Radiobutton"+i].labelPath._height=44;
						this["Radiobutton"+i].labelPath._width=this["Radiobutton"+i].width;
					}
				} else { //Need to randomize so store in array.
					random_response_array[i-1] = next_distractor_xmlnode;
				}
			} else {
				//if not hide the checkbox component
				this["Radiobutton" + i]._visible = false;
			}
			next_distractor_xmlnode = next_distractor_xmlnode.nextSibling;
		}
		if (randomResponse) {//Assign Random responses to their location
			var arrayL:Number = random_response_array.length;
			for (var j:Number = 1;j <= arrayL;j++){
				var new_num:Number = randRange(0,(random_response_array.length - 1))
				var tempArray:Array = random_response_array.splice(new_num,1);
				var response_xmlnode:XMLNode = tempArray[0];
				//Assign Values
				tempObj["Distractor_Label" + j] = response_xmlnode.firstChild.nodeValue;
				var correctness = response_xmlnode.attributes.correct;
				//trace("correctness: " + correctness)
				if (correctness != undefined) {
					tempObj["Correct_Response" + j] = correctness;
				} else {
					tempObj["Correct_Response" + j] = "false";
				}
				//Specific feedback
				var iFeedback = response_xmlnode.attributes.iFeedback;
				if (iFeedback !== undefined)
					this["Radiobutton"+j].feedback = iFeedback;
				//Check to see if distractor should wrap text.
				var wraptext:Boolean = (response_xmlnode.attributes.wrap.toLowerCase() == "true");
				if (wraptext) {
					this["Radiobutton"+j].labelPath.multiline=true;
					this["Radiobutton"+j].labelPath.wordWrap=true;
					this["Radiobutton"+j].labelPath._height=44;
					this["Radiobutton"+j].labelPath._width=this["Radiobutton"+j].width;
				}
			}
		}
	}
	quizIntID.push(setInterval(refreshRadios,100));
}

function refreshRadios(){
	refreshRevs++
	if (refreshRevs > 4){
		var popped = quizIntID.pop();
		clearInterval(popped);
	}
	for(var i:Number = 1; i<=8;i++){
		if (playerMain_mc.presentation["Radiobutton" + i]._visible == true){
			//refresh component
			playerMain_mc.presentation["Radiobutton" + i].invalidate();
			
		}
		
	}
	
}
