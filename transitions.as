/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock


*/
//Transition function for page
//Global variable for controlling Trasitions
var tranIntID:Number;			//Interval ID
var tranOrigX:Number = presentation._x;		//Original X position of presentation movie clip
var tranOrigY:Number = presentation._y;		//Original Y position of presentation movie clip
var tranOrigWidth:Number = playerMain_mc.tranMask_mc._width;	//Original Width
var tranOrigHeight:Number = playerMain_mc.tranMask_mc._height; //If statement determines original height

if (controllerTransition > 0){
	tranOrigHeight = tranOrigHeight - controllerTransition;
}
/*if (controller_mc){
	tranOrigHeight = controller_mc._y - presentation._y;
} else {
	tranOrigHeight = indexName_mc._height;
}*/
//variable used during transition
var xDistance:Number;
var yDistance:Number;
var tranTime:Number;
var timeMill:Number;
var wipeInc:Number;
var zoomInc:Number;
var wipeRandom:Boolean = false;
//Constants -- These are used to account for the inaccuracy of setInterval to get the right time. These can be adjusted to legnthen or shorten time.
var fadeIncrement:Number = 6.2;
var wipeIncrement:Number = 15;
var zoomIncrement:Number = 5.5;
var duration:Number = 50;
//var zoomXYChange:Number = 50;
//trace("startInc: " + wipeIncrement);
function enterPageTransition() {
	//Reset to original position
	presentation._xscale = 100;
	presentation._yscale = 100;
	presentation._x = tranOrigX;		
	presentation._y = tranOrigY;
	tranMask_mc._alpha = 0;
	clearInterval(tranIntID);
	//Determine Transition type.
	var tranType:String = root_xmlnode.attributes.transition.toLowerCase();
	if (tranType == "random"){
		var trans:Array = ["fade","wipe","zoom"];
		var tmpNum:Number = randRangeDec(0,2);
		tranType = trans[tmpNum];
		wipeRandom = true;
	}
	tranTime = root_xmlnode.attributes.transitionTime;
	//trace(tranTime);
	switch(tranType) {
		case("fade"):
		//Fade Settings
			playerMain_mc.tranMask_mc._visible = true;
			tranMask_mc._x = tranOrigX;
			tranMask_mc._y = tranOrigY;
			tranMask_mc._width = tranOrigWidth;
			tranMask_mc._height = tranOrigHeight;
			tranMask_mc._alpha = 100;
			//trace(presentation._alpha);
			//timeMill = getTimer();
			//trace("timeMill: " + timeMill);
			tranIntID = setInterval(tranFadeOut,duration);
			break;
		case("wipe"):
		//wipe settings
			wipeDir = root_xmlnode.attributes.tranDirection.toLowerCase();
			if (wipeRandom){
				var dirW:Array = ["left","right","top","bottom"];
				var tmpNum2:Number = randRangeDec(0,3);
				wipeDir = dirW[tmpNum2];
			}
			switch(wipeDir){//Which direction?
				case("left"):
					
					presentation._x = -tranOrigWidth;
					wipeInc = (tranOrigWidth + tranOrigX)/(wipeIncrement*tranTime);
					//trace("inc: " + wipeIncrement);
					//timeMill = getTimer();
					//trace("timeMillstart: " + timeMill);
					tranIntID = setInterval(tranWipe,duration,wipeDir);
					break;
				case("right"):
					presentation._x = presentation._x + tranOrigWidth;
					wipeInc = tranOrigWidth/(wipeIncrement*tranTime);
					//trace("inc: " + wipeIncrement);
					//timeMill = getTimer();
					//trace("timeMillstart: " + timeMill);
					tranIntID = setInterval(tranWipe,duration,wipeDir);
					break;
				case("top"):
					presentation._y = -tranOrigHeight;
					wipeInc = (tranOrigHeight + tranOrigY)/(wipeIncrement*tranTime);
					//trace("inc: " + wipeIncrement);
					//timeMill = getTimer();
					//trace("timeMillstart: " + timeMill);
					tranIntID = setInterval(tranWipe,duration,wipeDir);
					break;
				case("bottom"):
					presentation._y = playerMain_mc._height
					wipeInc = (tranOrigHeight + tranOrigY)/(wipeIncrement*tranTime);
					//trace("inc: " + wipeIncrement);
					//timeMill = getTimer();
					//trace("timeMillstart: " + timeMill);
					tranIntID = setInterval(tranWipe,duration,wipeDir);
					break;
			}
			//presentation._y = -1000;
			//trace(presentation._height + "  " + presentation._width);
			break;
		case("zoom"):
		//zoom setttings
			zoomInc = zoomIncrement/tranTime;
			xDistance = tranOrigWidth/2;
			yDistance = tranOrigHeight/2;
			presentation._x = xDistance + presentation._x;
			presentation._y = yDistance + presentation._y;
			presentation._xscale = 2;
			presentation._yscale = 2;
			xDistance = xDistance/(100/zoomInc);
			yDistance = yDistance/(100/zoomInc);
			
			//timeMill = getTimer();
					//trace("timeMillstart: " + timeMill);
			tranIntID = setInterval(tranZoom,duration);
			break;
	}
		/*trace("transition");
		
		// Construct a new TransitionManager object
		var newTransition:Tween = new Tween(presentation,"_alpha",null,0,100,10);*/

}

function tranFadeOut() {
	//trace(10/tranTime);
	tranMask_mc._alpha = tranMask_mc._alpha - (fadeIncrement/tranTime);

	//trace(presentation._alpha);
	if (tranMask_mc._alpha <= 0){
		tranMask_mc._alpha = 0;
		clearInterval(tranIntID);
		//timeMill = getTimer();
		//trace("timeMill: " + timeMill);
		playerMain_mc.tranMask_mc._visible = false;
	}
}

function tranWipe(wipeDir:String){
	switch(wipeDir){//Find out which direction
		case("left"):
			presentation._x = presentation._x + wipeInc;
			if (presentation._x >= tranOrigX){
				clearInterval(tranIntID);
				presentation._x = tranOrigX;
				//timeMill = getTimer();
				//trace("timeMill: " + timeMill);
			}
			break;
		case("right"):
			presentation._x = presentation._x - wipeInc;
			if (presentation._x <= tranOrigX){
				clearInterval(tranIntID);
				presentation._x = tranOrigX;
				//timeMill = getTimer();
				//trace("timeMill: " + timeMill);
			}
			break;
		case("top"):
			presentation._y = presentation._y + wipeInc;
			if (presentation._y >= tranOrigY){
				clearInterval(tranIntID);
				presentation._y = tranOrigY;
				//timeMill = getTimer();
				//trace("timeMill: " + timeMill);
			}
			break;
		case("bottom"):
			presentation._y = presentation._y - wipeInc;
			if (presentation._y <= tranOrigY){
				clearInterval(tranIntID);
				presentation._y = tranOrigY;
				//timeMill = getTimer();
				//trace("timeMill: " + timeMill);
			}
			break;

	}
}

function tranZoom(){
	//trace(tranOrigHeight + " : " + tranOrigWidth);
	presentation._x = presentation._x - xDistance
	presentation._y = presentation._y - yDistance
	presentation._xscale = presentation._xscale + zoomInc;
	presentation._yscale = presentation._yscale + zoomInc;
	if (presentation._xscale >= 100) {
		clearInterval(tranIntID);
		presentation._xscale = 100;
		presentation._yscale = 100;
		presentation._x = tranOrigX;
		presentation._y = tranOrigY;
		//timeMill = getTimer();
					//trace("timeMillstart: " + timeMill);
	}
	//Redraw the text area.
	if (presentation.page_txt){
		presentation.page_txt.invalidate();
	}
	updateAfterEvent();
}



//Random Method added the Math Class
//Courtesy of Joey Lott, ActionScript CookBook
function randRangeDec(minNum,maxNum,decPl){
	decPl = (decPl == undefined) ? 0 : decPl;
	var rangeDiff = (maxNum - minNum) * Math.pow(10,decPl)+1;
	var randVal = Math.random() * rangeDiff;
	randVal = Math.floor(randVal);
	randVal/=Math.pow(10,decPl);
	randVal += minNum;
	return roundTo(randVal, Math.pow(10, -decPl));
}

function roundTo(num, roundToInterval){
	if (roundToInterval == undefined){
		roundToInterval = 1;
	}
	return Math.round(num/roundToInterval)*roundToInterval;
}