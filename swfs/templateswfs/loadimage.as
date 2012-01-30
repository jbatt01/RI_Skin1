/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	loading image
*/

var captionText:String = "";
//Loads the image that is displayed
function loadImage(){
	//Constants
	var caption_head:String = _parent.currentPage_xmlnode.attributes.captionhead;
	var caption_text:String = _parent.currentPage_xmlnode.attributes.captiontext;
	var swfFile:Boolean = false;
	//Object to load image
	var picture_mcl:MovieClipLoader = new MovieClipLoader();
	var mclListener:Object = new Object();
	//When picture loads, position it.
	mclListener.onLoadInit = function(target_mc:MovieClip){
		//Adjust Image
		var pictH:Number = target_mc._height;
		var pictW:Number = target_mc._width;
		if (swfFile){
			//trace(_parent.currentPage_xmlnode.attributes.swfHeight)
			if (_parent.currentPage_xmlnode.attributes.swfHeight !== undefined){
				pictH = Number(_parent.currentPage_xmlnode.attributes.swfHeight);
				pictW = Number(_parent.currentPage_xmlnode.attributes.swfWidth);
			}
		}
		adjustSize(pictW,pictH)
	}
	picture_mcl.addListener(mclListener);

	//Get Image node
	var imgLoc:String = _parent.currentPage_xmlnode.attributes.imageFile;
	if (imgLoc !== undefined){
		if (imgLoc.toLowerCase().indexOf(".swf") > 0){
			//Get SWF File
			swfFile = true;
			picture_mcl.loadClip(imgLoc,mediaSWF_mc)
			image_mc = mediaSWF_mc;
		}else{
			//Get JPEG file
			picture_mcl.loadClip(imgLoc,image_mc);
		}
		//Load and position caption
		if (caption_head != "" && caption_head !== undefined) {
			captionText = "<b>" + _parent.currentPage_xmlnode.attributes.captionhead + "</b> ";
		}
		if (caption_text !== "" && caption_text != undefined) {
			captionText = captionText + caption_text;
		}
		caption_txt.html = true;
		caption_txt.htmlText = captionText;
	}
//picture_mc._visible = false;
}

//modify preloader width based on loading the image
middlePrevWidth = (preLoader.track._width - preLoader.right._width) *.5;
middleWidthRemaining = (preLoader.track._width - preLoader.right._width) *.3;
	
// Monitor the loading progress of the image.
onEnterFrame = function()
{
	var bl = image_mc.getBytesLoaded()
	var bt = image_mc.getBytesTotal()
	if (bl > 4 && bt > 4 && bl >= bt)	// Loading is complete.
	{
		delete onEnterFrame;
		gotoAndStop(3);
		//preLoader.unloadMovie();
	}
	else
	{
		preLoader.middle._width = Math.round(bl / bt * middleWidthRemaining) + middlePrevWidth;
		preLoader.right._x = preLoader.middle._x + preLoader.middle._width;
	}
}

function adjustSize(pictW:Number,pictH:Number){
	//Constants
	var rMargin:Number = 30; //Number of pixels
	var lMargin:Number = 30; //Number of pixels
	var gutter:Number = 10;  //Space between picture and text in pixels
	var caption_gutter:Number = 5; //Space between picture and caption in pixels
	var pictVertSpace:Number = playerMain_mc.presentSizeH - 90; //Space vertically allowed for picture
	var pictHorizSpace:Number = playerMain_mc.presentSizeW; //Space horizontally allowed for picture
	var tMargin:Number = 10; //Number of pixels
	var bMargin:Number = 20; //If you change this also change it in textpage.as
	var totW:Number = playerMain_mc.presentSizeW; //the total size of the movie. If you change the movie size change this.
	var totH:Number = playerMain_mc.presentSizeH; // The heighth of the movie. Change this is movie changes.
	var noteType:String = _parent.currentPage_xmlnode.attributes.nType; //used to determine relative size of page text if img centered
	var caption_head:String = _parent.currentPage_xmlnode.attributes.captionhead;
	var caption_text:String = _parent.currentPage_xmlnode.attributes.captiontext;

	//Adjust Image
	//var pictH:Number = target_mc._height;
	//var pictW:Number = target_mc._width;
	//trace("pictH: " + pictH + "  pictW: " + pictW);
	var newX:Number = lMargin;
	image_mc._x = Math.round(newX);
	var imgPos:String = _parent.currentPage_xmlnode.attributes.imgPos;
	var loadPercentage:Number = _parent.currentPage_xmlnode.attributes.loadPercentage;
	
	if (loadPercentage == 0) { //if the page loading the text doesn't include media
		totH = playerMain_mc.presentSizeH + playerMain_mc.mediaPlayerNum; //number of pixels
		pictVertSpace = playerMain_mc.presentSizeH + playerMain_mc.mediaPlayerNum;
	} else {
		totH = playerMain_mc.presentSizeH;
		pictVertSpace = playerMain_mc.presentSizeH;
	}
	//image_mc.onMouseUp = function(){
		//image_mc.useHandCursor = true;
		//trace("here");
	//}
	if (playerMain_mc.currentPage_xmlnode.attributes.pType.toLowerCase() == "image and audio" || playerMain_mc.currentPage_xmlnode.attributes.pType.toLowerCase() == "image link and audio"){
		imgPos = "imageaudio"
	}
	switch (imgPos.toLowerCase()){
		case "center":
			image_mc._y = tMargin//Math.round(((pictVertSpace - tMargin - pictH - gutter)/2)/2);
			image_mc._x = Math.round((pictHorizSpace - pictW)/2);
			page_txt._x = lMargin;
			page_txt._y = image_mc._y + pictH + caption_txt._height + gutter;
			var newSizeW:Number = (pictHorizSpace - lMargin - rMargin);
			var newSizeH:Number = (totH - image_mc._y - pictH - caption_txt._height - gutter - bMargin - tMargin);
			if (caption_head == "" || caption_head == undefined) {
				if (caption_text == "" || caption_text == undefined){
					page_txt._y = page_txt._y - caption_txt._height;
					newSizeH = (newSizeH + caption_txt._height - gutter);
				}
			}
			if (noteType != "none") {
				newSizeH = (newSizeH - note_txt._height);
			}
			if (newSizeH < 42)newSizeH = 42;
			page_txt.setSize(int(newSizeW),int(newSizeH));
			break;
		case "bottom center":
			page_txt._x = lMargin;
			page_txt._y = tMargin;
			var newSizeW:Number = (pictHorizSpace - lMargin - rMargin);
			var newSizeH:Number = (totH - pictH - caption_txt._height - gutter - bMargin - tMargin);
			if (caption_head == "" || caption_head == undefined) {
				if (caption_text == "" || caption_text == undefined){
					//page_txt._y = page_txt._y - caption_txt._height;
					newSizeH = (newSizeH + caption_txt._height - gutter);
				}
			}
			if (noteType != "none") {
				newSizeH = (newSizeH - note_txt._height);
			}
			if (newSizeH < 42){
				newSizeH = 42;
				image_mc._y = page_txt._y + newSizeH + gutter;
			} else {
				image_mc._y = page_txt._y + newSizeH + gutter;
			}
			
			image_mc._x = Math.round((pictHorizSpace - pictW)/2);
	
			page_txt.setSize(int(newSizeW),int(newSizeH));
			break;
		case "left and center":
			page_txt._x = lMargin + gutter + pictW; //position page text to the right of the pic
			var newHeight:Number = totH - tMargin - bMargin;
			if (noteType != "none") {
				newHeight = (newHeight - note_txt._height - gutter);
				image_mc._y = Math.round((pictVertSpace - tMargin - bMargin - note_txt._height - pictH)/2);
			} else {
				image_mc._y = Math.round((pictVertSpace - tMargin - bMargin - pictH)/2);
			}
			page_txt.setSize(totW - pictW - rMargin - lMargin - gutter,newHeight);
			break;
		case "left":
			image_mc._x = Math.round(lMargin);
			page_txt._x = lMargin + gutter + pictW;
			var newHeight:Number = totH - tMargin - bMargin;
			if (noteType != "none") {
				newHeight = (newHeight - note_txt._height - gutter);
			}
			page_txt.setSize(totW - pictW - rMargin - lMargin - gutter,newHeight);
			break;
		case "right":
			image_mc._x = Math.round((totW - rMargin - pictW));
			page_txt._x = lMargin;
			var newHeight:Number = totH - tMargin - bMargin;
			if (noteType != "none") {
				newHeight = (newHeight - note_txt._height - gutter);
			}
			page_txt.setSize(totW - pictW - rMargin - lMargin - gutter,newHeight);
			//trace(page_txt._width);
			break;
		case "right and center":
			image_mc._x = Math.round((pictHorizSpace - rMargin - pictW));
			
			page_txt._x = lMargin;
			var newHeight:Number = totH - tMargin - bMargin;
			if (noteType != "none") {
				newHeight = (newHeight - note_txt._height - gutter);
				image_mc._y = Math.round((pictVertSpace - tMargin - bMargin - note_txt._height - pictH)/2);
			} else {
				image_mc._y = Math.round((pictVertSpace - tMargin - bMargin - pictH)/2);
			}
			page_txt.setSize(totW - pictW - rMargin - lMargin - gutter,newHeight);
			break;
		case "imageaudio":
			image_mc._y = Math.round(((pictVertSpace - tMargin - pictH - gutter)/2)/2);
			image_mc._x = Math.round((pictHorizSpace - pictW)/2);
			break;
	}
	
	//Adjust Caption
	caption_txt._width = pictW;
	caption_txt._x = image_mc._x //make caption line up with wherever the image is
	//trace(image_mc._x + "   " + image_mc._y + "   " + caption_gutter + "   " + pictH);
	caption_txt._y = image_mc._y + caption_gutter + pictH;

	if (captionText != "")
	{
		//Adjust Caption background
		caption_back._visible = true;
		caption_back._width = pictW + 10;
		caption_back._x = image_mc._x - 5;
		caption_back._y = image_mc._y + caption_gutter + pictH;
	} else {
		caption_back._visible = false;
	}
}