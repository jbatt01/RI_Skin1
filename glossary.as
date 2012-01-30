/*
Flash Companion, Copyright 2004, 2005, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications made to glossary for version 1.3:
		- Background image was changed to a movie clip symbol
		- Code added to prevent buttons below glossary from being functional.
		- Added error checking for the parsing of the XML file in the loadGlossary function.
		- Changed references to main timeline with Global variable.
*/


//Specialized code for this style
import mx.transitions.Tween; 
import mx.transitions.easing.*;


/*Customized code for this player*/

	import Scrollbar;
	var letters:Object = new Object();
	var selectedLetter;	
	var sBar:Scrollbar;
	
/*   ---------------------------	*/
	

var player:Object = this;
var player_x:Number = player._x;
var player_y:Number = player._y;

//Load glossary.xml file
var glossary_xml:XML = new XML(); //creates the XML object in Flash
var cacheString2:String = getSkipCacheString();
if (cacheString2 === undefined)
	cacheString2 = "";
glossary_xml.load("glossary.xml" + cacheString2);     //load the glossarys's XML data into the XML object
//trace("glossary.xml" + getSkipCacheString());
glossary_xml.onLoad = loadGlossary;   //tells Flash which function to execute after loading
glossary_xml.ignoreWhite = true;  //tells Flash to ignore white space between tags in the XML file

// Global values pointing to XML nodes
var root_glossary_xmlnode:XMLNode;          // root node of XML
var letter_xmlnode:XMLNode;        // letters node  
var term_desc:Array = new Array();	//Hold definitions for each term.
var term_scroll:Array = new Array(); //Holds scroll position for each letter and term
//Make sure definition field is white
definition.setStyle( "backgroundColor", "white" );
//Custom Colors
//Extend Color object
Color.prototype.setTint = function (r, g, b, amount) {
	var trans = new Object();
	trans.ra = trans.ga = trans.ba = 100 - amount;
	var ratio = amount / 100;
	trans.rb = r * ratio;
	trans.gb = g * ratio;
	trans.bb = b * ratio;
	this.setTransform(trans);
}
//Set color of Interface
if (playerMain_mc.useInterfaceColors) {//This variable is set in the player.fla file for those styles that were built for tinting.
	var satPct:Number = playerMain_mc.root_xmlnode.attributes.saturationPercent;

	//Change heading color
	var headerColor:String = playerMain_mc.root_xmlnode.attributes.glossaryHeader;
	var headColor = new Color(title_bar_mc);
	headColor.setTint(playerMain_mc.convertHexToR(headerColor),playerMain_mc.convertHexToG(headerColor),playerMain_mc.convertHexToB(headerColor), satPct);
	//Change background color
	var backColor:String = playerMain_mc.root_xmlnode.attributes.glossaryColor;
	var backgroundColor = new Color(background_mc);
	backgroundColor.setTint(playerMain_mc.convertHexToR(backColor),playerMain_mc.convertHexToG(backColor),playerMain_mc.convertHexToB(backColor), satPct);
	
	if (playerMain_mc.useButtonTextColor){
		var buttonTextColor:String = playerMain_mc.root_xmlnode.attributes.buttonTextColor;
		var b1Color = new Color(close_btn.buttonText_mc);
		b1Color.setTint(playerMain_mc.convertHexToR(buttonTextColor),playerMain_mc.convertHexToG(buttonTextColor),playerMain_mc.convertHexToB(buttonTextColor), satPct);

		var buttonColor:String = playerMain_mc.root_xmlnode.attributes.buttonColor
		var b2Color = new Color(close_btn.back1);
		b2Color.setTint(playerMain_mc.convertHexToR(buttonColor),playerMain_mc.convertHexToG(buttonColor),playerMain_mc.convertHexToB(buttonColor), satPct);
		var b3Color = new Color(close_btn.back2);
		b3Color.setTint(playerMain_mc.convertHexToR(buttonColor),playerMain_mc.convertHexToG(buttonColor),playerMain_mc.convertHexToB(buttonColor), satPct);
	} else {
		var buttonColor:String = playerMain_mc.root_xmlnode.attributes.buttonColor
		var b2Color = new Color(close_btn);
		b2Color.setTint(playerMain_mc.convertHexToR(buttonColor),playerMain_mc.convertHexToG(buttonColor),playerMain_mc.convertHexToB(buttonColor), satPct);
	}
}

//Accessibility Features
player.menu_txt._accProps = new Object();
player.menu_txt._accProps.silent = true;
player.terms_txt._accProps = new Object();
player.terms_txt._accProps.silent = true;
player.close_btn._accProps = new Object();
player.close_btn._accProps.name = "Close";
player.close_button._accProps = new Object();
player.close_button._accProps.name = "Close";
player.term_txt._accProps = new Object();
player.term_txt._accProps.name = "term";
Accessibility.updateProperties();

function loadGlossary(load_boolean) {
	if (load_boolean) {
		root_glossary_xmlnode = glossary_xml.firstChild;
		letter_xmlnode = root_glossary_xmlnode.firstChild;
		showGlossary();
		//Display parsing error status
		if (glossary_xml.status != 0) {
			var errorMessage:String;
			switch (glossary_xml.status) {
				case -2 :
				  errorMessage = "A CDATA section was not properly terminated.";
				  break;
				case -3 :
				  errorMessage = "The XML declaration was not properly terminated.";
				  break;
				case -4 :
				  errorMessage = "The DOCTYPE declaration was not properly terminated.";
				  break;
				case -5 :
				  errorMessage = "A comment was not properly terminated.";
				  break;
				case -6 :
				  errorMessage = "An XML element was malformed.";
				  break;
				case -7 :
				  errorMessage = "Out of memory.";
				  break;
				case -8 :
				  errorMessage = "An attribute value was not properly terminated.";
				  break;
				case -9 :
				  errorMessage = "A start-tag was not matched with an end-tag.";
				  break;
				case -10 :
				  errorMessage = "An end-tag was encountered without a matching start-tag.";
				  break;
				default :
				  errorMessage = "An unknown error has occurred.";
				  break;
			}
			trace("The XML file did not parse correctly -- status: "+glossary_xml.status+" ("+errorMessage+")");
		}
	}
}

function showGlossary() {
	terms_txt.html = true;
	var styles = new TextField.StyleSheet();
	styles.load("glossary.css");//Load the style sheet.
	styles.onLoad = function(ok) {
	  if (!ok) {//Did the style load OK? If it doesn't load, no data loads.
		trace("Error loading CSS file.");
	  } else {
		terms_txt.styleSheet = styles;//Apply the style
		definition.styleSheet = styles;//Apply to definition field
		terms_txt.selectable = false;
		//Load XML data
		loadData();
	  }
	}
}
//Load XML data into Glossary. Only runs if CSS file loads successully.
function loadData() {
	//Loop through XML data and place it in the text field.
	var index:Number = 0;
	var index2:Number = 0;
	var scroll_num:Number = 1;
	var text_holder:String = "";
	
	
	
	
	for (var currentLetter:XMLNode = letter_xmlnode;currentLetter != null;currentLetter = currentLetter.nextSibling){//loop through letters in glossary
		text_holder += "<span class=\"h1\">" + currentLetter.attributes.text + "</span><br>";
		//trace(currentLetter.attributes.text);
		//Create array used for scrolling terms field
		row2 = [currentLetter.attributes.text, scroll_num, -1];
		term_scroll[index2] = row2;
		scroll_num++;
		index2++;
		
		/* Customized Code ofr this player */
		letters[currentLetter.attributes.text] = new Array();
		/* ------------------------ */
		
		
		
		for (var currentTerm:XMLNode = currentLetter.firstChild;currentTerm != null;currentTerm = currentTerm.nextSibling){//loop through pages
			text_holder += "<a href=\"asfunction:showDescription," + index + "\">" + currentTerm.attributes.text + "</a><br>";
			//trace(currentTerm.attributes.text);
			var row = [currentTerm.attributes.text,("<body>"+currentTerm.firstChild.firstChild.nodeValue+"</body>")]
			term_desc[index]= row;
			//trace(currentTerm.firstChild.firstChild.nodeValue);
			//Scroll attribute
			var numLines:Number = currentTerm.attributes.numWrap;
			if (isNaN(numLines)){
				numLines = 1;
			}
			//Create array used for scrolling terms field
			row2 = [currentTerm.attributes.text, scroll_num, index];
			term_scroll[index2] = row2;
			index++;
			scroll_num = Number(scroll_num) + Number(numLines);
			index2++;
			
			
			 var _obj = new Object();
			_obj.title = currentTerm.attributes.text;
			_obj.text = currentTerm.firstChild.firstChild.nodeValue;						
			
			/* Customized Code ofr this player */			
				letters[currentLetter.attributes.text].push(_obj);			
			/* ------------------------------ */
		}
		
		
		
		
	}
	
	terms_txt.htmlText = text_holder;
	showMenu();
}
//Display Menu of letters of the alphabet. Use HTML to simplify the look of the menu.
function showMenu(){
	/*
	var styles = new TextField.StyleSheet();
	styles.load("glossary_menu.css");//Load the style sheet.
	styles.onLoad = function(ok) {
	  if (!ok) {//Did the style load OK
		trace("Error loading CSS file.");
	  } else {
		menu_txt.styleSheet = styles; //Apply to menu
		var menu_string:String = "<a href=\"asfunction:scrollTerms,a\">A </a><a href=\"asfunction:scrollTerms,b\">B </a><a href=\"asfunction:scrollTerms,c\">C </a><a href=\"asfunction:scrollTerms,d\">D </a><a href=\"asfunction:scrollTerms,e\">E </a><a href=\"asfunction:scrollTerms,f\">F </a><a href=\"asfunction:scrollTerms,g\">G </a><a href=\"asfunction:scrollTerms,h\">H </a><a href=\"asfunction:scrollTerms,i\">I </a><a href=\"asfunction:scrollTerms,j\">J </a><a href=\"asfunction:scrollTerms,k\">K </a><a href=\"asfunction:scrollTerms,l\">L </a><a href=\"asfunction:scrollTerms,m\">M </a><a href=\"asfunction:scrollTerms,n\">N </a><a href=\"asfunction:scrollTerms,o\">O </a><a href=\"asfunction:scrollTerms,p\">P </a><a href=\"asfunction:scrollTerms,q\">Q </a><a href=\"asfunction:scrollTerms,r\">R </a><a href=\"asfunction:scrollTerms,s\">S </a><a href=\"asfunction:scrollTerms,t\">T </a><a href=\"asfunction:scrollTerms,u\">U </a><a href=\"asfunction:scrollTerms,v\">V </a><a href=\"asfunction:scrollTerms,w\">W-Z</a>";
		menu_txt.html=true;
		menu_txt.htmlText = menu_string;
		menu_txt.selectable = false;
		//variable to indicate that glossary has loaded.
		playerMain_mc.glossaryLoaded = true;
	  }
	}
	*/
	
	
	/* CUSTOMIZED CODE FOR THIS PLAYER */
	var letters=["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];
	for (var i=0;i<letters.length;i++)
	{
		menu_mc[letters[i]].letter = letters[i]
		
		menu_mc[letters[i]].onRollOver = function()
		{
			this._alpha = 100;
			this._parent.glow_mc.gotoAndStop(this.letter);
		}
		menu_mc[letters[i]].onRollOut = menu_mc[letters[i]].onReleaseOutside = function()
		{
			this._alpha = 100;
			this._parent.glow_mc.gotoAndStop(1);
		}
		menu_mc[letters[i]].onRelease = function()
		{						
			this.enabled = false;			
			this._parent.glow_selected_mc.gotoAndStop(this.letter);
			selectedLetter.enabled = true;			
			selectedLetter = this;
			showDescription(this.letter.toUpperCase());
			
		}
		
	}
	menu_mc[letters[0]].onRelease();
	
	
}



function showDescription(indexNum){
	
	
	term_txt.text = term_desc[indexNum][0];
	definition.text = term_desc[indexNum][1]; 
	trace("*** "+indexNum+letters[indexNum].length)
	/* Customized code */
	var posY = 0;
	var i=0;
	while(testMC["item"+i])
	{
		testMC["item"+i].removeMovieClip();
		i++;
	}
	
	for(var i=0;i<letters[indexNum].length;i++)	
	{
		trace("indexNum "+letters[indexNum])
		
		var item = testMC.attachMovie("item","item"+i,testMC.getNextHighestDepth());
		item._y = posY;
		
		item.definition.autoSize = true;
		item.definition._width = item.title;		
		item.title.text = letters[indexNum][i].title;
		item.definition.html = true;
		item.definition.htmlText = letters[indexNum][i].text||"";				
		item.bg_mc._height = item.definition._y+item.definition._height+10;		
		posY+=item._height;
	}
	
	if(sBar)
	{
		sBar.removeMovieClip();
		delete sBar;
	}
	testMC._y = mask_mc._y;
	scroll_mc.dragHandleMC._y = 0;
	sBar = new Scrollbar(testMC,scroll_mc);


	
}

//Scroll the terms to the appropriate letter
function scrollTerms(theLetter){
	//trace(theLetter);
	//Loop through the scroll array and determine field scroll position based upon letter selected or word selected.
	var found:Boolean = false;//Did we find a match
	var test_term:String;
	for (var i = 0;i < term_scroll.length;i++) {//Cycle through all the terms and letters.
		test_term = term_scroll[i][0];//get word or letter
		if (test_term.toUpperCase() == theLetter.toUpperCase()) {//Is there a match with the clicked term or letter?
			if (test_term.length > 1) {//Is this a letter or a word? A hyper linked word may be clicked in the narration text.
				//trace(test_term);
				scrollBar.scrollPosition = term_scroll[i][1];//scroll scrollbar
				terms_txt.scroll = term_scroll[i][1];//scroll field
				showDescription(term_scroll[i][2]);//Show the term and description
			} else { //It is a letter
				//trace(test_term);
				scrollBar.scrollPosition = term_scroll[i][1];//scroll scrollbar
				terms_txt.scroll = term_scroll[i][1];//scroll field
			}
			found = true;//term found
			break;
		}
	}
	if (!found) {//If the term or letter was not found, find the closest letter.
		var first_letter:String = theLetter.substr(0,1);
		var prev_letter:Number; //Stores index of last letter so we can scroll to it.
		for (var j = 0;j < term_scroll.length;j++) {//Cycle through terms again
			test_term = term_scroll[j][0];//get word or letter
			if (test_term.length == 1) {//Is this a letter or a word? Only want to scroll to a letter
				if (first_letter.toUpperCase() < test_term.toUpperCase()) { //if letter is less than we have gone past it so use previous letter.
					if (prev_letter > -1) {
						scrollBar.scrollPosition = term_scroll[prev_letter][1];//scroll scrollbar
						terms_txt.scroll = term_scroll[prev_letter][1];//scroll field
					} else {
						scrollBar.scrollPosition = term_scroll[j-1][1];//scroll scrollbar
						terms_txt.scroll = term_scroll[j-1][1];//scroll field
					}
					found = true;
					break;
				}
				prev_letter = j;
			}
		}
		if (!found) {//If letter is not found scroll to the end.
			scrollBar.scrollPosition = terms_txt.maxscroll;
			terms_txt.scroll = terms_txt.maxscroll;
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
		close_glossary();
	}
	close_btn.onReleaseOutside = function() {
		this.gotoAndStop("up");
	}
} else {
	close_btn.onRelease = function () {
		close_glossary();
	}
}

function click(evt){
	close_glossary();
}
close_button.addEventListener("click", this);

function close_glossary() {
	
	var moveOut = new Tween(this,"_x",Strong.easeIn,this._x,1050,1,true);			
	moveOut.onMotionFinished = function()
	{
		player.unloadMovie();
		player._x = player_x;
		player._y = player_y;
		playerMain_mc.glossaryLoaded = false;
	}


	
}

//Script for title bar to drag movie
title_bar_mc.onPress = function(){
	player.startDrag();
}

title_bar_mc.onRelease = function() {
	player.stopDrag();
}

//Code for background image to prevent clicks through the glossary.
bkgnd_mc.useHandCursor = false;
bkgnd_mc.onRollOver = function() {
}
bkgnd_mc.onRollOut = function(){
}
bkgnd_mc.onPress = function(){
}
bkgnd_mc.onRelease = function(){
}
bkgnd_mc.onMouseDown = function(){
}
bkgnd_mc.onMouseUp = function(){
}
