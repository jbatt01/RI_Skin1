/*
Flash Companion, Copyright 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	MC Audio Question
*/

//Establish a multiple choice quiz question.

var refreshRevs:Number = 0;
update_mc_question();

//Sets all the attributes of the multiple choice component
function update_mc_question(){
	var tempObj:Object = this.multiplechoiceA;
	questionObj = tempObj;
	//Set question text
	var questionText_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "questionText");
	tempObj.Question = questionText_xmlnode.firstChild.nodeValue;
	
	//Set up question Audio
	var qAudio:String = questionText_xmlnode.attributes.filePath;
	if (qAudio !== undefined){
		playQAudio.filepath = qAudio;
	} else {
		playQAudio._visible = false;
	}
	
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
						this["CheckboxA"+i].labelPath.multiline=true;
						this["CheckboxA"+i].labelPath.wordWrap=true;
						this["CheckboxA"+i].labelPath._height=44;
						this["CheckboxA"+i].labelPath._width=this["CheckboxA"+i].width;
					}
					//Set up the Audio
					var dAudio:String = next_distractor_xmlnode.attributes.filePath;
					if (dAudio !== undefined){
						this["playAudio"+i].filepath = next_distractor_xmlnode.attributes.filePath;
					} else {
						this["playAudio"+i]._visible = false;
					}
				} else { //Need to randomize so store in array.
					random_response_array[i-1] = next_distractor_xmlnode;
				}
			} else {
				//if not hide the checkbox component
				this["CheckboxA" + i]._visible = false;
				//hide the audio button
				this["playAudio"+i]._visible = false;
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
					this["CheckboxA"+j].labelPath.multiline=true;
					this["CheckboxA"+j].labelPath.wordWrap=true;
					this["CheckboxA"+j].labelPath._height=44;
					this["CheckboxA"+j].labelPath._width=this["CheckboxA"+j].width;
				}
				//Set up the Audio
				var dAudio:String = response_xmlnode.attributes.filePath;
				if (dAudio !== undefined){
					this["playAudio"+j].filepath = response_xmlnode.attributes.filePath;
				} else {
					this["playAudio"+j]._visible = false;
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
		if (playerMain_mc.presentation["CheckboxA" + i]._visible == true){
			//refresh component
			playerMain_mc.presentation["CheckboxA" + i].invalidate();
		}
		
	}
	
}

//Audio Buttons

playQAudio.onRollOver = function(){
	if (g_audioPlaying == "playQAudio"){
		if (g_audioPaused){
			this.gotoAndStop("over_play")
		} else {
			this.gotoAndStop("over_pause")
		}
	} else {
		this.gotoAndStop("over_play")
	}
}

playQAudio.onRollOut = function(){
	if (g_audioPlaying == "playQAudio"){
		if (g_audioPaused){
			this.gotoAndStop("up_play")
		} else {
			this.gotoAndStop("up_pause")
		}
	} else {

		this.gotoAndStop("up_play")
	}
}

playQAudio.onRelease = function(){
	if (g_audioPlaying == "playQAudio"){
		if (g_audioPaused){
			this.gotoAndStop("over_pause")
			playQuestionAudio(this._name);
		} else {
			this.gotoAndStop("over_play")
			pauseQuestionAudio()
		}
	} else {
		this.gotoAndStop("over_pause")
		playQuestionAudio(this._name);
	}
	
}

playQAudio.onPress = function(){
	if (g_audioPlaying == "playQAudio"){
		if (g_audioPaused){
			this.gotoAndStop("down_play")
		} else {
			this.gotoAndStop("down_pause")
		}
	} else {
		this.gotoAndStop("down_play")
	}
}

for (var m:Number=1;m<9;m++){
	this["playAudio"+m].onRollOver = function(){
		//trace(g_audioPlaying)
		if (g_audioPlaying == this._name){
			if (g_audioPaused){
				this.gotoAndStop("over_play")
			} else {
				this.gotoAndStop("over_pause")
			}
		} else {
			this.gotoAndStop("over_play")
		}
	}

	this["playAudio"+m].onRollOut = function(){
		if (g_audioPlaying == this._name){
			if (g_audioPaused){
				this.gotoAndStop("up_play")
			} else {
				this.gotoAndStop("up_pause")
			}
		} else {
			this.gotoAndStop("up_play")
		}
	}

	this["playAudio"+m].onRelease = function(){
		if (g_audioPlaying == this._name){
			if (g_audioPaused){
				//trace("over pause")
				this.gotoAndStop("over_pause");
				playQuestionAudio(this._name);
			} else {
				this.gotoAndStop("over_play")
				pauseQuestionAudio()
			}
		} else {
			this.gotoAndStop("over_pause")
			playQuestionAudio(this._name);
		}
		
	}

	this["playAudio"+m].onPress = function(){
		if (g_audioPlaying == this._name){
			if (g_audioPaused){
				this.gotoAndStop("down_play")
			} else {
				this.gotoAndStop("down_pause")
			}
		} else {
			this.gotoAndStop("down_play")
		}
	}
}