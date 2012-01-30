/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	
*/

//loads media into media controller

function loadMedia() {
	
	//get XML data
	var myMediaURL:String = _parent.currentPage_xmlnode.attributes.mediaPath;
	var myMediaType:String = _parent.currentPage_xmlnode.attributes.mediaFormat;
	
	//load media container with media
	media_container.setMedia(myMediaURL, myMediaType);
	playerMain_mc.aPageCompleted = false;
}

function positionMedia() { //this function called onEnterFrame in the RI_textvideo_pg.fla movie
	//Set vars for positioning
	var mediaPos:String = _parent.currentPage_xmlnode.attributes.mediaPos;
	var rMargin:Number = 30; //Number of pixels
	var lMargin:Number = 30; //Number of pixels
	var gutter:Number = 10; //Space between picture and text in pixels
	var caption_gutter:Number = 5; //Space between picture and caption in pixels
	var pictVertSpace:Number = playerMain_mc.presentSizeH - 90; //Space vertically allowed for picture
	var pictHorizSpace:Number = playerMain_mc.presentSizeW; //Space horizontally allowed for picture
	var tMargin:Number = 10; //Number of pixels
	var totW:Number = playerMain_mc.presentSizeW; //the total size of the movie. If you change the movie size change this.
	var totH:Number = playerMain_mc.presentSizeH; // The heighth of the movie. Change this is movie changes.
	var newY:Number = 0;//new position of media once determined; se case statement below
	
	var pictH:Number = media_container.preferredHeight; //"pict" in this case refers to the video
	var pictW:Number = media_container.preferredWidth;
	var containerW:Number = media_container.width;
	var containerH:Number = media_container.height;
	
	var noteType:String = _parent.currentPage_xmlnode.attributes.nType; //used to determine relative size of page text if img centered
	var caption_head:String = _parent.currentPage_xmlnode.attributes.captionhead;
	var caption_text:String = _parent.currentPage_xmlnode.attributes.captiontext;
	
	switch (mediaPos.toLowerCase()) {
		case "center" :
			newY = ((totH-tMargin-pictH-gutter)/2 + ((pictH - containerH)/2))/2;
			newX = (totW-pictW)/2 + ((pictW - containerW)/2);
			page_txt._x = lMargin;
			page_txt._y = media_container._y - ((pictH - containerH)/2) +pictH+caption_txt._height+gutter;
			var newSizeW:Number = (pictHorizSpace-lMargin-rMargin);
			var newSizeH:Number = (totH - (newY - ((pictH - containerH)/2)) - pictH - caption_txt._height - gutter);
			if (caption_head == "" || caption_head == undefined) {
				if (caption_text == "" || caption_text == undefined){
					page_txt._y = page_txt._y - caption_txt._height;
					newSizeH = (newSizeH + caption_txt._height);
				}
			}
			if (noteType == "none") {
				newSizeH = (newSizeH + note_txt._height);
			}
			if (newSizeH < 42)newSizeH = 42;
			page_txt.setSize(int(newSizeW),int(newSizeH));
			break;
		case "left and center" :
			newY = (pictVertSpace-tMargin-pictH)/2 + ((pictH - containerH)/2);
			newX = lMargin + ((pictW - containerW)/2);
			page_txt._x = lMargin+gutter+pictW;
			//position page text to the right of the pic
			page_txt.setSize(totW-pictW-rMargin-lMargin-gutter,page_txt.height);
			break;
		case "left" :
			newX = lMargin + ((pictW - containerW)/2);
			newY = tMargin + gutter + ((pictH - containerH)/2);
			page_txt._x = lMargin+gutter+pictW;
			page_txt.setSize(totW-pictW-rMargin-lMargin-gutter,page_txt.height);
			break;
		case "right" :
			newX = (totW-rMargin-pictW) + ((pictW - containerW)/2); //the last addition of pixels is because the _x refers to the x pos of the container component before it is sized to fit the media
			newY = tMargin + gutter + ((pictH - containerH)/2);
			page_txt._x = lMargin;
			page_txt.setSize(totW-pictW-rMargin-lMargin-gutter,page_txt.height);
			break;
		case "right and center" :
			newX = (totW-rMargin-pictW) + ((pictW - containerW)/2);
			newY = (pictVertSpace-tMargin-pictH)/2 + ((pictH - containerH)/2);
			page_txt._x = lMargin;
			page_txt.setSize(totW-pictW-rMargin-lMargin-gutter,page_txt.height);
			break;
	}
	
	//position media based on new values
	media_container._x = newX
	media_container._y = newY
	
	//pWidth.text = pictW
	//pHeight.text = containerW
	
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
		var bl = media_container.bytesLoaded;
		//trace("loadperc = " + (loadPerc/100))
		var bt = media_container.bytesTotal * (loadPerc/100);
		if (bl > 4 && bt > 4 && bl >= bt)	// Loading is complete.
		{
			//trace("loading is complete")
			preLoader.unloadMovie();
			//media_container.play();
		}
		else
		{
			preLoader.middle._width = Math.round(bl / bt * middleWidthRemaining) + middlePrevWidth;
			preLoader.right._x = preLoader.middle._x + preLoader.middle._width;
			//media_container.pause();
			//media_container.autoPlay = false;
		}
}

media_container.addEventListener("progress", myProgressListener);
