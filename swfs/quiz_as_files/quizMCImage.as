/*
Flash Companion, Copyright 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications made to this page for version 3:
		- New Question.
*/

//Establish a multiple choice quiz question.

var refreshRevs:Number = 0;
update_mc_question();

//Sets all the attributes of the multiple choice component
function update_mc_question(){
	var tempObj:Object = this.multiplechoiceCI;
	questionObj = tempObj;
	//Set question text
	var questionText_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "questionText");
	tempObj.Question = questionText_xmlnode.firstChild.nodeValue;
	updateImageMC();
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
				if (!randomResponse) {//No need to randomize so establish settings.
					tempObj["Distractor_Label" + i] = next_distractor_xmlnode.firstChild.nodeValue;
					//set correctness
					var correctness = next_distractor_xmlnode.attributes.correct;
					if (correctness != undefined) {
						tempObj["Correct_Response" + i] = correctness;
					} else {
						tempObj["Correct_Response" + i] = "false";
					}
					//Check to see if distractor should wrap text.
					var wraptext:Boolean = (next_distractor_xmlnode.attributes.wrap.toLowerCase() == "true");
					if (wraptext) {
						this["CheckboxI"+i].labelPath.multiline=true;
						this["CheckboxI"+i].labelPath.wordWrap=true;
						this["CheckboxI"+i].labelPath._height=44;
						this["CheckboxI"+i].labelPath._width=this["CheckboxI"+i].width;
					}
				} else { //Need to randomize so store in array.
					random_response_array[i-1] = next_distractor_xmlnode;
				}
			} else {
				//if not hide the checkbox component
				this["CheckboxI" + i]._visible = false;
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
				if (correctness != undefined) {
					tempObj["Correct_Response" + j] = correctness;
				} else {
					tempObj["Correct_Response" + j] = "false";
				}
				//Check to see if distractor should wrap text.
				var wraptext:Boolean = (response_xmlnode.attributes.wrap.toLowerCase() == "true");
				if (wraptext) {
					this["CheckboxI"+j].labelPath.multiline=true;
					this["CheckboxI"+j].labelPath.wordWrap=true;
					this["CheckboxI"+j].labelPath._height=44;
					this["CheckboxI"+j].labelPath._width=this["CheckboxI"+j].width;
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
		if (playerMain_mc.presentation["CheckboxI" + i]._visible == true){
			//refresh component
			playerMain_mc.presentation["CheckboxI" + i].invalidate();
		}
		
	}
	
}

function updateImageMC()
{
	//loadImage_mc.removeMovieClip();
	//trace(loadImage_mc)
	//trace(this.getNextHighestDepth())
	//this.createEmptyMovieClip("loadImage_mc",this.getNextHighestDepth());
	//trace(this.text_back_mc._x)
	//loadImage_mc._x = text_back_mc._x + 4;
	//loadImage_mc._y = 3;
	
//trace("updating ImageMC")
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
	var mcLoader2:MovieClipLoader = new MovieClipLoader();
	var mcLoadListen2:Object = new Object();
	mcLoader2.addListener(mcLoadListen2);
	var imageFile:String = currentQuestion_xmlnode.attributes.imageFile;
	mcLoader2.loadClip(imageFile, loadImage_mc);

	mcLoadListen2.onLoadInit = function(mc:MovieClip) {
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
		
		
		//trace("difference: " + diffW + " - " + diffH);
		//trace("final Width: " + mc._width);
		//trace("final Height: " + mc._height);
	}

}