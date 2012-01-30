//******************************************************************
//Flashform Version 3.
//*******************************************************************

//Code for tab control
//Code for tab control of media controller buttons is contained the media controller Flash file.
//playerMain_mc.heading_txt.tabIndex = 1;
playerMain_mc.index_read_mc.tabIndex = 2;
playerMain_mc.glossary_btn.tabIndex = 3;
playerMain_mc.exit_btn.tabIndex = 4;
playerMain_mc.audio_onoff.tabIndex = 5;
playerMain_mc.back_mc.tabIndex = 6;
playerMain_mc.next_mc.tabIndex = 7;
//Implment Tab Control for buttons
/*playerMain_mc.controller_mc.tabChildren =true;
playerMain_mc.controller_mc.tabEnabled = false;
playerMain_mc.controller_mc.play_mc.tabIndex = 8;
playerMain_mc.controller_mc.rewind_mc.tabIndex = 9;*/
//focusManager.setFocus(index_btn);

//Keyboard shortcuts
function myOnKeyDown(){
	//trace(Key.getCode());
	var ctrlDown:Boolean = Key.isDown(Key.CONTROL);
	var keyPressed:Number = Key.getCode();
	//trace(ctrlDown + " : " + keyPressed);
	if (ctrlDown){
		switch (keyPressed){
			case 188://, character
				Selection.setFocus(audio_onoff_mc);
				audio_onoff_mc.onRelease();
				break;
			case 221://] character
				Selection.setFocus(glossary_btn);
				glossary_btn.onRelease();
				break;
			case 219://[ character
				Selection.setFocus(index_read_mc);
				index_read_mc.onRelease();
				break;
			case 190://. character
				Selection.setFocus(exit_btn);
				exit_btn.onRelease();
				break;
			case 186://; character (media controller)
				if (currentPage_xmlnode.attributes.loadPercentage != 0){
					Selection.setFocus(controller_mc.play_mc);
					controller_mc.play_mc.onPress();
					controller_mc.play_mc.onRelease();
					break;
				}
			case 222://' character (media controller)
				if (currentPage_xmlnode.attributes.loadPercentage != 0) {
					Selection.setFocus(controller_mc.rewind_mc);
					controller_mc.rewind_mc.onPress();
					controller_mc.rewind_mc.onRelease();
					break;
				}
			case 220://\ character (close button for glossary)
				if (glossary_mc.close_btn){
					glossary_mc.close_glossary();
					break;
				}
			case 187://equal
				if (lastPage_xmlnode != currentPage_xmlnode){
					//Selection.setFocus(next_mc)
					next_mc.onRelease();
				}
				break;
			case 189://hyphen
				if (firstPage_xmlnode != currentPage_xmlnode) {
					//Selection.setFocus(back_mc)
					back_mc.onRelease();
				}
				break;
			case 48://0
				Selection.setFocus(presentation)
				break;
			/*default:
				trace(keyPressed);*/
		}
	} else {
		/*switch (keyPressed){
			case 39://Right Arrow
				if (lastPage_xmlnode != currentPage_xmlnode){
					//Selection.setFocus(next_mc)
					next_mc.onRelease();
				}
				break;
			case 37://Left Arrow
				if (firstPage_xmlnode != currentPage_xmlnode) {
					//Selection.setFocus(back_mc)
					back_mc.onRelease();
				}
				break;
		}*/
	}
}

var myListener = new Object();
myListener.onKeyDown  = myOnKeyDown;
Key.addListener(myListener);

playerMain_mc.indexName_mc._accProps = new Object();
playerMain_mc.indexName_mc._accProps.silent = true;
playerMain_mc.heading_txt._accProps = new Object();
playerMain_mc.heading_txt._accProps.silent = true;
playerMain_mc._accProps = new Object();
playerMain_mc._accProps.name = root_xmlnode.attributes.title;
playerMain_mc.index_read_mc._accProps = new Object();
playerMain_mc.index_read_mc._accProps.name = "Narration";
playerMain_mc.exit_btn._accProps = new Object();
playerMain_mc.exit_btn._accProps.name = "exit";
playerMain_mc.audio_onoff_mc._accProps = new Object();
playerMain_mc.audio_onoff_mc._accProps.name = "audio";
playerMain_mc.glossary_btn._accProps = new Object();
playerMain_mc.glossary_btn._accProps.name = "glossary";
playerMain_mc.back_mc._accProps = new Object();
playerMain_mc.back_mc._accProps.name = "previous";
playerMain_mc.next_mc._accProps = new Object();
playerMain_mc.next_mc._accProps.name = "next";
playerMain_mc.presentation._accProps = new Object();
playerMain_mc.presentation._accProps.name = "Content";
Accessibility.updateProperties();