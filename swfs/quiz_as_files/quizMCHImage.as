/*
Flash Companion, Copyright 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications made to this page for version 3:
		- New Question with this release.
*/

//Establish a multiple choice quiz question.

var refreshRevs:Number = 0;
update_mcr_question();

//Sets all the attributes of the multiple choice component
function update_mcr_question(){
	var tempObj:Object = this.multiplechoiceI;
	questionObj = tempObj;
	//Set question text
	var questionText_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "questionText");
	tempObj.Question = questionText_xmlnode.firstChild.nodeValue;
	updateImage();
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
		for(var i:Number = 1; i<=6;i++){
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
						this["RadiobuttonI"+i].feedback = iFeedback;
					//Check to see if distractor should wrap text.
					var wraptext:Boolean = (next_distractor_xmlnode.attributes.wrap.toLowerCase() == "true");
					if (wraptext) {
						this["RadiobuttonI"+i].labelPath.multiline=true;
						this["RadiobuttonI"+i].labelPath.wordWrap=true;
						this["RadiobuttonI"+i].labelPath._height=44;
						this["RadiobuttonI"+i].labelPath._width=this["RadiobuttonI"+i].width;
					}
				} else { //Need to randomize so store in array.
					random_response_array[i-1] = next_distractor_xmlnode;
				}
			} else {
				//if not hide the checkbox component
				this["RadiobuttonI" + i]._visible = false;
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
					this["RadiobuttonI"+j].feedback = iFeedback;
				//Check to see if distractor should wrap text.
				var wraptext:Boolean = (response_xmlnode.attributes.wrap.toLowerCase() == "true");
				if (wraptext) {
					this["RadiobuttonI"+j].labelPath.multiline=true;
					this["RadiobuttonI"+j].labelPath.wordWrap=true;
					this["RadiobuttonI"+j].labelPath._height=44;
					this["RadiobuttonI"+j].labelPath._width=this["RadiobuttonI"+j].width;
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
		if (playerMain_mc.presentation["RadiobuttonI" + i]._visible == true){
			//refresh component
			playerMain_mc.presentation["RadiobuttonI" + i].invalidate();
			
		}
		
	}
	
}

function updateImage()
{
	//loadImage_mc.removeMovieClip();
	//this.createEmptyMovieClip("loadImage_mc",this.getNextHighestDepth());
	//loadImage_mc._x = text_back_mc._x + 4;;
	//loadImage_mc._y = 3;
	

	//Set Sizes
	if (playerMain_mc.presentSizeH >= 485)
	{
		var newHeight:Number = 170;
	} else if (playerMain_mc.presentSizeH >= 450) {
		var newHeight:Number = 150;
	} else {
		var newHeight:Number = 140;
	}
	var newWidth:Number = 250;
	
	//Loader 
	var mcLoader:MovieClipLoader = new MovieClipLoader();
	var mcLoadListen:Object = new Object();
	mcLoader.addListener(mcLoadListen);
	var imageFile:String = currentQuestion_xmlnode.attributes.imageFile;
	mcLoader.loadClip(imageFile, loadImage_mc);

	mcLoadListen.onLoadInit = function(mc:MovieClip) {
		//trace(mc._width);
		//trace(mc._height);
		
		var scaleSizeH:Number = 100;
		var scaleSizeW:Number = 100;
		if (mc._width > newWidth)
			scaleSizeW = Math.floor((newWidth/mc._width*100));
		if (mc._height > newHeight)
			scaleSizeH = Math.floor((newHeight/mc._height*100));
			
		var scaleSize:Number = Math.min(scaleSizeW,scaleSizeH);
		mc._xscale = scaleSize;
		mc._yscale = scaleSize;
		//trace("scaleSize Width: " + scaleSize);
		Template_Question._x = mc._x + mc._width + 10;
		Template_Question._width = playerMain_mc.presentSizeW - mc._x - mc._width - 15;
		
		//trace("final Width: " + mc._width);
		//trace("final Height: " + mc._height);
	}
}