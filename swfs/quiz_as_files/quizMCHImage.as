/*
Flash Companion, Copyright 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications made to this page for version 3:
		- New Question with this release.
*/

//==================================================================================//
//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//

import com.greensock.*;
import com.greensock.easing.*;

//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
//==================================================================================//


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
	
	//==================================================================================//
	//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//	
	
	mcLoader.loadClip(imageFile, loadImage_mc.holder_mc);
		
	//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
	//==================================================================================//


	mcLoadListen.onLoadInit = function(mc:MovieClip) {
		
		//==================================================================================//
		//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//		
		
		mc.forceSmoothing = true;	
	
		var wr = mc._width/mc._parent.dummy_mc._width;
		var hr = mc._height/mc._parent.dummy_mc._height;
		
		if(wr>hr)
		{
			//limit W			
			mc._width = mc._parent.dummy_mc._width;
			mc._yscale = mc._xscale;		
			
			//center in Y
			var posY = mc._parent.dummy_mc._height-mc._height			
			mc._y = posY/2;
		}
		else
		{
			//limit H			
			mc._height = mc._parent.dummy_mc._height;
			mc._xscale = mc._yscale;
			
			//center in X			
			var posX = mc._parent.dummy_mc._width-mc._width			
			mc._x = posX/2;
		}
		
		mc._parent.zoom_btn._x = mc._x+mc._width;
		mc._parent.zoom_btn._y = mc._y+mc._height;	
		mc._parent.zoom_btn.onRelease = zoomIn;
		mc._parent.zoom_btn._visible = true;

		mc.onRelease = zoomOut;
		mc.enabled = false;

		loadImage_mc.W = loadImage_mc._width;
		loadImage_mc.H = loadImage_mc._height;
		loadImage_mc.X = loadImage_mc._x;
		loadImage_mc.Y = loadImage_mc._y;		
		
		//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
		//==================================================================================//
		
		
		//trace("scaleSize Width: " + scaleSize);
		Template_Question._x = mc._parent._x + mc._parent._width + 10;
		Template_Question._width = playerMain_mc.presentSizeW - mc._parent._x - mc._parent._width - 15;				
	}
}



//==================================================================================//
//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//

// ZoomIn the loadImage container, based on the playerMain_mc size.
function zoomIn()
{	
	loadImage_mc.zoom_btn._visible = false;
	loadImage_mc.holder_mc.enabled = true;
	
	locked_mc._alpha = 0;	
	locked_mc._visible = true
	locked_mc.resize(playerMain_mc);
	TweenLite.to(locked_mc, 0.6, {_alpha:100});
	var wr = playerMain_mc.presentSizeW/loadImage_mc._width;
	var hr = playerMain_mc.presentSizeH/loadImage_mc._height;
		
	var newW, newH, newX, newY, newScale;	
		
	if(wr<hr)
		{
			//limit W												
			loadImage_mc._width = playerMain_mc.presentSizeW;
			loadImage_mc._yscale = loadImage_mc._xscale;			
			newW = playerMain_mc.presentSizeW;
			newH = loadImage_mc._height;			
			var posY = playerMain_mc.presentSizeH-loadImage_mc._height			
			
			loadImage_mc._width = loadImage_mc.W;
			loadImage_mc._height = loadImage_mc.H;
					
			//center in Y			
			newX = 0;
			newY = posY/2;			
			
			TweenLite.to(loadImage_mc,0.6,{_x:newX, _y:newY, _width:newW, _height:newH});
		}
		else
		{
			//limit H			
			loadImage_mc._height = playerMain_mc.presentSizeH;
			loadImage_mc._xscale = loadImage_mc._yscale;			
			newH = playerMain_mc.presentSizeH;
			newW = loadImage_mc._width;
			var posX = playerMain_mc.presentSizeW-loadImage_mc._width;			
			
			loadImage_mc._width = loadImage_mc.W;
			loadImage_mc._height = loadImage_mc.H;
			
			//center in X			
			newY = 0;
			newX = posX/2;
			
			TweenLite.to(loadImage_mc,0.6,{_x:newX, _y:newY, _width:newW, _height:newH});
		}
}

// ZoomOut the loadImage container, to the original values.
function zoomOut()
{
	loadImage_mc.holder_mc.enabled = false;		
	TweenLite.to(loadImage_mc, 0.6, {_x:loadImage_mc.X, _y: loadImage_mc.Y, _width:loadImage_mc.W, _height:loadImage_mc.H});	
	TweenLite.to(locked_mc, 0.6, {_alpha:0, onComplete:hideLock});	
}

function hideLock()
{	
	loadImage_mc.zoom_btn._visible = true;
	locked_mc.hide();
}

//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
//==================================================================================//
