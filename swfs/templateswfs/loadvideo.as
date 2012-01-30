/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	load video
*/

//-----------------------------------------
// Video FullScreen Feature
//-----------------------------------------
import flash.geom.*;
//-----------------------------------------
// End Video FullScreen Feature
//-----------------------------------------



//loads media into media controller

function loadMedia() {
	
	//get XML data
	var myMediaURL:String = _parent.currentPage_xmlnode.attributes.mediaPath;
	var myMediaType:String = _parent.currentPage_xmlnode.attributes.mediaFormat;
	
	//load media container with media
	video_container.setMedia(myMediaURL, myMediaType);
	//trace("First Content Path: " + video_container.contentPath);
	playerMain_mc.aPageCompleted = false;
}

function positionMedia() { //this function called onEnterFrame in the RI_textvideo_pg.fla movie
	//Set vars for positioning
	//trace(loopingClip);
	//delete loopingClip.onEnterFrame;
	var mediaPos:String = _parent.currentPage_xmlnode.attributes.mediaPos;
	var rMargin:Number = 30; //Number of pixels
	var lMargin:Number = 30; //Number of pixels
	var gutter:Number = 10; //Space between picture and text in pixels
	var caption_gutter:Number = 5; //Space between picture and caption in pixels
	var pictVertSpace:Number = playerMain_mc.presentSizeH; //Space vertically allowed for picture
	var pictHorizSpace:Number = playerMain_mc.presentSizeW; //Space horizontally allowed for picture
	var tMargin:Number = 10; //Number of pixels
	var bMargin:Number = 20; //If you change this also change it in textpage.as
	var totW:Number = playerMain_mc.presentSizeW; //the total size of the movie. If you change the movie size change this.
	var totH:Number = playerMain_mc.presentSizeH; // The heighth of the movie. Change this is movie changes.
	var newY:Number = 0;//new position of media once determined; se case statement below
	
	var pictH:Number = video_container.preferredHeight; //"pict" in this case refers to the video
	var pictW:Number = video_container.preferredWidth;
	var containerW:Number = video_container.width;
	var containerH:Number = video_container.height;
	
	var noteType:String = _parent.currentPage_xmlnode.attributes.nType; //used to determine relative size of page text if img centered
	var caption_head:String = _parent.currentPage_xmlnode.attributes.captionhead;
	var caption_text:String = _parent.currentPage_xmlnode.attributes.captiontext;
	var loadPercentage:Number = _parent.currentPage_xmlnode.attributes.loadPercentage;
	
	if (loadPercentage == 0) { //if the page loading the text doesn't include media
		totH = playerMain_mc.presentSizeH + playerMain_mc.mediaPlayerNum; //number of pixels
		pictVertSpace = playerMain_mc.presentSizeH + playerMain_mc.mediaPlayerNum;
	} else {
		totH = playerMain_mc.presentSizeH;
		pictVertSpace = playerMain_mc.presentSizeH;
	}
	//trace("pictH: " + pictH + " containerH: " + containerH)
	switch (mediaPos.toLowerCase()) {
		case "center" :
			newY = (pictH - containerH)/2 + tMargin//((totH-tMargin-pictH-gutter)/2 + ((pictH - containerH)/2))/2;
			newX = (totW-pictW)/2 + ((pictW - containerW)/2);
			page_txt._x = lMargin;
			page_txt._y = video_container._y - ((pictH - containerH)/2) +pictH+caption_txt._height+gutter;
			var newSizeW:Number = (pictHorizSpace-lMargin-rMargin);
			var newSizeH:Number = (totH - tMargin - pictH - caption_txt._height - gutter - bMargin - tMargin);
			
			if (caption_head == "" || caption_head == undefined) {
				if (caption_text == "" || caption_text == undefined){
					page_txt._y = page_txt._y - caption_txt._height;
					newSizeH = (newSizeH + caption_txt._height);
				}
			}
			if (noteType != "none") {
				newSizeH = (newSizeH - note_txt._height);
			}
			if (newSizeH < 42)newSizeH = 42;
			page_txt.setSize(int(newSizeW),int(newSizeH));
			break;
		case "left and center" :
			newX = lMargin + ((pictW - containerW)/2);
			page_txt._x = lMargin+gutter+pictW;
			
			var newHeight:Number = totH - tMargin - bMargin;
			if (noteType != "none") {
				newHeight = (newHeight - note_txt._height - gutter);
				newY = (pictVertSpace-tMargin-bMargin-note_txt._height-pictH)/2 + ((pictH - containerH)/2);
			} else {
				newY = (pictVertSpace-tMargin-bMargin-pictH)/2 + ((pictH - containerH)/2);
			}
			page_txt.setSize(totW - pictW - rMargin - lMargin - gutter,newHeight);
			break;
		case "left" :
			newX = lMargin + ((pictW - containerW)/2);
			newY = tMargin + ((pictH - containerH)/2);
			page_txt._x = lMargin+gutter+pictW;
			
			var newHeight:Number = totH - tMargin - bMargin;
			if (noteType != "none") {
				newHeight = (newHeight - note_txt._height - gutter);
			}
			page_txt.setSize(totW - pictW - rMargin - lMargin - gutter,newHeight);
			break;
		case "right" :
			newX = (totW-rMargin-pictW) + ((pictW - containerW)/2); //the last addition of pixels is because the _x refers to the x pos of the container component before it is sized to fit the media
			newY = tMargin + ((pictH - containerH)/2);
			page_txt._x = lMargin;
			var newHeight:Number = totH - tMargin - bMargin;
			if (noteType != "none") {
				newHeight = (newHeight - note_txt._height - gutter);
			}
			page_txt.setSize(totW - pictW - rMargin - lMargin - gutter,newHeight);
			break;
		case "right and center" :
			newX = (totW-rMargin-pictW) + ((pictW - containerW)/2);
			page_txt._x = lMargin;
			
			var newHeight:Number = totH - tMargin - bMargin;
			if (noteType != "none") {
				newHeight = (newHeight - note_txt._height - gutter);
				newY = (pictVertSpace-tMargin-bMargin-note_txt._height-pictH)/2 + ((pictH - containerH)/2);
			} else {
				newY = (pictVertSpace-tMargin-bMargin-pictH)/2 + ((pictH - containerH)/2);
			}
			page_txt.setSize(totW - pictW - rMargin - lMargin - gutter,newHeight);
			break;
	}
	
	//===========================================================================//
	//================= CUSTOMIZED CODE: VIDEO FULLSCREEN =======================//	
	// Move the fullScreen button on the right botom corner
	fullscreen_btn._x = video_container._x+((pictW + containerW)/2);
	fullscreen_btn._y = video_container._y+((pictH + containerH)/2);
	
	//position media based on new values
	if(Stage["displayState"] == "normal" || Stage["displayState"] == undefined)
	{		
		video_container._x = Math.round(newX);
		video_container._y = Math.round(newY);
		video_container.autoSize = true;	
		fullscreen_btn._visible = true;
		bg._visible = false;
	}
	else
	{
		bg._visible = true;
		video_container._x = 0;
		video_container._y = 0;
	}
	//================= CUSTOMIZED CODE: VIDEO FULLSCREEN =======================//
	//===========================================================================//
	
	
	//Load and position caption
	var captionText:String = "";
	caption_txt._width = pictW;
	caption_txt._x = newX - ((pictW - containerW)/2)//make caption line up with wherever the image is
	caption_txt._y = newY - ((pictH - containerH)/2) + caption_gutter + pictH;
	if (caption_head != "" && caption_head !== undefined) {
		captionText = "<b>" + _parent.currentPage_xmlnode.attributes.captionhead + "</b> ";
	}
	if (caption_text !== "" && caption_text != undefined) {
		captionText = captionText + caption_text;
	}
	caption_txt.html = true;
	caption_txt.htmlText = captionText;
	
	if (captionText != "")
	{
		//Adjust Caption background
		caption_back._visible = true;
		caption_back._width = pictW + 10;
		caption_back._x = caption_txt._x - 5;
		caption_back._y = caption_txt._y;
	} else {
		caption_back._visible = false;
	}
}

//load template preloader
//load the portion that belongs to the media
middlePrevWidth = (preLoader.track._width - preLoader.right._width) *.8; //previously loaded frames take up 80% of preloader width 
middleWidthRemaining = (preLoader.track._width - preLoader.right._width) *.2; //media on this frame takes 20% of preloader width
loadPerc = playerMain_mc.currentPage_xmlnode.attributes.loadPercentage;
if (loadPerc < 1) {
	loadPerc = 1;
}

var myProgressListener = new Object(); 
myProgressListener.progress = function(){ 
		var bl = video_container.bytesLoaded;
		//trace("loadperc = " + (loadPerc/100))
		var bt = video_container.bytesTotal * (loadPerc/100);
		//trace("bl: " + bl + " bt: " + bt);
		if (bl > 4 && bt > 4 && bl >= bt)	// Loading is complete.
		{
			//trace("loading is complete")
			preLoader.unloadMovie();
			//video_container.play();
		}
		else
		{
			preLoader.middle._width = Math.round(bl / bt * middleWidthRemaining) + middlePrevWidth;
			preLoader.right._x = preLoader.middle._x + preLoader.middle._width;
			//video_container.pause();
			//video_container.autoPlay = false;
		}
}

video_container.addEventListener("progress", myProgressListener);



//===========================================================================//
//================= CUSTOMIZED CODE: VIDEO FULLSCREEN =======================//	
bg.onRelease = function()
{
	trace("LOCKED")
}
bg.useHandCursor= false;
bg._visible = false;
bg._x = 0;
bg._y = 0;
bg._width = playerMain_mc.presentSizeW;
bg._height = playerMain_mc.presentSizeH;


fullscreen_btn.onRelease = goFullScreen;
function goFullScreen(){		
	playerMain_mc.fullvideo_mc._visible = true;
	this._visible = false;
	bg._visible = true;

	video_container.autoSize = false;
	video_container.setSize(playerMain_mc.StageW,playerMain_mc.StageH)	
	playerMain_mc.presentation._x = 0;
	playerMain_mc.presentation._y = 0;	
	video_container._x = 0;
	video_container._y = 0;
	Stage["displayState"] = "fullScreen";
	playerMain_mc.presentation.setDepthAbove(playerMain_mc.fullvideo_mc);		
}
//================= CUSTOMIZED CODE: VIDEO FULLSCREEN =======================//	
//===========================================================================//