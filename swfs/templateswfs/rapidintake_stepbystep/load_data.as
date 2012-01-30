//Load data into step-by-step template 

//Import Tween and Easing classes
import mx.transitions.Tween; 
import mx.transitions.easing.*;
var stepbystep_mc:MovieClip = this;
//Variables
var nLayer:Number = 5000;
if (contentH < 450)
{
	var spacingBetweenSteps:Number = 6;
	var scaleSize:Number = 200;
	var xScaleValue:Number = 2;
} else {
	var spacingBetweenSteps:Number = 10;
	var scaleSize:Number = 150;
	var xScaleValue:Number = 4;
}

var stepsNum:Number = 0;
var stepCounter:Array = new Array();
//Variable to keep track of original position and size of text area and loader component
var iOrigX:Number = enlarge_mc.x;
var iOrigY:Number = enlarge_mc.y;
var iOrigW:Number = enlarge_mc.width;
var iOrigH:Number = enlarge_mc.height;
var tOrigX:Number = stepDescription_ta.x;
var tOrigY:Number = stepDescription_ta.y;
var tOrigH:Number = stepDescription_ta.height;
var tOrigW:Number = stepDescription_ta.width;
var swfOrigX:Number = swfControl_mc._x;
var swfOrigY:Number = swfControl_mc._y;
var overFlowSpace:Number = 0;
var overFlowOrig:Number = stepsHolder_mc._y;
var imageBig:Boolean = false;
var s_currentStep:Number = 0;
stepsHolder_mc.moreUp_mc.onRelease = moveStepsDown;
stepsHolder_mc.moreDown_mc.onRelease = moveStepsUp;

//Load Data
stepDescription_ta.setStyle("borderStyle","none");
stepDescription_ta.label.selectable=false;
_global.styles.TextArea.setStyle("backgroundColor" , "transparent");

var taskTitle:String = playerMain_mc.currentPage_xmlnode.attributes.taskTitle;
//trace(taskTitle);
taskTitle_txt.html = true;
taskTitle_txt.htmlText = taskTitle;
stepsHolder_mc.moreUp_mc._visible = false;
stepsHolder_mc.moreDown_mc._visible = false;
var stepCSS = new TextField.StyleSheet();
stepCSS.load("swfs/templateswfs/template_styles.css");//Load the style sheet.
stepCSS.onLoad = function(ok) {
	if (!ok) {//Did the style load OK? If it doesn't load, no data loads.
		trace("Error loading CSS file.");
	}
}

setUpNavButtons();
loadSteps();
selectStep(1);
s_mask_mc._visible = false;

//Load the steps
function loadSteps()
{
	var steps_xmlnode:XMLNode = matchSiblingNode(playerMain_mc.currentPage_xmlnode.firstChild, "steps");
	var steps_array:Array = steps_xmlnode.childNodes;
	stepsNum = steps_array.length;
	
	//Starting position of steps. To change the starting position just move the steps_mc movie clip in the FLA.
	var startX:Number = steps_mc._x;
	var startY:Number = steps_mc._y;
	
	
	if (stepsNum !== undefined)
	{
		
		for (var i:Number = 1;i<=stepsNum;i++)
		{
			// create a name for this step
			var name_str = "step_mc" + i;
			// create a new step item
			stepsHolder_mc.steps_mc.duplicateMovieClip(name_str, nLayer);
			nLayer++;
			var step_mc:MovieClip = stepsHolder_mc[name_str];
			var curStep_xmlnode:XMLNode = steps_array[i-1];
			step_mc.step_text_txt.text = curStep_xmlnode.attributes.stepText;
			//Resize Text field to a max of five lines
			if (step_mc.step_text_txt.maxscroll > 1)
			{
				//trace("step " + i + " - " + step_mc.step_text_txt.maxscroll)
				step_mc.step_text_txt._height = step_mc.step_text_txt.textHeight + 6;
				step_mc.cover_mc._height = step_mc.step_text_txt._height;
			}
			step_mc.stepNode = curStep_xmlnode;
			step_mc.num_mc.step_num_txt.text = i;
			step_mc.stepNum = i;
			//Position step
			step_mc._x = startX;
			if (i == 1)
			{
				step_mc._y = startY;
			} else {
				var preStep_mc:MovieClip = stepsHolder_mc["step_mc" + (i-1)];
				step_mc._y = Math.floor(preStep_mc._y + preStep_mc._height + spacingBetweenSteps);
				//trace(i + ":  " + step_mc._y)
				//trace((step_mc._y + step_mc._height + stepsHolder_mc.moreDown_mc._height) + " - " + steps_back_mc._height)
				if ((step_mc._y + step_mc._height + stepsHolder_mc.moreDown_mc._height + 10) > steps_back_mc._height)
				{
					//trace((step_mc._y + step_mc._height + stepsHolder_mc.moreDown_mc._height) + " - " + steps_back_mc._height)
					if (stepsHolder_mc.moreDown_mc._visible == false)
					{
						stepsHolder_mc.moreDown_mc._y = Math.floor(preStep_mc._y + preStep_mc._height + 2);
						stepsHolder_mc.moreDown_mc._visible = true;
						
						//trace(stepsHolder_mc.moreDown_mc._x + " - " + stepsHolder_mc.moreDown_mc._y)
					}
					step_mc._visible = false;
					overFlowSpace += step_mc._height + spacingBetweenSteps;
				}
			}
			
			//set to inactive
			step_mc.num_mc.gotoAndStop("inactive");
			
			//Add handlers
			step_mc.origWidth = step_mc.num_mc._width;
			step_mc.origHeight = step_mc.num_mc._height;
			step_mc.origX = step_mc.num_mc._x;
			step_mc.origY = step_mc.num_mc._y;
			step_mc.onRollOver = function()
			{
				//this.num_mc.gotoAndStop("active");
				var moveBack = new Tween(this.num_mc,"_width",Strong.easeOut,this.num_mc._width,(this.num_mc._width + 4),0.5,true);
				var moveBack = new Tween(this.num_mc,"_height",Strong.easeOut,this.num_mc._height,(this.num_mc._height + 4),0.5,true);
				var xBack = new Tween(this.num_mc,"_x",Strong.easeOut,this.num_mc._x,(this.num_mc._x - 2),0.5,true);
				var yBack = new Tween(this.num_mc,"_y",Strong.easeOut,this.num_mc._y,(this.num_mc._y - 2),0.5,true);
			}

			step_mc.onRollOut = function()
			{
				var moveBack = new Tween(this.num_mc,"_width",Strong.easeOut,this.num_mc._width,this.origWidth,1,true);
				var moveBack = new Tween(this.num_mc,"_height",Strong.easeOut,this.num_mc._height,this.origHeight,1,true);
				var xBack = new Tween(this.num_mc,"_x",Strong.easeOut,this.num_mc._x,(this.origX),1,true);
				var yBack = new Tween(this.num_mc,"_y",Strong.easeOut,this.num_mc._y,(this.origY),1,true);
				/*yBack.onMotionFinished = function()
				{
					trace(step_mc)
					step_mc.num_mc.gotoAndStop("inactive");
				}*/
			}
			step_mc.onRelease = function()
			{
				this.num_mc.gotoAndStop("active");
				selectStep(this.stepNum);
			}
			//Set up step counter array for pageComplete functionallity.
			stepCounter[i-1] = false;
		}
	}
	stepsHolder_mc.steps_mc._visible = false;
}

//Select the step
function selectStep(stepNum)
{
	//reset image
	resetEnlarge();
	s_currentStep = stepNum;
	//Page complete functionallity
	stepCounter[stepNum -1] = true;
	var usePageComplete:Boolean = playerMain_mc.root_xmlnode.attributes.pageComplete.toLowerCase() == "true";
	if (usePageComplete)
	{
		var stepsFinished:Number = 0;
		for (var i:Number = 0;i < stepsNum;i++)
		{
			if (stepCounter[i] == true)
			{
				stepsFinished++;
			}
		}
		if (stepsFinished == stepsNum)
		{
			playerMain_mc.apiPageComplete();
		}
	}
	//magnifyIcon_mc._visible = false;
	//trace("stepNum: " + stepNum)
	var step_mc:MovieClip = stepsHolder_mc["step_mc" + stepNum];
	var curStep_xmlnode:XMLNode = step_mc.stepNode;
	var imagePath = curStep_xmlnode.attributes.imageFile;
	var stepDescript = curStep_xmlnode.firstChild.nodeValue;
	
	var loadListen:Object = new Object();
	loadListen.complete = function(eventObject)
	{
		//trace("w h x y: " +enlarge_mc.content._width+","+enlarge_mc.content._height+","+enlarge_mc.content._x+","+enlarge_mc.content._y);
		magnifyIcon_mc._x = enlarge_mc.content._x + enlarge_mc.content._width - 20 + enlarge_mc.x;
		magnifyIcon_mc._y = enlarge_mc.content._y + enlarge_mc.content._height - 20 + enlarge_mc.y;
		magnifyIcon_mc._visible = true;
	}
	enlarge_mc.addEventListener("complete", loadListen)


	
	if (imagePath && stepDescript)
	{
		//Since both have contet, set back to original size then populate.
		enlarge_mc.move(iOrigX,iOrigY);
		enlarge_mc.setSize(iOrigW,iOrigH);
		/*enlarge_mc._width = iOrigW;
		enlarge_mc._height = iOrigH;
		enlarge_mc._x = iOrigX;
		enlarge_mc._y = iOrigY;*/
		enlarge_mc.contentPath = imagePath;
		stepDescription_ta.move(tOrigX,tOrigY);
		stepDescription_ta.setSize(tOrigW,tOrigH);
		stepDescription_ta.styleSheet = stepCSS;
		stepDescription_ta.html = true;
		stepDescription_ta.text = "<p class='pageText'>" + stepDescript + "</p>";
	} 
	else if (imagePath)
	{
		enlarge_mc.move(170,70);
		enlarge_mc.setSize(contentW-180,contentH-75);
		/*enlarge_mc._width = contentW-180;
		enlarge_mc._height = contentH-75;
		enlarge_mc._x = 170;
		enlarge_mc._y = 70;*/
		
		enlarge_mc.contentPath = imagePath;
		stepDescription_ta.text = "";
	}
	else if (stepDescript)
	{
		enlarge_mc.contentPath = "";
		stepDescription_ta.move(170,70);
		stepDescription_ta.setSize(contentW-180,contentH-75);
		stepDescription_ta.styleSheet = stepCSS;
		stepDescription_ta.html = true;
		stepDescription_ta.text = "<p class='pageText'>" + stepDescript + "</p>";
	}
/*trace("---------------------------------------");
trace("Original: " + iOrigX + " _ " + iOrigY + " _ " + iOrigW + " _ " + iOrigH)
trace("Normal: " + enlarge_mc._x + " _ " + enlarge_mc._y + " _ " + enlarge_mc._width + " _ " + enlarge_mc._height)
trace("Component: " + enlarge_mc.x + " _ " + enlarge_mc.y + " _ " + enlarge_mc.width + " _ " + enlarge_mc.height)*/
	
	if (imagePath)
	{
		magnifyIcon_mc._visible = true;
		//stepbystep_mc.attachMovie("enlargeIcon", "magnifyIcon_mc", this.getNextHighestDepth(), {_x:(enlarge_mc.x + enlarge_mc.width - 20), _y:(enlarge_mc.y + enlarge_mc.height - 46)});
		//enlarge_mc.setMask(magnifyIcon_mc);
	} else {
		magnifyIcon_mc._visible = false;
	}
	
	if (imagePath.indexOf(".swf") > -1)
	{
		/*trace("newSize w h x y: " + enlarge_mc._width + ", " + enlarge_mc._height + ", " + enlarge_mc._x + ", " + enlarge_mc._y + " --Original Size w h x y: " + enlarge_mc.origWidth + ", " + enlarge_mc.origHeight + ", " + enlarge_mc.origX + ", " + enlarge_mc.origY);
			trace(enlarge_mc.width + " - " + enlarge_mc.height + " - " + enlarge_mc.x + " - " + enlarge_mc.y);*/
		swfControl_mc._visible = true;
		swfControl_mc._y = enlarge_mc.height + enlarge_mc.y + 3;
		swfControl_mc._x = Math.floor((enlarge_mc.width - swfControl_mc._width)/2) + enlarge_mc.x;
		swfOrigX = swfControl_mc._x;
		swfOrigY = swfControl_mc._y;
		setController();
	} else {
		swfControl_mc._visible = false;
		stopController();
	}
	stepTitle_txt.text = curStep_xmlnode.attributes.stepText;
	var textWidth:Number = stepTitle_txt.textWidth + 5;
	var textLegnth:Number = stepTitle_txt.length;
	if (textWidth > stepTitle_txt._width)
	{
		var sizeDiff:Number = textWidth - stepTitle_txt._width;
		var charSize:Number = textWidth/textLegnth;
		var charChange:Number = Math.ceil(sizeDiff/charSize) + 3;
		stepTitle_txt.replaceText(textLegnth - charChange,textLegnth,"...");
	}
	step_highlight_mc._y = step_mc._y + stepsHolder_mc._y;
	step_highlight_mc._height = step_mc._height;
	step_highlight_mc._visible = true;
	step_mc.num_mc.gotoAndStop("active")
	numberSteps(stepNum);
	//Make it possible to enlarge image
	setUpEnlarge();
}

function numberSteps(stepNum)
{
	stepNav_mc.step_cnt_txt.html = true;
	stepNav_mc.step_cnt_txt.htmlText = "<b>" + stepNum + "</b> of <b>" + stepsNum + "</b>";
}


	
function setUpEnlarge()
{
	enlarge_mc.onRelease = function()
	{
		this.origWidth = this._width;
		this.origHeight = this._height;
		this.origX = this._x;
		this.origY = this._y;
		//var moveBack = new Tween(this,"_width",Back.easeOut,this._width,(this._width + 150),1,true);
		//var moveBack2 = new Tween(this,"_height",Back.easeOut,this._height,(this._height + 150),1,true);
		
		var moveBack = new Tween(this,"_xscale",Back.easeOut,this._xscale,scaleSize,1,true);
		var moveBack2 = new Tween(this,"_yscale",Back.easeOut,this._yscale,scaleSize,1,true);
		
		var xBack = new Tween(this,"_x",Back.easeOut,this._x,(this._x - Math.floor(iOrigW/xScaleValue)),1,true);
		var yBack = new Tween(this,"_y",Back.easeOut,this._y,(this._y - Math.floor(iOrigH/xScaleValue)),1,true);
		
		/*yBack.onMotionFinished = function(){
			trace("newSize w h x y: " + enlarge_mc._width + ", " + enlarge_mc._height + ", " + enlarge_mc._x + ", " + enlarge_mc._y + " --Original Size w h x y: " + enlarge_mc.origWidth + ", " + enlarge_mc.origHeight + ", " + enlarge_mc.origX + ", " + enlarge_mc.origY);
			trace(enlarge_mc.width + " - " + enlarge_mc.height + " - " + enlarge_mc.x + " - " + enlarge_mc.y);
		}*/
		/*xBack.onMotionChanged = function()
		{
			//trace(enlarge_mc.x)
			//trace(enlarge_mc.content._x);
			//trace(enlarge_mc.content._width);
			//trace(enlarge_mc.content._height);
			//swfControl_mc._x = Math.floor((enlarge_mc.width - swfControl_mc._width)/2) + enlarge_mc.x;
		}*/
		//Enlarge the controller for SWF Files
		if (swfControl_mc._visible == true)
		{
			//var moveCtrlX = new Tween(swfControl_mc,"_x",Back.easeOut,swfControl_mc._x,(swfControl_mc._x - 38),1,true);
			var moveCtrlY = new Tween(swfControl_mc,"_y",Back.easeOut,swfControl_mc._y,(swfControl_mc._y + Math.floor(iOrigH/xScaleValue)),1,true);
		}
		//Set variable
		imageBig = true;
		//set cursor back to default
		magnify_mc._visible = false;
		microfy_mc._visible = true;
		microfy_mc.startDrag(true);
		this.useHandCursor = false;
		//Mouse.show();
		magnifyIcon_mc._visible = false;
		enlarge_mc.onRelease = function()
		{
			//var moveBack = new Tween(this,"_width",Strong.easeOut,this._width,this.origWidth,2,true);
			//var moveBack2 = new Tween(this,"_height",Strong.easeOut,this._height,this.origHeight,2,true);
			
			var moveBack = new Tween(this,"_xscale",Strong.easeOut,this._xscale,100,2,true);
			var moveBack2 = new Tween(this,"_yscale",Strong.easeOut,this._yscale,100,2,true);
			
			var xBack = new Tween(this,"_x",Strong.easeOut,this._x,this.origX,2,true);
			var yBack = new Tween(this,"_y",Strong.easeOut,this._y,this.origY,2,true);
			if (swfControl_mc._visible == true)
			{
				//var moveCtrlX = new Tween(swfControl_mc,"_x",Strong.easeOut,swfControl_mc._x,swfOrigX,2,true);
				var moveCtrlY = new Tween(swfControl_mc,"_y",Strong.easeOut,swfControl_mc._y,swfOrigY,2,true);
			}
			stepbystep_mc.magnifyIcon_mc._visible = true;
			//Set variable
			imageBig = false;
			/*enlarge_mc.onRollOut = function()
			{
				magnify_mc._visible = false;
				Mouse.show();
			}*/
			microfy_mc._visible = false;
			magnify_mc._visible = true;
			magnify_mc.startDrag(true);
			//Mouse.show();
			setUpEnlarge()
	
		}
		enlarge_mc.onRollOver = function()
		{
			microfy_mc._visible = true;
			microfy_mc.startDrag(true);
			//magnify_mc.swapDepths(magnifyIcon_mc);
			Mouse.hide();
		}
		
		enlarge_mc.onRollOut = function()
		{
			microfy_mc._visible = false;
			//magnify_mc.swapDepths(magnifyIcon_mc);
			Mouse.show();
		}
		/*enlarge_mc.onRelease = function()
		{
		}*/
	}
	
	enlarge_mc.onRollOver = function()
	{
		magnify_mc._visible = true;
		magnify_mc.startDrag(true);
		//magnify_mc.swapDepths(magnifyIcon_mc);
		Mouse.hide();
	}
	
	enlarge_mc.onRollOut = function()
	{
		magnify_mc._visible = false;
		//magnify_mc.swapDepths(magnifyIcon_mc);
		Mouse.show();
	}
}

function resetEnlarge()
{
	//trace(imageBig);
	if (imageBig)
	{
		
		
		//trace(enlarge_mc.origWidth + " - " + enlarge_mc.origX);
		enlarge_mc._xscale = 100;
		enlarge_mc._yscale = 100;
		enlarge_mc._y = enlarge_mc.origY;
		enlarge_mc._x = enlarge_mc.origX;
		
		enlarge_mc.setSize(enlarge_mc.origWidth,enlarge_mc.origHeight);
		enlarge_mc.move(enlarge_mc.origX,enlarge_mc.origY);
		
		if (swfControl_mc._visible == true)
		{
			swfControl_mc._y = swfOrigY;
			swfControl_mc._visible = false;
		}
		stepbystep_mc.magnifyIcon_mc._visible = true;
		imageBig = false;
	}
}


function moveStepsUp(selectAStep:Boolean)
{
	var moveUp = new Tween(stepsHolder_mc,"_y",Strong.easeOut,stepsHolder_mc._y,stepsHolder_mc._y - overFlowSpace,2,true);
	step_highlight_mc._visible = false;
	moveUp.onMotionChanged = function()
	{
		//trace(stepsHolder_mc.step_mc1._y);
		for (var i:Number = 1;i<=stepsNum;i++)
		{
			// create a name for this step
			var name_str = "step_mc" + i;
			// create a new step item
			var step_mc:MovieClip = stepsHolder_mc[name_str];
			//trace(stepsHolder_mc.step_mc1._y + stepsHolder_mc._y);
			if ((step_mc._y + stepsHolder_mc._y) < 0)//step_mc._height) < ((overFlowSpace + stepsHolder_mc.moreUp_mc._height) - (overFlowSpace - (overFlowOrig - stepsHolder_mc._y))))
			{
				step_mc._visible = false;
				//trace(stepsHolder_mc.moreUp_mc._y)
			} else if ((step_mc._y + stepsHolder_mc._y + step_mc._height) < playerMain_mc.presentSizeH){
				step_mc._visible = true;
			}
		}
	}
	moveUp.onMotionFinished = function()
	{
		for (var i:Number = 1;i<=stepsNum;i++)
		{
			// create a name for this step
			var name_str = "step_mc" + i;
			var name_str_bf = "step_mc" + (i+1);
			// create a new step item
			var step_mc:MovieClip = stepsHolder_mc[name_str];
			if ((step_mc._y + stepsHolder_mc._y) < 0)//((step_mc._y + step_mc._height) < overFlowSpace + stepsHolder_mc.moreUp_mc._height)
			{
				step_mc._visible = false;
				stepsHolder_mc.moreUp_mc._y = stepsHolder_mc[name_str_bf]._y - stepsHolder_mc.moreUp_mc._height + 4;
				if (playerMain_mc.presentSizeH<400)
				{
					stepsHolder_mc.moreUp_mc._y += 5;
				}
				//trace(stepsHolder_mc.moreUp_mc._y)
			}
			/*if ((step_mc._y + step_mc._height) < overFlowSpace + stepsHolder_mc.moreUp_mc._height)
			{
				step_mc._visible = false;
				stepsHolder_mc.moreUp_mc._y = stepsHolder_mc[name_str_bf]._y - stepsHolder_mc.moreUp_mc._height + 4;
				//trace(stepsHolder_mc.moreUp_mc._y)
			}  else {
				step_mc._visible = true;
			}*/
		}
		stepsHolder_mc.moreUp_mc._alpha = 0;
		stepsHolder_mc.moreUp_mc._visible = true;
		var showButton = new Tween(stepsHolder_mc.moreUp_mc,"_alpha",Strong.easeOut,stepsHolder_mc.moreUp_mc._alpha,100,0.5,true);
		if (selectAStep)
		{
			selectStep(s_currentStep + 1);
		}
	}
	stepsHolder_mc.moreDown_mc._visible = false;
	
}

function moveStepsDown(selectAStep:Boolean)
{
	var moveDown = new Tween(stepsHolder_mc,"_y",Strong.easeOut,stepsHolder_mc._y,overFlowOrig,2,true);
	step_highlight_mc._visible = false;
	moveDown.onMotionChanged = function()
	{
		for (var i:Number = 1;i<=stepsNum;i++)
		{
			// create a name for this step
			var name_str = "step_mc" + i;
			// create a new step item
			var step_mc:MovieClip = stepsHolder_mc[name_str];
			if ((step_mc._y + step_mc._height + stepsHolder_mc.moreDown_mc._height + 10) > (steps_back_mc._height + (overFlowOrig - stepsHolder_mc._y)))
			{
				step_mc._visible = false;
			} else if (step_mc._y + stepsHolder_mc._y > 0) {
				step_mc._visible = true;
			}
		}
	}
	moveDown.onMotionFinished = function()
	{
		for (var i:Number = 1;i<=stepsNum;i++)
		{
			// create a name for this step
			var name_str = "step_mc" + i;
			// create a new step item
			var step_mc:MovieClip = stepsHolder_mc[name_str];
			if ((step_mc._y + step_mc._height + stepsHolder_mc.moreDown_mc._height + 10) > steps_back_mc._height)
			{
				step_mc._visible = false;
			} else {
				step_mc._visible = true;
			}
		}
		stepsHolder_mc.moreDown_mc._alpha = 0;
		stepsHolder_mc.moreDown_mc._visible = true;
		var showButton = new Tween(stepsHolder_mc.moreDown_mc,"_alpha",Strong.easeOut,stepsHolder_mc.moreDown_mc._alpha,100,0.5,true);
		if (selectAStep)
		{
			selectStep(s_currentStep - 1);
		}
	}
	
	stepsHolder_mc.moreUp_mc._visible = false;
}

/*this.onEnterFrame = function(){
	
trace(enlarge_mc.content._currentframe)
}*/

function setController()
{
	swfControl_mc.playStatus = "play";
	var fileToControl = enlarge_mc.content;
	fileToControl.play();
	swfControl_mc.rewind_btn.onRelease = function()
	{
		fileToControl.gotoAndPlay(1);
		//swfControl_mc.play_mc.gotoAndStop("pause")
		swfControl_mc.playStatus = "play";
	}
	
	//trace(swfControl_mc.play_mc.pause_btn)
	swfControl_mc.play_mc.pause_btn.onRelease = function()
	{
		//trace(_parent)
		fileToControl.stop();
		//swfControl_mc.play_mc.gotoAndStop("play")
		swfControl_mc.playStatus = "stopped";
	}
	swfControl_mc.play_mc.play_btn.onRelease = function()
	{
		fileToControl.play();
		//swfControl_mc.play_mc.gotoAndStop("pause")
		swfControl_mc.playStatus = "play";
	}
	swfControl_mc.onEnterFrame = function()
	{
		var totalFrames:Number = fileToControl._totalframes;
		var currentFrame:Number = fileToControl._currentframe;
		
		if (currentFrame > 0 && totalFrames > 0 && currentFrame < totalFrames)
		{
			//trace(swfControl_mc.track_mc._width*(currentFrame/totalFrames) + swfControl_mc.track_mc._x)
			swfControl_mc.scrubber_mc._x = ((swfControl_mc.track_mc._width*(currentFrame/totalFrames)) + swfControl_mc.track_mc._x)-5;
			//swfControl_mc.playStatus = "play";
		} else {
			//swfControl_mc.scrubber_mc._x = swfControl_mc.track_mc._x;
			swfControl_mc.playStatus = "stopped";
		}
		if (swfControl_mc.playStatus == "play")
		{
			swfControl_mc.play_mc.gotoAndStop("pause");
		} else {
			swfControl_mc.play_mc.gotoAndStop("play");
		}
	}
}

function stopController()
{
	delete swfControl_mc.onEnterFrame;
}


function setUpNavButtons()
{
	
	stepNav_mc.nextStep_mc.origWidth = stepNav_mc.nextStep_mc._width;
	stepNav_mc.nextStep_mc.origHeight = stepNav_mc.nextStep_mc._height;
	stepNav_mc.nextStep_mc.origX = stepNav_mc.nextStep_mc._x;
	stepNav_mc.nextStep_mc.origY = stepNav_mc.nextStep_mc._y;
	stepNav_mc.nextStep_mc.onRollOver = function()
	{
		if (s_currentStep < stepsNum)
		{
		//this.num_mc.gotoAndStop("active");
			var moveBack1w = new Tween(this,"_width",Strong.easeOut,this._width,(this._width + 2),0.25,true);
			var moveBack1h = new Tween(this,"_height",Strong.easeOut,this._height,(this._height + 2),0.25,true);
			var xBack1x = new Tween(this,"_x",Strong.easeOut,this._x,(this._x - 1),0.25,true);
			var yBack1y = new Tween(this,"_y",Strong.easeOut,this._y,(this._y - 1),0.25,true);
		}
	}

	stepNav_mc.nextStep_mc.onRollOut = function()
	{
		var moveBack2w = new Tween(this,"_width",Strong.easeOut,this._width,this.origWidth,0.5,true);
		var moveBack2h = new Tween(this,"_height",Strong.easeOut,this._height,this.origHeight,0.5,true);
		var xBack2x = new Tween(this,"_x",Strong.easeOut,this._x,(this.origX),0.5,true);
		var yBack2y = new Tween(this,"_y",Strong.easeOut,this._y,(this.origY),0.5,true);
	}
	stepNav_mc.nextStep_mc.onRelease = function()
	{
		
		if (s_currentStep < stepsNum)
		{
			var next_step_mc:MovieClip = stepsHolder_mc["step_mc" + (s_currentStep + 1)];
			var cur_step_mc:MovieClip = stepsHolder_mc["step_mc" + (s_currentStep)];
			
			
			
			if (next_step_mc._visible)
			{
				selectStep(s_currentStep + 1);
			} else {
				if (cur_step_mc._visible)
				{
					moveStepsUp(true);
				} else {
					s_currentStep = s_currentStep + 2;
					moveStepsDown(true);
				}
			}
				/*var below:Boolean = true;
				for (var m:Number = s_currentStep;m<=stepsNum;m++)
				{
					// create a name for this step
					var name_str = "step_mc" + m;
					// create a new step item
					var step_mc:MovieClip = stepsHolder_mc[name_str];
					//trace(stepsHolder_mc.step_mc1._y + stepsHolder_mc._y);
					if (step_mc._visible) below = false;
				}
				var name_str = "step_mc" + (s_currentStep++)
				var step_mc:MovieClip = stepsHolder_mc[name_str];
				//if (!step_mc._visible)
				if (below)
				{
					moveStepsUp(true);
				} else {
					s_currentStep = s_currentStep + 2;
					moveStepsDown(true);
				}
			}*/
		}
	}
	
	stepNav_mc.prevStep_mc.origWidth = stepNav_mc.prevStep_mc._width;
	stepNav_mc.prevStep_mc.origHeight = stepNav_mc.prevStep_mc._height;
	stepNav_mc.prevStep_mc.origX = stepNav_mc.prevStep_mc._x;
	stepNav_mc.prevStep_mc.origY = stepNav_mc.prevStep_mc._y;
	stepNav_mc.prevStep_mc.onRollOver = function()
	{
		if (s_currentStep > 1)
		{
			//this.num_mc.gotoAndStop("active");
			var moveBack3w = new Tween(this,"_width",Strong.easeOut,this._width,(this._width + 2),0.25,true);
			var moveBack3h = new Tween(this,"_height",Strong.easeOut,this._height,(this._height + 2),0.25,true);
			var xBack3x = new Tween(this,"_x",Strong.easeOut,this._x,(this._x - 1),0.25,true);
			var yBack3y = new Tween(this,"_y",Strong.easeOut,this._y,(this._y - 1),0.25,true);
		}
	}

	stepNav_mc.prevStep_mc.onRollOut = function()
	{
		var moveBack4w = new Tween(this,"_width",Strong.easeOut,this._width,this.origWidth,0.5,true);
		var moveBack4h = new Tween(this,"_height",Strong.easeOut,this._height,this.origHeight,0.5,true);
		var xBack4x = new Tween(this,"_x",Strong.easeOut,this._x,(this.origX),0.5,true);
		var yBack4y = new Tween(this,"_y",Strong.easeOut,this._y,(this.origY),0.5,true);
	}
	stepNav_mc.prevStep_mc.onRelease = function()
	{
		if (s_currentStep > 1)
		{
			var next_step_mc:MovieClip = stepsHolder_mc["step_mc" + (s_currentStep - 1)];
			var cur_step_mc:MovieClip = stepsHolder_mc["step_mc" + (s_currentStep)];
			if (next_step_mc._visible)
			{
				selectStep(s_currentStep - 1);
			} else {
				if (cur_step_mc._visible)
				{
					moveStepsDown(true);
				} else {
					s_currentStep = s_currentStep - 2;
					moveStepsUp(true);
				}
			}
		}
	}
}