﻿//Set text area transparentdefinition_txt.setStyle("borderStyle","none");definition_txt.label.selectable=false;_global.styles.TextArea.setStyle("backgroundColor" , "transparent");_global.styles.TextArea.setStyle("borderStyle" , "none");import com.greensock.*;import com.greensock.plugins.*;//tween lite pluginTweenPlugin.activate([TintPlugin]);instructArea.instruction_txt.html = true;//Variablesvar topMargin:Number = 5;//Show definition backgrounddef_bkgrnd._visible = false;/*if (firstAttempt) {	update_mouseover();} else {	firstAttempt = true;	setStartPosition();	update_mouseover();}*///Button colorsbuttonColorString = playerMain_mc.currentPage_xmlnode.attributes.buttonColor;buttonOverString = playerMain_mc.currentPage_xmlnode.attributes.bottonRoll;//Establish button colorif(buttonColorString == "" || buttonColorString == null){	} else {	TweenLite.to(practice_btn.practBTN, 0, {tint:buttonColorString});}//Roll over statesif(buttonColorString == "" || buttonColorString == null){	practice_btn.onRollOut = function(){		this.gotoAndStop(1);	}} else {	//practice buttons	practice_btn.onRollOut = function(){		this.gotoAndStop(1);		TweenLite.to(practice_btn.practBTN, 0, {tint:buttonColorString});	}}if(buttonOverString == "" || buttonOverString == null){	practice_btn.onRollOver = function(){		this.gotoAndStop(2);	}} else{	practice_btn.onRollOver = function(){		this.gotoAndStop(2);		TweenLite.to(practice_btn.practRoll, 0, {tint:buttonOverString});	}}//Establish button colorif(buttonColorString == "" || buttonColorString == null){	} else {	TweenLite.to(instructArea.beginButton.beginBTN, 0, {tint:buttonColorString});}//Begin Buttonif(buttonColorString == "" || buttonColorString == null){	instructArea.beginButton.onRollOut = function(){		this.gotoAndStop(1);	}} else {	//practice buttons	instructArea.beginButton.onRollOut = function(){		this.gotoAndStop(1);		TweenLite.to(instructArea.beginButton.beginBTN, 0, {tint:buttonColorString});	}}if(buttonOverString == "" || buttonOverString == null){	instructArea.beginButton.onRollOver = function(){		this.gotoAndStop(2);	}} else{	instructArea.beginButton.onRollOver = function(){		this.gotoAndStop(2);		TweenLite.to(instructArea.beginButton.beginRollBTN, 0, {tint:buttonOverString});	}}/*fader._height = playerMain_mc.presentSizeH + 30;fader._width = playerMain_mc.presentSizeW + 20;*/fader._height = playerMain_mc.presentSizeH;fader._width = playerMain_mc.presentSizeW;///////////////////myMask///////////////////*myMask._height = playerMain_mc.presentSizeH;myMask._width = playerMain_mc.presentSizeW;myMask._x = 0;myMask._y = 0;myMask2._height = playerMain_mc.presentSizeH;myMask2._width = playerMain_mc.presentSizeW;myMask2._x = 0;myMask2._y = 0;myMask3._height = playerMain_mc.presentSizeH;myMask3._width = playerMain_mc.presentSizeW;myMask3._x = 0;myMask3._y = 0;myMask4._height = playerMain_mc.presentSizeH;myMask4._width = playerMain_mc.presentSizeW;myMask4._x = 0;myMask4._y = 0;myMask5._height = playerMain_mc.presentSizeH;myMask5._width = playerMain_mc.presentSizeW;myMask5._x = 0;myMask5._y = 0;myMask6._height = playerMain_mc.presentSizeH;myMask6._width = playerMain_mc.presentSizeW;myMask6._x = 0;myMask6._y = 0;myMask7._height = playerMain_mc.presentSizeH;myMask7._width = playerMain_mc.presentSizeW;myMask7._x = 0;myMask7._y = 0;Lterm1.setMask (myMask);Lterm2.setMask (myMask2);Lterm3.setMask (myMask3);Lterm4.setMask (myMask4);Lterm5.setMask (myMask5);Lterm6.setMask (myMask6);Lterm7.setMask (myMask7);myMaskIns._height = playerMain_mc.presentSizeH;myMaskIns._width = playerMain_mc.presentSizeW;myMaskIns._x = 0;myMaskIns._y = 0;instructArea.setMask (myMaskIns);*///////////////////End///////////////////////*fader._x = -20;fader._y = -20;*/// terms Color Settingprimarycolor = playerMain_mc.currentPage_xmlnode.attributes.termsColor;trace(primarycolor);if (primarycolor.indexOf("0x") == -1) {	if (primarycolor.indexOf("#") != -1) { primarycolor = primarycolor.substr(1);  } //remove the #	else { primarycolor = "0099FF"; } //use default} else { 	if (primarycolor.length > 7) { primarycolor = primarycolor.substr(2); } //rip off 0x}//Setting primary color for term 1clrobj = Lterm1.color_MC;var myColor:Color = new Color(clrobj);newclr = primarycolor;newColor = "0x" + newclr.toString()myColor.setRGB(newColor);//Setting primary color for term 2clrobj2 = Lterm2.color_MC;var myColor2:Color = new Color(clrobj2);newclr2 = primarycolor;newColor2 = "0x" + newclr2.toString()myColor2.setRGB(newColor2);//Setting primary color for term 3clrobj3 = Lterm3.color_MC;var myColor3:Color = new Color(clrobj3);newclr3 = primarycolor;newColor3 = "0x" + newclr3.toString()myColor3.setRGB(newColor3);//Setting primary color for term 4clrobj4 = Lterm4.color_MC;var myColor4:Color = new Color(clrobj4);newclr4 = primarycolor;newColor4 = "0x" + newclr4.toString()myColor4.setRGB(newColor4);//Setting primary color for term 5clrobj5 = Lterm5.color_MC;var myColor5:Color = new Color(clrobj5);newclr5 = primarycolor;newColor5 = "0x" + newclr5.toString()myColor5.setRGB(newColor5);//Setting primary color for term 6clrobj6 = Lterm6.color_MC;var myColor6:Color = new Color(clrobj6);newclr6 = primarycolor;newColor6 = "0x" + newclr6.toString()myColor6.setRGB(newColor6);//Setting primary color for term 7clrobj7 = Lterm7.color_MC;var myColor7:Color = new Color(clrobj7);newclr7 = primarycolor;newColor7 = "0x" + newclr7.toString()myColor7.setRGB(newColor7);// Roll over colorrollcolor = playerMain_mc.currentPage_xmlnode.attributes.rollverColor;if (rollcolor.indexOf("0x") == -1) {	if (rollcolor.indexOf("#") != -1) { rollcolor = rollcolor.substr(1);  } //remove the #	else { rollcolor = "FF9900"; } //use default} else { 	if (rollcolor.length > 7) { rollcolor = rollcolor.substr(2); } //rip off 0x}//Setting rollover for term 1rollclrobj = Lterm1.rollOverTerm;var rollmyColor:Color = new Color(rollclrobj);rollnewclr = rollcolor;rollnewColor = "0x" + rollnewclr.toString()rollmyColor.setRGB(rollnewColor);//Setting rollover for term 2rollclrobj2 = Lterm2.rollOverTerm;var rollmyColor2:Color = new Color(rollclrobj2);rollnewclr2 = rollcolor;rollnewColor2 = "0x" + rollnewclr2.toString()rollmyColor2.setRGB(rollnewColor2);//Setting rollover for term 3rollclrobj3 = Lterm3.rollOverTerm;var rollmyColor3:Color = new Color(rollclrobj3);rollnewclr3 = rollcolor;rollnewColor3 = "0x" + rollnewclr3.toString()rollmyColor3.setRGB(rollnewColor3);//Setting rollover for term 4rollclrobj4 = Lterm4.rollOverTerm;var rollmyColor4:Color = new Color(rollclrobj4);rollnewclr4 = rollcolor;rollnewColor4 = "0x" + rollnewclr4.toString()rollmyColor4.setRGB(rollnewColor4);//Setting rollover for term 5rollclrobj5 = Lterm5.rollOverTerm;var rollmyColor5:Color = new Color(rollclrobj5);rollnewclr5 = rollcolor;rollnewColor5 = "0x" + rollnewclr5.toString()rollmyColor5.setRGB(rollnewColor5);//Setting rollover for term 6rollclrobj6 = Lterm6.rollOverTerm;var rollmyColor6:Color = new Color(rollclrobj6);rollnewclr6 = rollcolor;rollnewColor6 = "0x" + rollnewclr6.toString()rollmyColor6.setRGB(rollnewColor6);//Setting rollover for term 7rollclrobj7 = Lterm7.rollOverTerm;var rollmyColor7:Color = new Color(rollclrobj7);rollnewclr7 = rollcolor;rollnewColor7 = "0x" + rollnewclr7.toString()rollmyColor7.setRGB(rollnewColor7);////////////////// Setting text color //////////////////////////textcolor = playerMain_mc.currentPage_xmlnode.attributes.textcolor;trace(textcolor);if (textcolor.indexOf("0x") == -1) {	if (textcolor.indexOf("#") != -1) { textcolor = textcolor.substr(1);  } //remove the #	else { textcolor = "FFFFFF"; } //use default} else { 	if (textcolor.length > 7) { textcolor = textcolor.substr(2); } //rip off 0x}//Setting text color for term 1textclrobj = Lterm1.term_txt;var textmyColor:Color = new Color(textclrobj);textnewclr = textcolor;textnewColor = "0x" + textnewclr.toString()textmyColor.setRGB(textnewColor);//Setting text color for term 2textclrobj2 = Lterm2.term_txt;var textmyColor2:Color = new Color(textclrobj2);textnewclr2 = textcolor;textnewColor2 = "0x" + textnewclr2.toString()textmyColor2.setRGB(textnewColor2);//Setting text color for term 3textclrobj3 = Lterm3.term_txt;var textmyColor3:Color = new Color(textclrobj3);textnewclr3 = textcolor;textnewColor3 = "0x" + textnewclr3.toString()textmyColor3.setRGB(textnewColor3);//Setting text color for term 4textclrobj4 = Lterm4.term_txt;var textmyColor4:Color = new Color(textclrobj4);textnewclr4 = textcolor;textnewColor4 = "0x" + textnewclr4.toString()textmyColor4.setRGB(textnewColor4);//Setting text color for term 5textclrobj5 = Lterm5.term_txt;var textmyColor5:Color = new Color(textclrobj5);textnewclr5 = textcolor;textnewColor5 = "0x" + textnewclr5.toString()textmyColor5.setRGB(textnewColor5);//Setting text color for term 6textclrobj6 = Lterm6.term_txt;var textmyColor6:Color = new Color(textclrobj6);textnewclr6 = textcolor;textnewColor6 = "0x" + textnewclr6.toString()textmyColor6.setRGB(textnewColor6);//Setting text color for term 7textclrobj7 = Lterm7.term_txt;var textmyColor7:Color = new Color(textclrobj7);textnewclr7 = textcolor;textnewColor7 = "0x" + textnewclr7.toString()textmyColor7.setRGB(textnewColor7);//////////////////End/////////////////////////////////////////Starting defBackdefBack._y = topMargin + 15;defBack._x = playerMain_mc.presentSizeW/2 - 20;definition_txt._x = defBack._x + 5;defHead_txt._x = definition_txt._x + 5;defHead_txt._y = defBack._y + 15;instructArea._x = playerMain_mc.presentSizeW + 50;instructArea._y = playerMain_mc.presentSizeH/2 - instructArea._height/2;//Fading intstructions helpIcon._x = 20;helpIcon._y = playerMain_mc.presentSizeH - helpIcon._height - 10;//defBack._y = intBack._height + 7;var defCSS = new TextField.StyleSheet();defCSS.load("swfs/templateswfs/template_styles.css");//Load the style sheet.defCSS.onLoad = function(ok) {	if (!ok) {//Did the style load OK? If it doesn't load, no data loads.		trace("Error loading CSS file.");	}	update_mouseover();	defHead_txt.styleSheet = defCSS;	defHead_txt.html = true;}function update_mouseover(){	//Set size of text field	var totalSpace:Number;	var bottomMargin:Number = 10;	if (playerMain_mc.presentSizeH < 485)	{		//instruction_txt._height = 45;		//instruction_txt._width = playerMain_mc.presentSizeW - 6;		//instruction_txt.setSize(playerMain_mc.presentSizeW - 180,45)		//intBack._width = playerMain_mc.presentSizeW - 7;		//intBack._height = instruction_txt._height + 2;	}	else	{		//instruction_txt._height = 90;		//instruction_txt._width = playerMain_mc.presentSizeW - 6;		//instruction_txt.setSize(playerMain_mc.presentSizeW - 180,90)		//intBack._width = playerMain_mc.presentSizeW - 7;		//intBack._height = instruction_txt._height + 2;	}	totalSpace = playerMain_mc.presentSizeH - topMargin - bottomMargin - Lterm1._height;	//totalSpace = playerMain_mc.presentSizeH - instruction_txt._height - topMargin - bottomMargin - Lterm1._height;	//var startY:Number = instruction_txt._height + 1;		var xInstructions:Number;	xInstructions = playerMain_mc.presentSizeW/2 - instructArea._width/2;		if(firstLaunch){		fader._alpha = 0;		TweenLite.to(fader, 1, {_alpha:50, onComplete:scrollInInstr});		firstLaunch = false;		faderVisi();	}		function scrollInInstr(){		TweenLite.to(instructArea, .8, {_x:xInstructions});		if(buttonColorString == "" || buttonColorString == null){			} else {			instructArea.beginButton.gotoAndStop(1);			TweenLite.to(instructArea.beginButton.beginBTN, 0, {tint:buttonColorString});		}	}		instructArea.beginButton.onPress = function(){		TweenLite.to(instructArea, .8, {_x:playerMain_mc.presentSizeW + 50});		TweenLite.to(fader, .5, {_alpha:0, onComplete:faderNotVisi});	}		function faderNotVisi(){		fader._visible = false;	}		function faderVisi(){		fader._visible = true;	}		helpIcon.onPress = function(){		fader._visible = true;		TweenLite.to(fader, .5, {_alpha:50, onComplete:scrollInInstr});	}		fader.onPress = function (){			}			//StartY	var startY:Number = defBack._y + 10;	trace(startY);	//definition fields	//defBack._x = playerMain_mc.presentSizeW - definition_txt.width - 30;		//Tween in the buttons	var tweenTermTo:Number;	tweenTermTo = defBack._x - 270;	TweenLite.to(Lterm1, 1, {_x:tweenTermTo});	TweenLite.to(Lterm2, 1.3, {_x:tweenTermTo});	TweenLite.to(Lterm3, 1.6, {_x:tweenTermTo});	TweenLite.to(Lterm4, 1.9, {_x:tweenTermTo});	TweenLite.to(Lterm5, 2.2, {_x:tweenTermTo});	TweenLite.to(Lterm6, 2.5, {_x:tweenTermTo});	TweenLite.to(Lterm7, 2.8, {_x:tweenTermTo});	//definition text background	def_bkgrnd._x = playerMain_mc.presentSizeW - definition_txt.width - 20;	if(playerMain_mc.presentSizeH < 400) definition_txt.height = 200;	//defHead_txt._y = topMargin + 2;	//defHead_txt._y = topMargin + instruction_txt._height + 2;	definition_txt._y = defHead_txt._y + 10 + defHead_txt._height;	//definition text background	def_bkgrnd._y = defHead_txt._y + defHead_txt._height;	//width for definition background graphic	def_bkgrnd._width = definition_txt.width + 5;		//Changing Y of Def Back		//trace(defHead_txt._y + " - " + defHead_txt._height + " - ");//trace(defHead_txt._height)	//Review button		practice_btn._y = playerMain_mc.presentSizeH - practice_btn._height - 2;	practice_btn._x = playerMain_mc.presentSizeW - 15 - practice_btn._width;//trace("practice: " + practice_btn._y + " - " + practice_btn._x + " - " + practice_btn._visible)	//update instructions	var thePage_xmlnode:XMLNode = playerMain_mc.currentPage_xmlnode;	var instructionText_xmlnode:XMLNode = matchSiblingNode(thePage_xmlnode.firstChild, "instructionText");		var titleText:String = playerMain_mc.currentPage_xmlnode.attributes.title;	if (titleText !== undefined && !playerMain_mc.showPageTitle) {		if (playerMain_mc.presentSizeH < 485)		{			titleStr = "<p class = 'h2'>" +  titleText + " - Learn" + "</p>";		} else {			titleStr = "<p class = 'h2'>" +  titleText + " - Learn" + "</p><br>";		}	} else {		titleStr = "";	}		//instruction_txt.html = true;	instructArea.instruction_txt.htmlText = "<body>" + titleStr + "<p class = 'pageText'>" + instructionText_xmlnode.firstChild.nodeValue + "</p></body>";	instructArea.instruction_txt.styleSheet = defCSS;	//Style definintion text	definition_txt.styleSheet = defCSS;		//Update Term Objects	var definitions_xmlnode:XMLNode = matchSiblingNode(thePage_xmlnode.firstChild, "definitionsText");	var def_array:Array = definitions_xmlnode.childNodes;	var defNum:Number = def_array.length;	if (defNum > 1) defNum = defNum -1;	//var defSpacing = Math.round(totalSpace/defNum);	var defSpacing = Math.round(defBack._height/defNum);	if (defNum < 2) defSpacing = 140;	//Added code for each spacing to happen	if (defNum == 2) defSpacing = 140;	if (defNum == 3) defSpacing = 118;	if (defNum == 4) defSpacing = 88;	if (defNum ==5) defSpacing = 72;	if (defNum >=6) defSpacing = 60;	//trace("number: " + def_array.length)	if (definitions_xmlnode != null) {		var next_def_xmlnode:XMLNode = definitions_xmlnode.firstChild;		for (var i = 1;i < 8;i++){			if (next_def_xmlnode != null) {				this["Lterm"+i]._y = startY + (defSpacing * (i-1));				this["Lterm"+i]._visible = true;				this["Lterm"+i]._alpha = 100;				if(this["Lterm"+i].origX) 					this["Lterm"+i]._x = this["Lterm"+i].origX;				else					this["Lterm"+i].origX = this["Lterm"+i]._x;				this["Lterm" + i].definition = next_def_xmlnode.firstChild.nodeValue;				this["Lterm" + i].term_txt.styleSheet = defCSS;				this["Lterm" + i].term_txt.html = true;				this["Lterm" + i].term_txt.htmlText = "<p class = 'term'>" + next_def_xmlnode.attributes.term + "</p>";				this["Lterm" + i].onRollOver = showDef;				this["Lterm" + i].onRollOut = function() {					//definition_txt.text = "";				}			} else {				this["Lterm"+i]._visible = false;			}			next_def_xmlnode = next_def_xmlnode.nextSibling;		}	}}trace(Lterm1._y);/*function setStartPosition(){	for (var g = 1;g < 8;g++){		this["term"+g].origX = this["term"+g]._x;		this["term"+g].origY = this["term"+g]._y;	}}*/function display_def(targetObj:Object){	definition_txt.html = true;	definition_txt.text = "<p class = 'definition'>" + targetObj.definition + "</p>";}function showDef() {	display_def(this);	this.gotoAndStop(2);}function goToReview(){	gotoAndStop("review");}//practice_btn.addEventListener("click", goToReview);practice_btn.onRelease = function() {	goToReview();}