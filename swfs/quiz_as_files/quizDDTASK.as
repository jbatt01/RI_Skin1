/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Drag and Drop Task question.
*/

//Global Variables for positioning dropped items
var target1cnt:Number = 0;
var target2cnt:Number = 0;

var aResponseOrder = new Array();	
//Establish a Drag and Drop Task quiz question.

//Establish a multiple choice quiz question.
update_ddnum_question();

//Sets all the attributes of the multiple choice component
function update_ddnum_question(){
	var tempObj:Object = this.dragdroptask;
	questionObj = tempObj;
	//Set question text
	var questionText_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "questionText");
	tempObj.Question = questionText_xmlnode.firstChild.nodeValue;
	
	//Set Question parameters
	var quest_params = set_question_params(currentQuestion_xmlnode,tempObj)
	//Establish headings on the targets and over drag elements
	var target1:String = currentQuestion_xmlnode.attributes.target1;
	var target2:String = currentQuestion_xmlnode.attributes.target2;
	var drag1:String = currentQuestion_xmlnode.attributes.draghead;
	TargetTask1.target_text1_txt.styleSheet = playerMain_mc.quizCSS;
	TargetTask1.target_text1_txt.html = true;
	TargetTask1.target_text1_txt.htmlText = "<p class='target'>" + target1 + "</p>";
	TargetTask2.target_text2_txt.styleSheet = playerMain_mc.quizCSS;
	TargetTask2.target_text2_txt.html = true;
	TargetTask2.target_text2_txt.htmlText = "<p class='target'>" + target2 + "</p>";
	drag_heading_txt.styleSheet = playerMain_mc.quizCSS;
	drag_heading_txt.html = true;
	drag_heading_txt.htmlText = "<p class='dragtitle'>" + drag1 + "</p>";
	
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
					this["DragTask" + i].task_txt.styleSheet = playerMain_mc.quizCSS;
					this["DragTask" + i].task_txt.html = true;
					this["DragTask" + i].task_txt.htmlText = "<p class='dragtext'>" + next_xmlnode.firstChild.nodeValue + "</p>";
					aResponseOrder[aResponseOrder.length] = next_xmlnode;						
					//Establish Match
					tempObj["dragName" + i] = ("DragTask" + i);
					var matchelement:String = next_xmlnode.attributes.matchelement;
					if (matchelement.toUpperCase() == target1.toUpperCase() || matchelement == "1") {
						trace(matchelement)
						tempObj["targetName" + i] = "TargetTask1";
					} else {
						trace(matchelement)
						tempObj["targetName" + i] = "TargetTask2";
					}
				} else {
					random_response_array[i-1] = next_xmlnode;
				}
			} else {
				//if not hide the checkbox component
				this["DragTask" + i]._visible = false;
			}
			next_xmlnode = next_xmlnode.nextSibling;
		}
		if (randomResponse) {//Assign Random responses to their location
			var arrayL:Number = random_response_array.length;
			for (var j:Number = 1;j <= arrayL;j++){
				var new_num:Number = randRange(0,(random_response_array.length - 1))
				var tempArray:Array = random_response_array.splice(new_num,1);
				var response_xmlnode:XMLNode = tempArray[0];
				aResponseOrder[aResponseOrder.length] = response_xmlnode;				

				//Assign Values
				this["DragTask" + j].task_txt.styleSheet = playerMain_mc.quizCSS;
				this["DragTask" + j].task_txt.html = true;
				this["DragTask" + j].task_txt.htmlText = "<p class='dragtext'>" + response_xmlnode.firstChild.nodeValue + "</p>";
				//Establish Match
				tempObj["dragName" + j] = ("DragTask" + j);
				var matchelement:String = response_xmlnode.attributes.matchelement;
				if (matchelement.toUpperCase() == target1.toUpperCase() || matchelement == "1") {
					tempObj["targetName" + j] = "TargetTask1";
				} else {
					tempObj["targetName" + j] = "TargetTask2";
				}
			}
		}
	}
}