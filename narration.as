/*
Flash Companion, Copyright 2004, 2005, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications made to this page for version 1.3:
		- Moved glossary function from this file to player3.as in order to make it global (376)
		- Changed references to main timeline with Global variable.
		- Updated to work with multiple child tags.
	Modifications made to this page for version 2.0:
		- Added specialized code for the dragging and closing of narration for certain styles.
*/
//Set Color



//Specialized code for this style
import mx.transitions.Tween; 
import mx.transitions.easing.*;



var player:Object = this;
var player_x:Number = player._x;
var player_y:Number = player._y;



if (setNarrationColor) {//Set in narration.fla
	var satPct:Number = playerMain_mc.root_xmlnode.attributes.saturationPercent;

	var indexColor:String = playerMain_mc.root_xmlnode.attributes.indexColor;
	indxColor = new Color(narration_mc);
	indxColor.setTint(playerMain_mc.convertHexToR(indexColor),playerMain_mc.convertHexToG(indexColor),playerMain_mc.convertHexToB(indexColor), satPct);
	var indexHeadColor:String = playerMain_mc.root_xmlnode.attributes.indexHeader;
	ihColor = new Color(narrationHead_mc);
	ihColor.setTint(playerMain_mc.convertHexToR(indexHeadColor),playerMain_mc.convertHexToG(indexHeadColor),playerMain_mc.convertHexToB(indexHeadColor), satPct);
}

narration_txt.html = true;
updateNarration();

function updateNarration()
{
	var nar_text = "";
	// see if there is a narration node for this page
	var nar_text_node:XMLNode = matchSiblingNode(playerMain_mc.currentPage_xmlnode.firstChild,"narration");
	if (nar_text_node == null || nar_text_node === undefined)
	{
		nar_text = "<p>There is no narration text available for this page</p>";
	} else {
		nar_text = nar_text_node.firstChild.nodeValue;
	}
	
	//Load style sheet for narration text
	var styles = new TextField.StyleSheet();
	styles.load("narration.css");//Load the style sheet.
	styles.onLoad = function(ok) {
	  if (!ok) {//Did the style load OK? If it doesn't load, no data loads.
		//trace("Error loading CSS file.");
		narration_txt.html = true;
		// show the narration text
		narration_txt.text = nar_text;
		narration_txt.editable = false;
	  } else {
		narration_txt.styleSheet = styles;//Apply the style
		narration_txt.html = true;
		// show the narration text
		narration_txt.text = nar_text;
		narration_txt.editable = false;
	  }
	}
	
}


//Script close buttons
if (playerMain_mc.useAllMovieClips){
	close_btn.onRollOver = function() {
		this.gotoAndStop("over");
	}
	close_btn.onRollOut = function() {
		this.gotoAndStop("up");
	}
	close_btn.onRelease = function() {
		this.gotoAndStop("down");
		close_narration();
	}
	close_btn.onReleaseOutside = function() {
		this.gotoAndStop("up");
	}
} else {
	close_btn.onRelease = function () {
		close_narration();
	}
}

function close_narration() {
	
	
	
	var moveOut = new Tween(this,"_x",Strong.easeIn,this._x,1050,1,true);			
	moveOut.onMotionFinished = function()
	{
			
		player.unloadMovie();
		player._x = player_x;
		player._y = player_y;
		playerMain_mc.narrationLoaded = false;
	}



}