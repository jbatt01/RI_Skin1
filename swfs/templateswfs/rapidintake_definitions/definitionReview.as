﻿//Import Tween classesimport mx.transitions.Tween; import mx.transitions.easing.*;import com.greensock.*;import com.greensock.plugins.*;//tween lite pluginTweenPlugin.activate([TintPlugin]);//Set text area transparentdefinition_txt.setStyle("borderStyle","none");definition_txt.label.selectable=false;_global.styles.TextArea.setStyle("backgroundColor" , "transparent");//Hide definition backgrounddef_bkgrnd._visible = false;reviewInstruct.instruction_txt.html = true;// terms Color Settingprimarycolor = playerMain_mc.currentPage_xmlnode.attributes.termsColor;if (primarycolor.indexOf("0x") == -1) {	if (primarycolor.indexOf("#") != -1) { primarycolor = primarycolor.substr(1);  } //remove the #	else { primarycolor = "0099FF"; } //use default} else { 	if (primarycolor.length > 7) { primarycolor = primarycolor.substr(2); } //rip off 0x}///////////////////myMask///////////////////*myMask._height = playerMain_mc.presentSizeH;myMask._width = playerMain_mc.presentSizeW;myMask._x = 0;myMask._y = 0;myMask2._height = playerMain_mc.presentSizeH;myMask2._width = playerMain_mc.presentSizeW;myMask2._x = 0;myMask2._y = 0;myMask3._height = playerMain_mc.presentSizeH;myMask3._width = playerMain_mc.presentSizeW;myMask3._x = 0;myMask3._y = 0;myMask4._height = playerMain_mc.presentSizeH;myMask4._width = playerMain_mc.presentSizeW;myMask4._x = 0;myMask4._y = 0;myMask5._height = playerMain_mc.presentSizeH;myMask5._width = playerMain_mc.presentSizeW;myMask5._x = 0;myMask5._y = 0;myMask6._height = playerMain_mc.presentSizeH;myMask6._width = playerMain_mc.presentSizeW;myMask6._x = 0;myMask6._y = 0;myMask7._height = playerMain_mc.presentSizeH;myMask7._width = playerMain_mc.presentSizeW;myMask7._x = 0;myMask7._y = 0;term1.setMask (myMask);term2.setMask (myMask2);term3.setMask (myMask3);term4.setMask (myMask4);term5.setMask (myMask5);term6.setMask (myMask6);term7.setMask (myMask7);myMaskIns._height = playerMain_mc.presentSizeH;myMaskIns._width = playerMain_mc.presentSizeW;myMaskIns._x = 0;myMaskIns._y = 0;instructArea.setMask (reviewInstruct);*///////////////////End////////////////////////Setting primary color for term 1clrobj = term1.color_MC.colorPart;var myColor:Color = new Color(clrobj);newclr = primarycolor;newColor = "0x" + newclr.toString()myColor.setRGB(newColor);//Setting primary color for term 2clrobj2 = term2.color_MC.colorPart;var myColor2:Color = new Color(clrobj2);newclr2 = primarycolor;newColor2 = "0x" + newclr2.toString()myColor2.setRGB(newColor2);//Setting primary color for term 3clrobj3 = term3.color_MC.colorPart;var myColor3:Color = new Color(clrobj3);newclr3 = primarycolor;newColor3 = "0x" + newclr3.toString()myColor3.setRGB(newColor3);//Setting primary color for term 4clrobj4 = term4.color_MC.colorPart;var myColor4:Color = new Color(clrobj4);newclr4 = primarycolor;newColor4 = "0x" + newclr4.toString()myColor4.setRGB(newColor4);//Setting primary color for term 5clrobj5 = term5.color_MC.colorPart;var myColor5:Color = new Color(clrobj5);newclr5 = primarycolor;newColor5 = "0x" + newclr5.toString()myColor5.setRGB(newColor5);//Setting primary color for term 6clrobj6 = term6.color_MC.colorPart;var myColor6:Color = new Color(clrobj6);newclr6 = primarycolor;newColor6 = "0x" + newclr6.toString()myColor6.setRGB(newColor6);//Setting primary color for term 7clrobj7 = term7.color_MC.colorPart;var myColor7:Color = new Color(clrobj7);newclr7 = primarycolor;newColor7 = "0x" + newclr7.toString()myColor7.setRGB(newColor7);//Button colorsbuttonColorString = playerMain_mc.currentPage_xmlnode.attributes.buttonColor;buttonOverString = playerMain_mc.currentPage_xmlnode.attributes.bottonRoll;//Establish button colorsif(buttonColorString == "" || buttonColorString == null){	} else {	TweenLite.to(learn_btn.learnButton, 0, {tint:buttonColorString});}//Roll over statesif(buttonColorString == "" || buttonColorString == null){	learn_btn.onRollOut = function(){		this.gotoAndStop(1);	}} else {	//practice buttons	learn_btn.onRollOut = function(){		this.gotoAndStop(1);		TweenLite.to(learn_btn.learnButton, 0, {tint:buttonColorString});	}}if(buttonOverString == "" || buttonOverString == null){	learn_btn.onRollOver = function(){		this.gotoAndStop(2);	}} else{	learn_btn.onRollOver = function(){		this.gotoAndStop(2);		TweenLite.to(learn_btn.learnButtonOver, 0, {tint:buttonOverString});	}}//Continue Button//Establish Button Colorif(buttonColorString == "" || buttonColorString == null){	} else{	TweenLite.to(reviewInstruct.beginButton.continueBTN, 0, {tint:buttonColorString});}//Roll over statesif(buttonColorString == "" || buttonColorString == null){	reviewInstruct.beginButton.onRollOut = function(){		this.gotoAndStop(1);	}} else {	//practice buttons	reviewInstruct.beginButton.onRollOut = function(){		this.gotoAndStop(1);		TweenLite.to(reviewInstruct.beginButton.continueBTN, 0, {tint:buttonColorString});	}}if(buttonOverString == "" || buttonOverString == null){	reviewInstruct.beginButton.onRollOver = function(){		this.gotoAndStop(2);	}} else{	reviewInstruct.beginButton.onRollOver = function(){		this.gotoAndStop(2);		TweenLite.to(reviewInstruct.beginButton.continueRollBTN, 0, {tint:buttonOverString});	}}///////////////////Terms Color For Review///////////////////////////textcolorreview = playerMain_mc.currentPage_xmlnode.attributes.textreviewcolor;trace(textcolorreview);if (textcolorreview.indexOf("0x") == -1) {	if (textcolorreview.indexOf("#") != -1) { textcolorreview = textcolorreview.substr(1);  } //remove the #	else { textcolorreview = "FFFFFF"; } //use default} else { 	if (textcolorreview.length > 7) { textcolorreview = textcolorreview.substr(2); } //rip off 0x}//Setting text color for term 1textRclrobj = term1.term_txt;var textRmyColor:Color = new Color(textRclrobj);textRnewclr = textcolorreview;textRnewColor = "0x" + textRnewclr.toString()textRmyColor.setRGB(textRnewColor);//Setting text color for term 2textRclrobj2 = term2.term_txt;var textRmyColor2:Color = new Color(textRclrobj2);textRnewclr2 = textcolorreview;textRnewColor2 = "0x" + textRnewclr2.toString()textRmyColor2.setRGB(textRnewColor2);//Setting text color for term 3textRclrobj3 = term3.term_txt;var textRmyColor3:Color = new Color(textRclrobj3);textRnewclr3 = textcolorreview;textRnewColor3 = "0x" + textRnewclr3.toString()textRmyColor3.setRGB(textRnewColor3);//Setting text color for term 4textRclrobj4 = term4.term_txt;var textRmyColor4:Color = new Color(textRclrobj4);textRnewclr4 = textcolorreview;textRnewColor4 = "0x" + textRnewclr4.toString()textRmyColor4.setRGB(textRnewColor4);//Setting text color for term 5textRclrobj5 = term5.term_txt;var textRmyColor5:Color = new Color(textRclrobj5);textRnewclr5 = textcolorreview;textRnewColor5 = "0x" + textRnewclr5.toString()textRmyColor5.setRGB(textRnewColor5);//Setting text color for term 6textRclrobj6 = term6.term_txt;var textRmyColor6:Color = new Color(textRclrobj6);textRnewclr6 = textcolorreview;textRnewColor6 = "0x" + textRnewclr6.toString()textRmyColor6.setRGB(textRnewColor6);//Setting text color for term 7textRclrobj7 = term7.term_txt;var textRmyColor7:Color = new Color(textRclrobj7);textRnewclr7 = textcolorreview;textRnewColor7 = "0x" + textRnewclr7.toString()textRmyColor7.setRGB(textRnewColor7);////////////////////////////End//////////////////////////////////////Instructions helpIconReview._x = 5;helpIconReview._y = playerMain_mc.presentSizeH - helpIconReview._height - 5;reviewInstruct._x = playerMain_mc.presentSizeW + 50;reviewInstruct._y = playerMain_mc.presentSizeH/2 - reviewInstruct._height/2;	//Hide feedbackcorrect_mc._visible = false;incorrect_mc._visible = false;var feedbackID:Number;TweenLite.to(term1, 1, {_x:10});TweenLite.to(term2, 1.3, {_x:10});TweenLite.to(term3, 1.6, {_x:10});TweenLite.to(term4, 1.9, {_x:10});TweenLite.to(term5, 2.2, {_x:10});TweenLite.to(term6, 2.5, {_x:10});TweenLite.to(term7, 2.8, {_x:10});//Help IconhelpIconReview.onPress = function(){	fader._visible = true;	TweenLite.to(fader, .5, {_alpha:50, onComplete:scrollInReviewHelp});}var xInstructions:Number;xInstructions = playerMain_mc.presentSizeW/2 - reviewInstruct._width/2;function scrollInReviewHelp(){	TweenLite.to(reviewInstruct, 1, {_x:xInstructions});	if(buttonColorString == "" || buttonColorString == null){		} else{		reviewInstruct.beginButton.gotoAndStop(1);		TweenLite.to(reviewInstruct.beginButton.continueBTN, 0, {tint:buttonColorString});	}}reviewInstruct.beginButton.onPress = function(){		TweenLite.to(reviewInstruct, .5, {_x:playerMain_mc.presentSizeW + 50,  onComplete:scrollOutReviewHelp});	TweenLite.to(fader, .5, {_alpha:0});	}function scrollOutReviewHelp(){		fader._visible = false;}//var incorrect_feedback:String = "Sorry, that is incorrect.";//var correct_feedback:String = "That is the correct term and definition.";//Set size of text fieldvar totalSpace:Number;var topMargin:Number = 10;var bottomMargin:Number = 10;if (playerMain_mc.presentSizeH < 485){	//instruction_txt._height = 45;	//instruction_txt._width = playerMain_mc.presentSizeW - 6;	instruction_txt.setSize(playerMain_mc.presentSizeW - 180,45)	var targetSize:Number = 45;	var dragStart:Number = 10;	var startX:Number = Math.round(dragStart + term1._width + 30);}else{	//instruction_txt._height = 75;	//instruction_txt._width = playerMain_mc.presentSizeW - 6;	instruction_txt.setSize(playerMain_mc.presentSizeW - 180,75)	var targetSize:Number = 75;	var dragStart:Number = -219;	var startX:Number = Math.round(dragStart + term1._width + 250);}totalSpace = playerMain_mc.presentSizeH - instruction_txt._height - topMargin - bottomMargin - term1._height - learn_btn._height - 10;var startY:Number = topMargin;//var startY:Number = instruction_txt._height + topMargin;var targetWidth:Number = playerMain_mc.presentSizeW - startX - 10;//For page complete functionallityvar termsTotal:Number = 0;var termsCorrect:Array = new Array();//Review button positioninglearn_btn._y = playerMain_mc.presentSizeH - learn_btn._height - 2;learn_btn._x = playerMain_mc.presentSizeW - 15 - learn_btn._width;//		/*question_count_txt.styleSheet = playerMain_mc.quizCSS;		question_count_txt.html = true;		question_count_txt.htmlText = "<p class = 'questioncount'>Question " + current_question + " of " + num_questions + "</p>";*/function update_dragdrop(){		//update instructions	var thePage_xmlnode:XMLNode = playerMain_mc.currentPage_xmlnode;	var instructionText_xmlnode:XMLNode = matchSiblingNode(thePage_xmlnode.firstChild, "instructionTextDD");		var titleText:String = playerMain_mc.currentPage_xmlnode.attributes.title;	if (titleText !== undefined && !playerMain_mc.showPageTitle) {		if (playerMain_mc.presentSizeH < 485)		{			titleStr = "<p class = 'h2'>" +  titleText + " - Practice" + "</p>";		} else {			titleStr = "<p class = 'h2'>" +  titleText + " - Practice" + "</p><br>";		}	} else {		titleStr = "";	}	trace("titleStr: " + titleStr)	reviewInstruct.instruction_txt.styleSheet = defCSS;	reviewInstruct.instruction_txt.html = true;	reviewInstruct.instruction_txt.text = "<body>" + titleStr + "<p class = 'pageText'>" + instructionText_xmlnode.firstChild.nodeValue + "</p></body>";	//Update Term Objects	var definitions_xmlnode:XMLNode = matchSiblingNode(thePage_xmlnode.firstChild, "definitionsText");	if (definitions_xmlnode != null) {		var random_array:Array = new Array(); //Array of responses		var next_def_xmlnode:XMLNode = definitions_xmlnode.firstChild;		var def_array:Array = definitions_xmlnode.childNodes;		var defNum:Number = def_array.length;		//for page complete functionallity		termsTotal = defNum;			if (defNum > 1) defNum = defNum -1;		var defSpacing = Math.round(totalSpace/defNum);		if (defNum < 2) defSpacing = 80;		//Added code for each spacing to happen		if (defNum == 2) defSpacing = 140;		if (defNum == 3) defSpacing = 118;		if (defNum == 4) defSpacing = 88;		if (defNum ==5) defSpacing = 72;		if (defNum >=6) defSpacing = 65;		for (var i = 1;i < 8;i++){			if (next_def_xmlnode != null) {				//Postion Term				this["term"+i]._y = startY + (defSpacing * (i-1));				this["term"+i]._x = dragStart;				//Postion Target				this["target"+i]._y = startY + (defSpacing * (i-1));				this["target"+i]._x = startX;				this["target"+i].target_txt.setSize(targetWidth,targetSize);				this["target"+i].def_bkgnd_mc._width = targetWidth + 7;				this["target"+i].def_bkgnd_mc._height = targetSize + 5;//trace("height: " + this["target"+i].target_txt.height)				this["target"+i].targetImage_mc._height = targetSize;				//this["target"+i]._height = targetSize;				//Style Target		//trace("targetSize: " + targetSize)				this["term"+i]._visible = true;				//this["term" + i].definition = next_def_xmlnode.firstChild.nodeValue;				//this["term" + i].term_txt.styleSheet = defCSS;				this["term" + i].term_txt.html = true;				this["term" + i].term_txt.htmlText = "<p class = 'term'>" + next_def_xmlnode.attributes.term + "</p>";				this["term" + i].cleanTerm = next_def_xmlnode.attributes.term;				this["term" + i].onPress = doDrag;				this["term" + i].onRelease = checkDrag;				this["term" + i].onReleaseOutside = checkDrag;				next_def_xmlnode.attributes.termNum = ["term" + i];				random_array[i-1] = next_def_xmlnode 			} else {				this["term"+i]._visible = false;				this["target"+i]._visible = false;			}			next_def_xmlnode = next_def_xmlnode.nextSibling;		}		//Set up targets		var arrayL:Number = random_array.length;		for (var j:Number = 1;j <= arrayL;j++){			var new_num:Number = randRange(0,(random_array.length - 1))			var tempArray:Array = random_array.splice(new_num,1);			var response_xmlnode:XMLNode = tempArray[0];			//Assign Values			this["target"+j].target_txt.styleSheet = defCSS;			this["target"+j].target_txt.html = true;			this["target" + j].target_txt.text = "<p class = 'target'>" + response_xmlnode.firstChild.nodeValue + "</p>";			this["target" + j].dragNum = response_xmlnode.attributes.termNum;			this["target" + j].cleanText = response_xmlnode.firstChild.nodeValue;		}	}}function doDrag(){	this.startDrag();	this.startY = this._y;	this.startX = this._x;}function checkDrag() {	this.stopDrag();	var targetName:String = eval(this._droptarget)._name;	if (targetName == "targetImage_mc") targetName = eval(this._droptarget)._parent._name;//trace("term dropped on: " + targetName)	var targetObj:Object = playerMain_mc.presentation[targetName];	var targetNum = targetObj.dragNum;//trace("targetNum: " + targetNum)	if (targetNum.toString() == this._name.toString()){				//targetObj.target_txt.html = true;		targetObj.target_txt.text = "<p class = 'targetCorrect'>" + this.cleanTerm + ": " + targetObj.cleanText + "</p>";						//this._visible = false;		var scopeOfClass = this;		//Fade it out if correct.		var hideIt = new Tween(this,"_alpha",Regular.easeIn,100,0,0.5,true);		hideIt.onMotionFinished = function() 		{			scopeOfClass._visible = false;			targetObj.target_txt.setStyle( "color", 0x006600 );			targetObj.correct = true;		};		//Show feedback		//correct_mc._visible = true;		//feedbackID = setInterval(hideFeedback,1000)		//feedback_txt.text = correct_feedback;		//trace("item is correct");		for (var h:Number = 1;h<6;h++){			//trace(playerMain_mc.presentation["target" + h].correct)			if (!playerMain_mc.presentation["target" + h].correct){				playerMain_mc.presentation["target" + h].target_txt.setStyle( "color", 0x0B333C );			}		}		//For page complete functionallity		var usePageComplete:Boolean = playerMain_mc.root_xmlnode.attributes.pageComplete.toLowerCase() == "true";		if (usePageComplete)		{			//trace(targetNum)			//trace(targetNum.toString().substr(-1))			var myPicNum:Number = Number(targetNum.toString().substr(-1));			//trace(myPicNum)			termsCorrect[myPicNum-1] = true;			//trace("legnth: " + imagesClicked.length)			var allClicked:Boolean = true;			for (var i:Number = 0;i < termsCorrect.length;i++)			{				if(!termsCorrect[i]) allClicked = false			}			trace(allClicked + " - " + termsCorrect.length)			if(allClicked && termsCorrect.length == termsTotal)			{				playerMain_mc.apiPageComplete();			}		}	} else {		targetObj.target_txt.text = "<p class = 'targetWrong'>" + targetObj.cleanText + "</p>";		//incorrect_mc._visible = true;		//feedbackID = setInterval(hideFeedback,1000)		//feedback_txt.text = incorrect_feedback;		//trace("not correct");		//Move back		var moveBack = new Tween(this,"_y",Strong.easeOut,this._y,this.startY,1,true);		var moveBack = new Tween(this,"_x",Strong.easeOut,this._x,this.startX,1,true);	}}/*function hideFeedback(){	clearInterval(feedbackID);	incorrect_mc._visible = false;	correct_mc._visible = false;}*///generates random numberfunction randRange(min:Number, max:Number):Number {  var randomNum:Number = Math.round(Math.random()*(max-min))+min;  return randomNum;}function goToLearn(){	gotoAndStop("learn");}//learn_btn.addEventListener("click", goToLearn);learn_btn.onRelease = function() {	goToLearn();}//Call functionupdate_dragdrop();