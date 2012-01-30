/*
			RTMP Streaming Video Page
			
			By Rapid Intake
			
			2/4/2011
			Copyright, Rapid Intake 2011
			
			Developer: Steven Hancock
*/

//Declare Variables
var containsPgText:Boolean = true;
var containsTitle:Boolean = true;
//var theWidth:Number = 760;
//var theHeight:Number = 405;
var theWidth:Number = playerMain_mc.presentSizeW;
var theHeight:Number = playerMain_mc.presentSizeH;
var tMargin:Number = 5;
var bMargin:Number = 5;
var lMargin:Number = 5;
var rMargin:Number = 5;
var gutter:Number = 5;
var borderDiffX = 3;
var borderDiffY = 3;
var controlOrigX = playerMain_mc.controller_mc._x;
var controlOrigY = playerMain_mc.controller_mc._y;
var theSize:String = "sm";
var rtmp:Boolean = false;
var mediaContorlW:Number = 334;
var vidWidth:Number = 320;
var vidHeight:Number = 240;
var borderWidth:Number = 12;

function loadText()
{
	var pagetext_xmlnode:XMLNode = matchSiblingNode(_parent.currentPage_xmlnode.firstChild,"pText");
	var titleText:String = _parent.currentPage_xmlnode.attributes.title;
//	trace(titleText)
	if (!playerMain_mc.showPageTitle)
	{
		if (titleText !== undefined) {
			titleStr = "<p class = 'h1'>" +  titleText + "</p><br>";
		} else {
			titleStr = "";
		}
	}
	
	if (pagetext_xmlnode.firstChild.nodeValue !== undefined && pagetext_xmlnode.firstChild.nodeValue != ""){//If it exists
		var text_str:String = "<body>" + titleStr + "<p class='pageText'>" + pagetext_xmlnode.firstChild.nodeValue + "</p>" + "</body>";
		page_txt._visible = true;
	} else {
		if (titleText == undefined)
		{
			var text_str:String = ""; //must have page text to display the page title and text
			page_txt._visible = false;
			containsPgText = false;
			containsTitle = false;
		} else {	//We don't use title text in this page type.
			var text_str:String = "<body>" + titleStr + "</body>";
			page_txt._visible = true;
			containsPgText = false;
		}
		
	}
	//Set the styles
	var format = new TextField.StyleSheet();
	format.load("swfs/templateswfs/template_styles.css");//Load the style sheet.
	format.onLoad = function(ok) {
		if (!ok) {//Did the style load OK? If it doesn't load, no data loads.
			trace("Error loading CSS file.");
		} else {
			page_txt.styleSheet = format;//Apply the style
			//trace(text_str)
			page_txt.text = text_str;//If the text is not set inside this onLoad function it doesn't use CSS because I think the text is inserted before the CSS.
		}
	}
	sizeAndPosition();
}

function sizeAndPosition()
{
	var mediaSize:String = _parent.currentPage_xmlnode.attributes.mediaSize;
	if (!containsPgText)
	{
		var mediaPos:String = "noTextCenter";
	} else {
		var mediaPos:String = _parent.currentPage_xmlnode.attributes.mediaPos;
	}
	var fact:Number = 1;
	
	
	switch (mediaSize.toLowerCase())
	{
		case "320x240":
			vidWidth = 320;
			vidHeight = 240;
			
			break;
		case "640x480":
			vidWidth = 640;
			vidHeight = 480;
			
			break;
		case "256x144":
			vidWidth = 256;
			vidHeight = 144;
			break;
		case "512x288":
			vidWidth = 512;
			vidHeight = 288;
			
			break;
		case "custom":
			vidWidth = Number(_parent.currentPage_xmlnode.attributes.videoWidth);
			vidHeight = Number(_parent.currentPage_xmlnode.attributes.videoHeight);
			
			break;
		default:
			vidWidth = 320;
			vidHeight = 240;
			
	}
	var ratio:Number = vidWidth/vidHeight;
	
	if (vidWidth < 300)
	{
		borderWidth -= 2;
	}
	resizeObjects();
	
	switch (mediaPos.toLowerCase()) {
		case "notextcenter":
			newX = Math.ceil((theWidth - video_player._width)/2);
			newY = Math.ceil((theHeight - video_player._height)/2);
			
			
			//page_txt._visible = false;
			//Need to position the controller.
			break;
		case "center" :
			newY = tMargin + borderDiffY;
			newX = Math.ceil((theWidth - video_player._width - borderDiffX)/2);
			
			page_txt._x = lMargin;
			page_txt._y = tMargin + border_mc._height + gutter;//media player is 30 pixels high.
			var newSizeW:Number = (theWidth-lMargin-rMargin);
			var newSizeH:Number = (theHeight - tMargin - border_mc._height - gutter - bMargin);//media player is 30 pixels high
			
			if (newSizeW > 0 && newSizeH > 0) page_txt.setSize(int(newSizeW),int(newSizeH));
			
			break;		
		case "left" :
			newX = lMargin + borderDiffX;
			newY = tMargin + borderDiffY; 
			
			page_txt._x = lMargin + border_mc._width + gutter;
			page_txt._y = tMargin;
			
			var newSizeW:Number = (theWidth-lMargin - border_mc._width - gutter - rMargin);
			var newSizeH:Number = (theHeight - tMargin - bMargin);
			
			page_txt.setSize(newSizeW,newSizeH);
			break;
		case "right" :
			newX = theWidth - rMargin - border_mc._width + borderDiffX + gutter;
			newY = tMargin + borderDiffY;
			
			page_txt._x = lMargin;
			page_txt._y = tMargin;
			
			var newSizeW:Number = (theWidth-lMargin - border_mc._width - gutter - rMargin);
			var newSizeH:Number = (theHeight - tMargin - bMargin);
			
			page_txt.setSize(newSizeW,newSizeH);
			break;
	}
	
	video_player._x = newX;
	video_player._y = newY;
	border_mc._x = newX - borderDiffX;
	border_mc._y = newY - borderDiffY;
	videoControl._x = border_mc._x + border_mc._width;
	videoControl._y = border_mc._y + border_mc._height - videoControl._height;
	
}

function resizeObjects(fact:Number)
{
	video_player._height = vidHeight;
	video_player._width = vidWidth;
	border_mc._height = vidHeight + borderWidth;
	border_mc._width = vidWidth + borderWidth;
	
	
//	trace(video_player._height + " - " + video_player._width);
}

function loadVideo()
{
	
	var myMediaURL:String = _parent.currentPage_xmlnode.attributes.mediaPath;
	if (myMediaURL.toLowerCase().indexOf("rtmp") > -1) rtmp = true;
	video_player.activeVideoPlayerIndex = 1;
	
	video_player.contentPath = myMediaURL;
	video_player.visibleVideoPlayerIndex = 1;
	video_player.play();
	
	if (rtmp)
	{
	//	preLoader.unloadMovie();
		
		showPageObjects();
	}
}

function isStreamingVideo()
{
	return true;
}

var listenerObject:Object = new Object();
listenerObject.ready = function(eventObject:Object):Void {
    // insert event-handling code here
preLoader.unloadMovie();
};
video_player.addEventListener("ready", listenerObject);