/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	loading and linking an image.
*/

#include "loadimage.as"
//Loads the image that is displayed
function loadLinkImage(){
	var noteType:String = playerMain_mc.currentPage_xmlnode.attributes.nType; //used to determine relative size of page text if img centered
	var caption_head:String = playerMain_mc.currentPage_xmlnode.attributes.captionhead
	var caption_text:String = _parent.currentPage_xmlnode.attributes.captiontext;
	//Object to load image
	var picture_mcl:MovieClipLoader = new MovieClipLoader();
	var mclListener:Object = new Object();
	//When picture loads, position it.
	mclListener.onLoadInit = function(target_mc:MovieClip){
		//Adjust the size of the image
		adjustSize(target_mc._width,target_mc._height);
		
		//Load the URL
		var imgURL:String = playerMain_mc.currentPage_xmlnode.attributes.imageURL
		target_mc.onRelease = function() {
			//trace("Image Load FLA");
			var urlArray:Array = imgURL.split(":");
			if (urlArray[0].toLowerCase() == "asfunction") {
				var pageArray:Array = urlArray[1].split(",");
				if (pageArray[0].toLowerCase() == "gotopage") {
					//trace(pageArray[1]);
					goToPage(pageArray[1]);
				} else if (pageArray[0].toLowerCase() == "glossary"){
					glossary(pageArray[1]);
				}
			} else {
				if (imgURL.toLowerCase().indexOf("http:") == -1) {
					getURL("http:\\\\" + imgURL,"_blank"); 
				} else {
					getURL(imgURL,"_blank");
				}
			}
		}
	}
	picture_mcl.addListener(mclListener);

	//Get Image node
	var imgLoc:String = _parent.currentPage_xmlnode.attributes.imageFile
	if (imgLoc !== undefined){
		//Get JPEG file
		//var imgLoc:String = playerMain_mc.currentPage_xmlnode.attributes.imageFile
		//if (imgLoc !== undefined){
			picture_mcl.loadClip(imgLoc,image_mc);
			//picture_mcl.loadClip("swfs/templateswfs/image_load.swf",image_mc);//"swfs/templateswfs/image_load.swf"
		//}
		//Load and position caption
		var captionText:String = "";
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

	
	


