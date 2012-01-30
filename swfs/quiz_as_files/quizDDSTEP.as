/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Drag and Drop number question
*/

clip_num++;
var aResponseOrder = new Array();
update_ddnum_question();
//Establish a multiple choice quiz question.


//Sets all the attributes of the multiple choice component
function update_ddnum_question(tempObj:Object){
	var tempObj:Object = this.dragdropnumber;
	questionObj = tempObj;
	
	var questionText_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "questionText");
	tempObj.Question = questionText_xmlnode.firstChild.nodeValue;
	//Set Question parameters
	var quest_params = set_question_params(currentQuestion_xmlnode,tempObj)
	
	//Set Feedback
	var feedback_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild,"feedback");
	do_feedback(feedback_xmlnode,tempObj)
		
	//Set drag and target items
	//get dragobjects node
	var drag_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "dragobjects");
	//cycle through drag objects
	if (drag_xmlnode != null) {
		var randomResponse:Boolean = (drag_xmlnode.attributes.randomize.toUpperCase() == "TRUE");
		var random_response_array:Array = new Array(); //Array of responses
		var next_xmlnode:XMLNode = drag_xmlnode.firstChild;

		for(var i:Number = 1; i<=8;i++){
			if (next_xmlnode != null) {
				if (!randomResponse) {
					//if element exists, add the text. It can be HTML
					this["TargetNum" + i].steptext_txt.styleSheet = playerMain_mc.quizCSS;
					this["TargetNum" + i].steptext_txt.html = true;
					this["TargetNum" + i].steptext_txt.htmlText = "<p class = 'steptext'>" + next_xmlnode.firstChild.nodeValue + "</p>";
					
					this["DragNum" + i].num_txt.text = i;
					aResponseOrder[aResponseOrder.length] = next_xmlnode;	
					//Establish Match
					tempObj["dragName" + i] = ("DragNum" + next_xmlnode.attributes.matchelement);
					tempObj["targetName" + i] = ("TargetNum" + i);
				} else {
					random_response_array[i-1] = next_xmlnode;
					this["DragNum" + i].num_txt.text = i;
				}
			} else {
				//if not hide the checkbox component
				this["DragNum" + i]._visible = false;
				this["TargetNum" + i]._visible = false;
			}
			next_xmlnode = next_xmlnode.nextSibling;
		}
		if (randomResponse) {//Assign Random responses to their location
			var arrayL:Number = random_response_array.length;
			for (var j:Number = 1;j <= arrayL;j++){
				var new_num:Number = randRange(0,(random_response_array.length - 1))
				var tempArray:Array = random_response_array.splice(new_num,1);
				var response_xmlnode:XMLNode = tempArray[0];
				//Assign Values
				this["TargetNum" + j].steptext_txt.styleSheet = playerMain_mc.quizCSS;
				this["TargetNum" + j].steptext_txt.html = true;
				this["TargetNum" + j].steptext_txt.htmlText = "<p class = 'steptext'>" + response_xmlnode.firstChild.nodeValue + "</p>";				
			
				aResponseOrder[aResponseOrder.length] = response_xmlnode;					
				//Establish Match
				tempObj["dragName" + j] = ("DragNum" + response_xmlnode.attributes.matchelement);
				tempObj["targetName" + j] = ("TargetNum" + j);				
			}
		}
	}
}