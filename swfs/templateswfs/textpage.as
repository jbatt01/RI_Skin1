/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Loads text.
*/

//Load the text
function loadText(){
	//Get narration node
	var pagetext_xmlnode:XMLNode = matchSiblingNode(_parent.currentPage_xmlnode.firstChild,"pText");
	var noteText:XMLNode = matchSiblingNode(_parent.currentPage_xmlnode.firstChild,"note");
	var noteType:String = _parent.currentPage_xmlnode.attributes.nType;
	var titleText:String = _parent.currentPage_xmlnode.attributes.title;
	if (titleText !== undefined && !playerMain_mc.showPageTitle) {
		titleStr = "<p class = 'h1'>" +  titleText + "</p><br>";
	} else {
		titleStr = "";
	}
	if (pagetext_xmlnode.firstChild.nodeValue !== undefined){//If it exists
		var text_str:String = "<body>" + titleStr + "<p class='pageText'>" + pagetext_xmlnode.firstChild.nodeValue + "</p>" + "</body>";
		page_txt._visible = true;
	} else {
		var text_str:String = ""; //must have page text to display the page title and text
		page_txt._visible = false;
		//trace(text_str.indexOf(String.fromCharCode(10)));
		//page_txt.html = true;
	}
	//Set the styles
	var format = new TextField.StyleSheet();
	format.load("swfs/templateswfs/template_styles.css");//Load the style sheet.
	format.onLoad = function(ok) {
		if (!ok) {//Did the style load OK? If it doesn't load, no data loads.
			trace("Error loading CSS file.");
		} else {
			page_txt.styleSheet = format;//Apply the style
			note_txt.styleSheet = format;
			page_txt.text = text_str;//If the text is not set inside this onLoad function it doesn't use CSS because I think the text is inserted before the CSS.
			
			if (noteType != "none"  && noteType !== undefined){
				loadNote(noteText);
			} else { //if text is not defined
				note_txt._visible = false;
				icon_mc._visible = false;
				note_highlight._visible = false;
			}
		}
	}
}

//Loads the appropriate note icon and text
//note_xmlnode - the note node
function loadNote(noteText){	
	//Load note text
	if (noteText !== undefined){
				//Determine type of note
		var noteType:String = _parent.currentPage_xmlnode.attributes.nType;
		var bMargin:Number = 20;
		switch (noteType){
			case "note":
				icon_mc.loadMovie("swfs/templateswfs/hint_icon.swf");
				break;
			case "tip":
				icon_mc.loadMovie("swfs/templateswfs/tip_icon.swf");
				break;
			case "warning":
				icon_mc.loadMovie("swfs/templateswfs/warning_icon.swf");
				break;
		}
		//write note text to note field
		note_txt.html = true;
		var note_txtStr:String = "<body><p class = 'note'>" +  noteText.firstChild.nodeValue  + "</p></body>" 
		note_txt.htmlText = note_txtStr
		var newY = playerMain_mc.presentSizeH - note_txt._height - bMargin;
		var loadPercentage:Number = playerMain_mc.currentPage_xmlnode.attributes.loadPercentage;

		if (loadPercentage == 0) { //if the page loading the text doesn't include media
			newY += playerMain_mc.mediaPlayerNum;
		}
		note_txt._y = newY;
		note_txt.setSize(playerMain_mc.presentSizeW - note_txt._x - 10,note_txt._height);
		icon_mc._y = newY;
		note_highlight._y = icon_mc._y - 4;
		//set color
		var backgroundColor:String = playerMain_mc.root_xmlnode.attributes.backgroundColor;
		if (backgroundColor !== undefined)
		{
			backColor = new Color(note_highlight);
			backColor.setTint(playerMain_mc.convertHexToR(backgroundColor),playerMain_mc.convertHexToG(backgroundColor),playerMain_mc.convertHexToB(backgroundColor), 50);
		}
		//trace("icon Y: " +  icon_mc._y + " - note highlight: " + note_highlight._y)
		note_highlight._x = -3;
		note_highlight._width = playerMain_mc.presentSizeW + 6
		note_highlight._height = playerMain_mc.presentSizeH - note_highlight._y;
		if (playerMain_mc.includesContentImage)
			note_highlight._visible = false;
		else
			note_highlight._visible = true;
	}
}
