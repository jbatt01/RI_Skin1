/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications made to this page for version 1.3:
		- Updated createToc and createTopic so it checks to see if page should be a part of index or not.
		- Update tocSetSelection so it would not highlight pages that were hidden from index.
		- Added lastPageClip variable in order to give a movie clip attribute to hidden pages.
		- Added autoScroll feature, so that when navigating with next button and back buttons the index will scroll so topic is visible.
		- Added code so highlight would automatically resize.
		- Changed references to main timeline with Global variable.
		- Added a blank movie clip to the bottom of the index, so that the last topic is not hidden.
	Modifications made to code for version 1.3.5:
		- Multiple modifications made to correct navigation restriction so you can restrict subtopics:
			* Added page_activated and nextNavTopic global variables.
			* Updated or changed these functions: make_selectable, makeNextSelectable, topicComplete, and createTopic.
			* Added new functions: topicPageComplete, nextNavTopic and isNavNextTopic.
		- Changed how check mark is added to pages so completion can be determined using apiPageComplete if necessary.
	Modificatons made to code for version 2.2 Interim release:
		- Added the ability to include quiz questions as a part of the total page count.
		- Fixed page numbering bug.
		- Added the ability to show navigation buttons if necessary.
	Modifications made to code for version 3 release:
		- Fixed issues with restricted navigation.
		- Fixed tooltip issue.
*/
// Global variables
var nLayer:Number = 1;      // the layer for each item used to display the TOC
var nX:Number = 0;          // The minimum X indent for the TOC items
var nY:Number = 5;          // the Y location of the TOC item
var nMaxSelect:Number = 0;  // the maximum selectable node
var nIndex:Number = 0;      // The index number of the TOC item
var visited_array:Array = new Array();    // array of page visit status
var selectable_array:Array = new Array(); // array of page selectable status
var nHeight:Number;         // height of a TOC item
var fmt:TextFormat;         // format of page TOC items
var nCheckWidth:Number;     // width of a checkmark
var lastPageClip:String;	// Name of most recent page added to index
var highlightSize:Number = highlight_mc._width;
var scrollMax:Number = playerMain_mc.topic_index_shell.height - 20;//height of index, Must auto scroll after this. 35 is for the horizontal scroll bar.
var page_activated:Boolean = false; //Used to determine when a topic should be activated.
var nextNavTopic:XMLNode;	//Used to determine next navigable topic.
var include_question_in_cnt:Boolean;
var lastSelectedPage:MovieClip;
var t_currentQuiz_xmlnode:XMLNode;        // quiz node 



// Diego.Diaz 22/02/2011 
import mx.transitions.Tween; 
import mx.transitions.easing.*; 
var selected_topic:MovieClip;  // Current Topic Selected [Expanded or not]
var clips:Array = new Array(); // Saves all clips created with duplicatedMovieClip
var blank_clip:MovieClip; 		// Stores the reference to the blank clip at the end of TOC
var indent:Number = 15; // Indentation inside each subtopic
var width_total:Number = 400; // Width of the TOC
var from_topic:Object = new Object(); // Saves pages per parentTopic


// CHangin colors 

playerMain_mc.indexLinkColor  = "0xCCCCCC";
playerMain_mc.highlightIndexColor = "0xCCCCCC";





trace(" @@@ >> "+playerMain_mc+" "+playerMain_mc.useInterfaceColors)
playerMain_mc.useInterfaceColors = false;
trace(" @@@ >> "+playerMain_mc+" "+playerMain_mc.useInterfaceColors)


//Check to see if they want to use questions in page count
include_question_in_cnt = (playerMain_mc.root_xmlnode.attributes.include_question_cnt.toUpperCase() == "TRUE");

createToc();


function createToc()
{
	// this topic is selectable
	var bSelectable:Boolean = true;
	
	// get the data to restore the state of the table of contents
	var suspend_str = playerMain_mc.apiGetState("toc");
	
	// see if we have a suspend string
	if (suspend_str != undefined)
	{
		// we do, so we must be running inside the player
		// see if there is any data from the last time we ran the SCO
		// see if there is anything there
		if (suspend_str != "")
		{
			// there is, break it apart (visited array, current selection, maximum selection)
			var suspend_array = suspend_str.split(":");
			visited_array = suspend_array[0].split(",");
			nMaxSelect = suspend_array[1] - 0;
			selectable_array = suspend_array[2].split(",");
		}
		// create a text format object, we'll use this later to underline text
		fmt = new TextFormat();
		fmt.underline = true;
		/*fmt.font = "Font1";//assign embedded font
		fmt_head = new TextFormat();//Style for header
		fmt_head.font = "Font1";//assign embedded font*/
			
		// get the height of a page item from the page item template
		nHeight = Page_mc._height;
		
		// get the width of a chekmark
		nCheckWidth = Checkmark_mc._width;
		// loop through the topics to create the table of contents
		for (var current_xmlnode:XMLNode = playerMain_mc.topics_xmlnode.firstChild;
			 current_xmlnode != null;
			 current_xmlnode = current_xmlnode.nextSibling)
		{	
			// see is this is a page
			if (current_xmlnode.nodeName == "page" && current_xmlnode.attributes.nonNavPage.toLowerCase() != "true")
			{
				playerMain_mc.total_pages++;
				//create a new attribute to store the page number
				current_xmlnode.attributes.pageNum = playerMain_mc.total_pages;
				//************Add Quiz questions to Page Count
				//Is this a quiz page?
				if (current_xmlnode.attributes.pType == "quiz"){
					//It is, do they want to include quiz questions in the pagecount
					if (include_question_in_cnt) {
						//Get the correct quiz node
						var quiz_id:String = current_xmlnode.attributes.id;
						t_currentQuiz_xmlnode = findQuizNode(playerMain_mc.t_firstQuiz_xmlnode, quiz_id)
						//Now get the data
						if (t_currentQuiz_xmlnode != null){
							var introPage:Boolean = (t_currentQuiz_xmlnode.attributes.intro != null);
							var resultsPage:Boolean = (t_currentQuiz_xmlnode.attributes.showresults.toUpperCase() == "TRUE");
							var pageCount:Number = t_currentQuiz_xmlnode.attributes.numquestions;
							if (pageCount === undefined){
								pageCount = 1;
							}
							//trace("introPage: " + introPage + " resultsPage: " + resultsPage + " pageCount: " + pageCount);
							//Now add to total page count
							playerMain_mc.total_pages--;
							if(introPage){
								playerMain_mc.total_pages++;
							} else {
								current_xmlnode.attributes.pageNum = playerMain_mc.total_pages;
							}
							if(resultsPage){
								playerMain_mc.total_pages++;
							}
							playerMain_mc.total_pages = playerMain_mc.total_pages + Number(pageCount);
						}
					}
				}
				// it is a page, create the page at level 0
				//If statement added in version 1.3, SWH
				if (current_xmlnode.attributes.isTocEntry != "false") {
					createPage(current_xmlnode,0,bSelectable);
					trace(" >>> PAGE ["+current_xmlnode.attributes.title+"]")
					
				} else {
					current_xmlnode.attributes.mc_str = lastPageClip;
				}
			} else if (current_xmlnode.nodeName == "page" && current_xmlnode.attributes.nonNavPage.toLowerCase() == "true"){
				//Hidden pages take on the page number of the previous visible pages.
				current_xmlnode.attributes.pageNum = playerMain_mc.total_pages;
				//trace(playerMain_mc.total_pages);
			}
			else if (current_xmlnode.nodeName == "topic")
			{			
				if (current_xmlnode.attributes.showTopicPages.toLowerCase() != "false")//Show the topic?
				{
					if (playerMain_mc.graphicalTopic){
						nY += playerMain_mc.graphicalTopicSpace;
					}
					// it is a topic, create the topic at level 0
					createTopic(current_xmlnode,0,bSelectable);
					
					trace(" >>> TOPIC ["+current_xmlnode.attributes.title+"]")
					
					// see if this topic has to be completed
					bSelectable = current_xmlnode.attributes.nav != "complete";
				} else {
				//Function Cycles through each page and mark it as nonNavPage
					
				}
			}
		}
		//Activate topics that need to be activated.
		activateTopics(); //makeNextSelectable(); 
		//Add a blank movie clip at the bottom so the scroll bar won't hide the last topic.
		addBlank();
		
		playerMain_mc.currentTopic_xmlnode = playerMain_mc.currentPage_xmlnode.parentNode;
		// set the selection (the first movie is already running)
		if (playerMain_mc.currentPage_xmlnode.attributes.mc_str) {//Updated to account for hidden pages. 3/25/05 SWH
			selectMovie(this[playerMain_mc.currentPage_xmlnode.attributes.mc_str], false);			
		} else {
			highlight_mc._visible = false;
		}
	
		// hide the template clips
		Page_mc._visible = false;
		Topic_mc._visible = false;
		Checkmark_mc._visible = false;
		blank_mc._visible = false;
		select_mc._visible = false;
	}
	//playerMain_mc.topic_index_shell.setSize(271,535);
	//set pageNumbering for first page.
	if (playerMain_mc.page_numbering) {
		playerMain_mc.pageNumber_mc.displayPageNumbers(playerMain_mc.currentPage_xmlnode.attributes.pageNum,playerMain_mc.total_pages);
	}
}

//Used to activate topics when course is reloaded
//*************************************************************************
function activateTopics(){
	for (var current_xmlnode:XMLNode = playerMain_mc.firstTopic_xmlnode;
			 current_xmlnode != null;
			 current_xmlnode = current_xmlnode.nextSibling)
		{
			for (var child_xmlnode:XMLNode = current_xmlnode.firstChild;
				child_xmlnode != null;
				child_xmlnode = child_xmlnode.nextSibling)
				{
					if (child_xmlnode.nodeName == "topic"){
						var cPage_xmlnode:XMLNode = getCurrentPage(child_xmlnode);
						if (cPage_xmlnode != null){
							//trace("curPage: " + cPage_xmlnode)
							//playerMain_mc.currentTopic_xmlnode = child_xmlnode;
							makeNextSelectableOnEntry(cPage_xmlnode,child_xmlnode);
						} else {//If they have a topic right after a topic.
							var cPage_xmlnode:XMLNode = getCurrentPage(current_xmlnode.firstChild);
							makeNextSelectableOnEntry(cPage_xmlnode,current_xmlnode);
						}
					}
				}
				if (current_xmlnode.nodeName == "topic"){
					var cPage_xmlnode:XMLNode = getCurrentPage(current_xmlnode);
					if (cPage_xmlnode != null){
						//trace("curPage: " + cPage_xmlnode)
						//playerMain_mc.currentTopic_xmlnode = current_xmlnode;
						makeNextSelectableOnEntry(cPage_xmlnode,current_xmlnode);
					} else {//If they have a topic right after a topic.
						var cPage_xmlnode:XMLNode = getCurrentPage(current_xmlnode.firstChild);
						makeNextSelectableOnEntry(cPage_xmlnode,current_xmlnode);
					}
				}
		}
}

function getCurrentPage(curTopic_xmlnode){
	for (var cPage_xmlnode:XMLNode = curTopic_xmlnode.firstChild;
			 cPage_xmlnode != null;
			 cPage_xmlnode = cPage_xmlnode.nextSibling)
			 {
				 if (cPage_xmlnode.nodeName == "page"){
					 return(cPage_xmlnode)
				 }
			 }
}

function makeNextSelectableOnEntry(cPage_xmlnode:XMLNode,cTopic_xmlnode:XMLNode)
{
	// go up through the hierarchy of topics
	for (var curTopic_xmlnode:XMLNode = cTopic_xmlnode;
		 curTopic_xmlnode.nodeName == "topic";
		 curTopic_xmlnode = curTopic_xmlnode.parentNode)
	{
		
		if (topicComplete(curTopic_xmlnode)){
			
			if (cPage_xmlnode.nextSibling != null && isNavNextTopic(cPage_xmlnode)) {
				//activate next topic
				
				makeSelectable(curTopic_xmlnode.nextSibling,false);
				if (nextNavTopic != undefined) {
					makeSelectable(nextNavTopic,false);
				}
			} else if (curTopic_xmlnode.nextSibling != null){ 
				//If not see if there is next sibling to this topic
				// there is, make it selectable
				makeSelectable(curTopic_xmlnode.nextSibling,false);
			}
		} else if (topicPageComplete(curTopic_xmlnode)){ //See if it is complete except for subtopics
			//trace("here")
			if (cPage_xmlnode.nextSibling != null && isNavNextTopic(cPage_xmlnode)) { 
					//activate next topic
					//trace("nextNavTopic: " + nextNavTopic)
					if (nextNavTopic != undefined) {
						makeSelectable(nextNavTopic,false);
					}
			}
			
		}
	}
}
//******************************************************************************
// create a page item
//	current_xmlnode - the current page node
//	nLevel - the level of this page (hierarchical level in the XML)
function createPage(current_xmlnode, nLevel, bSelectable, parentTopic)
{			


	trace(" layer: "+nLayer+" Level: "+nLevel+" parentTopic "+parentTopic)

	// create a name for this page item
	var name_str = "Page_mc" + nLayer;
	lastPageClip = name_str;
	// create a new page item based on our template
	Page_mc.duplicateMovieClip(name_str, nLayer);
	
	// increment the layer number for the next TOC entry
	nLayer++;
	
	// get a handle to this new movie clip
	this_mc = this[name_str];
	
		//Diego.Diaz add this page to from topic array
	if(from_topic[parentTopic._name] == undefined)
	{
	 	from_topic[parentTopic._name] = new Array()
		from_topic[parentTopic._name].push(this_mc);
	}
	else
	{
		from_topic[parentTopic._name].push(this_mc);
	}
	
	// Diego.Diaz 22/02/2011
	this_mc.parentTopic = parentTopic;
	clips.push(this_mc);
	
	//Custom color
	if (playerMain_mc.useInterfaceColors) {
		this_mc.Page_txt.textColor = 0xCCCCCC;//playerMain_mc.root_xmlnode.attributes.indexLinkColor;
	}
	// set the X and Y locations
	this_mc._x = nX + nLevel * nCheckWidth+nLevel*indent;
	this_mc._y = nY;
	//this_mc.Page_txt._width = width_total-this_mc._x-30;
	this_mc.Page_txt.autoSize = true;
	
	this_mc.nLevel = nLevel;
	
	//Add auto scroll value
	this_mc.vScroll = nY;
	
	// increment the location for the next TOC entry
	nY += nHeight;
	
	// set the text of this item
	//this_mc.Page_txt.embedFonts = true;
	if (playerMain_mc.noUnderlineInIndex != true){//No underline for some styles.
		//this_mc.Page_txt.setTextFormat(fmt);
		//this_mc.Page_txt.setNewTextFormat(fmt);
	}
	this_mc.Page_txt.text = current_xmlnode.attributes.title;
	
	// create a user-defined property to store the TOC index number
	this_mc.nIndex = nIndex;
	
	//================================================
	//Assign events to movie clip
	this_mc.onRollOver = function() {		
		
		
				
		// see if this page is selectable
		if (this.selectable_str == "1")
		{
			// it is, highlight it
			//this._y = this._y-1;
			//this._x = this._x+1;
			if (playerMain_mc.useInterfaceColors) {
				this.Page_txt.textColor = 0xCCCCCC;//playerMain_mc.root_xmlnode.attributes.indexLinkOverColor;
			} else {
				this.Page_txt.textColor = 0xCCCCCC;//playerMain_mc.indexOverColor;
			}
			var doToolTip:Boolean = (playerMain_mc.root_xmlnode.attributes.indexTooltip.toLowerCase() == "true");
			if (doToolTip){
				playerMain_mc.toolTipObj.showTip(this,this.Page_txt.text);
			}
			select_mc._x = 0;
			select_mc._y = this._y;
			select_mc._width = width_total;
			select_mc._visible = true;
		}
	}
	this_mc.onRollOut = function() {
		// see if this page is selectable
		if (this.selectable_str == "1")
		{
			// it is, undo the highlight
			//this._y = this._y+1;
			///this._x = this._x-1;
			if (playerMain_mc.useInterfaceColors) {
				this.Page_txt.textColor = 0xCCCCCC;//playerMain_mc.root_xmlnode.attributes.indexLinkColor;
			} else {
				this.Page_txt.textColor = 0xCCCCCC;//playerMain_mc.indexLinkColor;
			}
			select_mc._visible = false;
		}
		if (this == selected_mc){
			this.Page_txt.textColor = 0xCCCCCC;
		}
		
	}
	this_mc.onRelease = function() {
		
		trace("RELEASER 389 "+selected_topic)
		// see if this page is selectable
		if (this.selectable_str == "1")
		{
			// it is, select it and play the movie
			
			// Diego.Diaz 18/03/2011
			//playerMain_mc.hideIndex();				
			//playerMain_mc.menu_open = false;
			//playerMain_mc.menu_mc.gotoAndStop("up");
			
			
			
			this._parent.selectMovie(this, true);
		}	
		
		doReviewTopic(this.parentTopic);
	}
	//================================================
	
	// see if we have data in the visited array
	if (visited_array[nIndex] == undefined)
	{
		// we do not, initialize it to not visited
		visited_array[nIndex] = "0";
	} else if (visited_array[nIndex] == "1"){
		this_mc.visit_str = "1";
	}
	
	// see if we have data in the selectable array
	if (selectable_array[nIndex] == undefined)
	{
		// we do not, initialize it to the selectable value
		if (bSelectable)
			selectable_array[nIndex] = "1";
		else
			selectable_array[nIndex] = "0";
	}
	
	// create a user-defined property to remember if this node was visited
	this_mc.visit_str = visited_array[nIndex];
	
	// see if it has been visited
	if (visited_array[nIndex] != "0")
	{
		// it has been visited, set the checkmark
		setCheckmark(this_mc);
	}
	
	// create a user-defined property to indicate if this page is selectable
	this_mc.selectable_str = selectable_array[nIndex];
	
	// see if this page is selectable
	if (selectable_array[nIndex] == "0")
	{
		// it's not, gray it out
		this_mc.Page_txt.textColor = 0x777777;
	}
	
	// create a user-defined property to keep track of the page node
	this_mc.page_xmlnode = current_xmlnode;
	
	// store the name of this clip in the XML node's attribute list
	current_xmlnode.attributes.mc_str = name_str;

	// increment the index for the next TOC entry
	nIndex++;
}

// create a topic item
//	current_xmlnode - the current topic node
//	nLevel - the level of this page (hierarchical level in the XML)
function createTopic(current_xmlnode, nLevel, bSelectable, parentTopic)
{
	
	trace(" Topic Layer:"+nLayer+"  Level: "+nLevel+" parentTopic "+parentTopic)
	
	// TEmp
	var temp_topic = currentTopic;
	
	// create a name for this page item
	var name_str = "Topic_mc" + nLayer;
	
	// create a new page item based on our template
	Topic_mc.duplicateMovieClip(name_str, nLayer);
	
	// increment the layer number
	nLayer++;
	
	// get a handle to this new movie clip
	this_mc = this[name_str];
	
	// Diego.Diaz - 22/02/2011.
	currentTopic = this[name_str];
	clips.push(this_mc);
	
	this_mc.parentTopic = parentTopic;
	
	if(nLevel!=0)
	{
	this_mc._visible = false;
	this_mc._alpha = 0;
	}
	
	// set the X and Y locations
	/*
	if (playerMain_mc.moveJustTopicText){//For deepBlue style and other styles that want to adjust the inside of a topic.
		this_mc.text_mc._x = this_mc.text_mc._x + (nX + nCheckWidth + nLevel * nCheckWidth);
		this_mc._x = 0;
	} else {
		this_mc._x = nX + nCheckWidth + nLevel * nCheckWidth;
	}
	*/
	this_mc._x = nX + nLevel * nCheckWidth+nLevel*indent;	
	this_mc._y = nY;
	//this_mc.Topic_txt._width = width_total-this_mc._x-this_mc.Topic_txt._x;
	this_mc.Topic_txt.autoSize = true;
	this_mc.nLevel = nLevel;
	
	
	
	
	//Custom color
	if (playerMain_mc.useInterfaceColors) {				
		//this_mc.Topic_txt.textColor = playerMain_mc.root_xmlnode.attributes.indexTopicColor;
	}
	// increment the Y position for the next TOC item
	
	if (playerMain_mc.graphicalTopic){
		nY += nHeight + playerMain_mc.graphicalTopicSpace;
	} else {
		nY += nHeight;
	}
	
	// create a user-defined property to keep track of the page node
	this_mc.topic_xmlnode = current_xmlnode;
	
	// store the name of this clip in the XML node's attribute list
	topic_xmlnode.attributes.mc_str = name_str;
	
	// set the text of this item
	/*this_mc.Topic_txt.embedFonts = true;
	this_mc.Topic_txt.setTextFormat(fmt_head);
	this_mc.Topic_txt.setNewTextFormat(fmt_head);*/
	if (playerMain_mc.moveJustTopicText){
		this_mc.text_mc.Topic_txt.text = current_xmlnode.attributes.title;
	} else {
		this_mc.Topic_txt.text = current_xmlnode.attributes.title;
	}

	//================================================
	//Assign events to movie clip
	this_mc.useHandCursor = true;
	this_mc.onRollOver = function() {
		
			
			// If topic is resalted, not do this
			if(this == highlight_mc.clip)
			return;
			
			
		
			// do Tooltip
			var doToolTip:Boolean = (playerMain_mc.root_xmlnode.attributes.indexTooltip.toLowerCase() == "true");
			if (doToolTip){
				if (playerMain_mc.moveJustTopicText){
					playerMain_mc.toolTipObj.showTip(this,this.text_mc.Topic_txt.text);
				} else {
					playerMain_mc.toolTipObj.showTip(this,this.Topic_txt.text);
				}
			}
			
			// see if this page is selectable	
			// it is, highlight it
			//this._y = this._y-1;
			//this._x = this._x+1;
			if (playerMain_mc.useInterfaceColors) {
				this.Topic_txt.textColor = 0xCCCCCD;//playerMain_mc.root_xmlnode.attributes.indexLinkOverColor;
			} else {
				this.Topic_txt.textColor = 0xCCCCCD;//playerMain_mc.indexOverColor;
			}

			select_mc._x = 0;
			select_mc._y = this._y;
			select_mc._width = width_total;
			select_mc._visible = true;
		
	}
	this_mc.onRollOut = function() {
		
			// If topic is resalted, not do this
			if(this == highlight_mc.clip)
			return;
			
			// see if this page is selectable
			// it is, undo the highlight
			//this._y = this._y+1;
			///this._x = this._x-1;
			if (playerMain_mc.useInterfaceColors) {
				this.Topic_txt.textColor = 0xCCCCCD;//playerMain_mc.root_xmlnode.attributes.indexLinkColor;
			} else {
				this.Topic_txt.textColor = 0xCCCCCD;//playerMain_mc.indexLinkColor;
			}
			select_mc._visible = false;
			
			// ?????????????????????????
			
		if (this == selected_mc){
			this.Topic_txt.textColor = 0xCCCCCD;
		}
		
	}
	this_mc.onRelease = function() {
		// see if this page is selectable
		
		trace("RELEAAE 593")
		// Click the Topic
		this._parent.expandTopic(this);
		// Trick, so White text is shown on topic once user release click
		//this.onRollOut();
		//this.onRollOver();
		
	}
	//================================================
	
	// loop through the nodes contained in this topic
	for (var current_xmlnode = current_xmlnode.firstChild;
		 current_xmlnode != null;
		 current_xmlnode = current_xmlnode.nextSibling)
	{
		//trace("xmlnode: " + current_xmlnode.nodeName + " nonNavPage: " + current_xmlnode.attributes.nonNavPage.toLowerCase())
		// see is this is a page
		if (current_xmlnode.nodeName == "page" && current_xmlnode.attributes.nonNavPage.toLowerCase() != "true")
		{
			playerMain_mc.total_pages++;
			//create a new attribute to store the page number
			current_xmlnode.attributes.pageNum = playerMain_mc.total_pages;
			//************Add Quiz questions to Page Count
			//Is this a quiz page?
			if (current_xmlnode.attributes.pType == "quiz"){
				//It is, do they want to include quiz questions in the pagecount
				if (include_question_in_cnt) {
					//Get the correct quiz node
					var quiz_id:String = current_xmlnode.attributes.id;
					t_currentQuiz_xmlnode = findQuizNode(playerMain_mc.t_firstQuiz_xmlnode, quiz_id)
					//Now get the data
					if (t_currentQuiz_xmlnode != null){
						var introPage:Boolean = (t_currentQuiz_xmlnode.attributes.intro != null);
						var resultsPage:Boolean = (t_currentQuiz_xmlnode.attributes.showresults.toUpperCase() == "TRUE");
						var pageCount:Number = t_currentQuiz_xmlnode.attributes.numquestions;
						if (pageCount === undefined){
								pageCount = 1;
							}
						//trace("introPage: " + introPage + " resultsPage: " + resultsPage + " pageCount: " + pageCount);
						//Now add to total page count
						playerMain_mc.total_pages--;
						if(introPage){
							playerMain_mc.total_pages++;
						} else {
							current_xmlnode.attributes.pageNum = playerMain_mc.total_pages;
						}
						if(resultsPage){
							playerMain_mc.total_pages++;
						}
						playerMain_mc.total_pages = playerMain_mc.total_pages + Number(pageCount);
					}
				}
			}
			// it is a page, create the page at level 0
			//If statement added in version 1.3, SWH
			if (current_xmlnode.attributes.isTocEntry != "false") {
				
				// Diego.Diaz 22/02/2011 - Added for selecting Topics				
				createPage(current_xmlnode, nLevel+1, bSelectable, currentTopic);
			} else {
				current_xmlnode.attributes.mc_str = lastPageClip;
			}
		} else if (current_xmlnode.nodeName == "page" && current_xmlnode.attributes.nonNavPage.toLowerCase() == "true"){
				//Hidden pages take on the page number of the previous visible pages.
				current_xmlnode.attributes.pageNum = playerMain_mc.total_pages;
		}
		else if (current_xmlnode.nodeName == "topic")
		{
			if (current_xmlnode.attributes.showTopicPages.toLowerCase() != "false")//Do we want to show the topic?
			{
				if (playerMain_mc.graphicalTopic){
					nY += playerMain_mc.graphicalTopicSpace;
				}
				// it is a topic, create the topic at level 0
				createTopic(current_xmlnode, nLevel+1, bSelectable, currentTopic);
				// see if this topic has to be completed
				var bSelectableTopic:Boolean = current_xmlnode.attributes.nav != "complete";
				if (!bSelectableTopic) {
					bSelectable = bSelectableTopic;
				}
			} 
		}
	}
	
	// Diego.Diaz 
	trace("OUT AS TOPIC: "+temp_topic)
	currentTopic = temp_topic;
}


// Diego.Diaz 22/02/2011
// Refresh the TOC, showing only one expanded topic at any time [I't trigerred from a page click]
function expandTopicFromPage(item_mc)
{
	trace("ExpandTopicFomrPage "+selected_topic)
	//selected_topic.expanded = false;
	if(selected_topic!= undefined)
	contractTopic(selected_topic)
	
	selected_topic = item_mc.parentTopic;
	selected_topic.expanded = true;
	selected_topic.arrow_mc.gotoAndStop(2);
	refreshTopic(false);
}

// Hiding all subtopics inside this topic
function contractTopic(topic_mc)
{
	
	trace("OCULTAR: "+topic_mc)
	topic_mc.expanded = false;	
	topic_mc.arrow_mc.gotoAndStop(1);
	
	if(topic_mc.nLevel == 0)
	{		
		return;
	}	
	
	contractTopic(topic_mc.parentTopic)
		
}


// Review if all pages inside a topic have already been seen
function doReviewTopic(_topic){


	trace("------>   DO REVIEW "+_topic)

		// See if user has seen all pages inside this topic
		for(var i in from_topic)
		{
			
			if(i == _topic._name)
			{
			trace("#>> "+i)
			var all = true;
			for(var j in from_topic[i])
			{
				trace(j+" in: "+from_topic[i][j]+" seen: "+from_topic[i][j].visit_str+ "type of "+typeof(from_topic[i][j].visit_str))
				if(from_topic[i][j].visit_str!= "1" )
				{
					trace("!= 1")
					all = false;
				//break;
				}
			}						
			trace("ALL "+all)
			if(all == true)
			{
				trace("INSIDE ")
				_topic.ico_mc.gotoAndStop(2)
			}
			}
		}
		}


// Refresh the TOC, showing or hidding this Topic  [Trigerred from Topic click]
function expandTopic(topic_mc)
{
	trace("ExpandTopic "+topic_mc+" Selected "+selected_topic+"Parent: "+topic_mc.parentTopic+"  parentSelec: "+selected_topic.parentTopic)
		
	/*if(selected_topic!=topic_mc && topic_mc.parentTopic != selected_topic)
	{
		selected_topic.expanded = false;
		selected_topic = topic_mc;
	}
	else
	{
		selected_topic = topic_nc
		}*/
		
	if(selected_topic!=topic_mc)
	{
		if(topic_mc.parentTopic!=selected_topic)
		{
			// CLic a topic that is not Parent 
			contractTopic(selected_topic)
			//selected_topic.expanded = false;
		}
		
		
		trace("** topic: "+topic_mc+" selected: "+selected_topic.parentTopic)
		if(topic_mc != selected_topic.parentTopic)
		{
			selected_topic = topic_mc;
			// Changes current state for this Topic,  true-false-true... etc
			if(selected_topic.expanded == undefined)
			{
				selected_topic.expanded = false;
				selected_topic.arrow_mc.gotoAndStop(1);
			}
				
		
			selected_topic.expanded=!selected_topic.expanded;				
			
			selected_topic.expanded==true?selected_topic.arrow_mc.gotoAndStop(2):selected_topic.arrow_mc.gotoAndStop(1)
			trace("EXPANDE!!!")
		}
		selected_topic = topic_mc;
		trace("SEL TP"+selected_topic)
	}
	else
	{
	
		
		// Changes current state for this Topic,  true-false-true... etc
		if(selected_topic.expanded == undefined)
		{
			selected_topic.expanded = false;
			selected_topic.arrow_mc.gotoAndStop(1)
		}
			
	
		selected_topic.expanded=!selected_topic.expanded;				
		selected_topic.expanded==true?selected_topic.arrow_mc.gotoAndStop(2):selected_topic.arrow_mc.gotoAndStop(1)
	
	}
	refreshTopic();
}


// Show all pages and topics that have  'topic' as parentTopic
function showSubtopics(topic)
{
	
	trace("SUB>> "+topic)
	if(topic == undefined)
	return;
	
	showSubtopics(topic.parentTopic)
	
	for(var i=0;i<clips.length;i++)
	{
		if(clips[i].parentTopic == topic)
		{
			trace("== "+clips[i])
			clips[i]._visible = true;
			clips[i]._alpha = 100;
		}
	}
}

// Refresh  all topics, hidding pages on non expanded topics
function refreshTopic(_doTween)
{
	// Array for tweening elements
	var tw:Array = new Array();
	
	
	var expanded_topic:Object = new Object();
	for(var i=0;i<clips.length;i++)
	{
			//trace("clips["+i+"] "+clips[i]+" p: "+clips[i].parentTopic)
		
			var topic = clips[i].parentTopic;
			// Pages outside a Topic
			if(topic == undefined)
			{
				continue;
			}
			
			if(topic.expanded == true)
			{
				// Topic Expanded
				clips[i]._visible = true;
				clips[i]._alpha = 0;
				tw.push(clips[i])
				
				clips[i].parentTopic.Topic_txt.textColor = 0xCCCCCD;
				expanded_topic[clips[i].parentTopic] = true;
				//showSubtopics(clips[i].parentTopic);
			}
			else
			{
				// Topic Hidden
				clips[i]._visible = false;				
				clips[i].parentTopic.Topic_txt.textColor = 0xCCCCCD;
			}						
	}
	
	trace("ex: "+expanded_topic)
	for(var i in expanded_topic)
	{
		trace(i+" en_ "+expanded_topic[i]+" es: "+typeof(eval(i)))
		if(typeof(eval(i)) == "movieclip")
		{
			showSubtopics(eval(i));
			}
		}
	
	
	
	var nY = 5;
	for(var i=0;i<clips.length;i++)
	{
		if(clips[i]._visible == true)
		{
				
				
				if(clips[i].hidden != true)
				{
					var TY:Tween = new Tween(clips[i], "_y", Strong.easeIn  , clips[i]._y, nY, 0.2, true); 					
					clips[i]._endY = nY;				
					//clips[i]._y = nY;				
				}
				else
				{
					clips[i]._y = nY;				
				}
				
				clips[i].hidden = false;
				if(clips[i]._name.indexOf("Page_mc")!=-1)
				{
					//Page
					nY+=nHeight;
				}
				else
				{
					// Topic
					if (playerMain_mc.graphicalTopic){
						nY += nHeight + playerMain_mc.graphicalTopicSpace;
					} else {
						nY += nHeight;
					}
				}												
				if(selected_mc == clips[i])
				{
					//highlight_mc._y = selected_mc._y;										
					//highlight_mc._y = selected_mc._endY;										
					var TYH:Tween = new Tween(highlight_mc, "_y", Strong.easeIn  , highlight_mc._y, selected_mc._endY, 0.2, true); 					
					highlight_mc.clip = selected_mc;
				}
				
				
				clips[i].parentTopic.Topic_txt.textColor = 0xCCCCCD;	
				clips[i].parentTopic.selected = false;
		}		
		else
		{
			// Put all hidden clips at beggining so it does not breaks scroll
			clips[i]._y = 5;
			clips[i].hidden = true;
			if(selected_mc == clips[i])
			{
//				highlight_mc._y = clips[i].parentTopic._y;				
				//highlight_mc._y = clips[i].parentTopic._endY;				
				
				
				//highlight_mc.clip = clips[i].parentTopic;
				highlight_mc.clip = doHighlight(clips[i].parentTopic)
				trace("HIG "+highlight_mc.clip)
				clips[i].parentTopic.Topic_txt.textColor = 0xCCCCCD;
				//clips[i].parentTopic.selected = true;
				highlight_mc.clip.selected = true;
				
				var TYH:Tween = new Tween(highlight_mc, "_y", Strong.easeIn  , highlight_mc._y, highlight_mc.clip._endY, 0.2, true); 					
			}
		}
	}
	
	
	// Add the blank at the end
	blank_clip._y = nY;
	nY+=nHeight;
	
	
	
	// Fade in the pages clips
	for(var i=0;i<tw.length;i++)
	{
		if(_doTween!=false)
		xScaleT = new Tween(tw[i], "_alpha", Strong.easeIn  , 0, 100, 0.4, true); 
	}
	xScaleT.onMotionFinished = function() {
    trace("onMotionFinished triggered");
	// Refresh the scroll bars	
	playerMain_mc.topic_index_shell.refreshPane();
	playerMain_mc.topic_index_shell.getScrollContent()._y = 0;
	playerMain_mc.topic_index_shell.setScrollPosition(0,0)
	
	};
	
	
	
}

// looks for a parent topic which is not hidden
function doHighlight(topic_mc)
{
	
	trace("IN: "+topic_mc+" EXPANDIDO? "+topic_mc.expanded+" VISIBLE: "+topic_mc._visible+" PARENT: "+topic_mc.parentTopic)
	output = topic_mc;
	if(output._visible == false)
	{
		trace("INSIDE")
		output = doHighlight(output.parentTopic);
	}
	
	trace("RET: "+output)
	return output;
	}


// select a movie, called from a release event on a page item
//	bSwitch - true if we want to switch the movie playing
function selectMovie(item_mc, bSwitch)
{
	selected_mc.Page_txt.textColor = 0xCCCCCC;
	// make this the selected page- lastSelectedPage
	selected_mc = item_mc;
	
	
	// Diego.Diaz 22/02/2011
	//selected_topic = item_mc.parentTopic;
	expandTopicFromPage(item_mc);
	
	
	
	//See which completion method is being used
	var usePageComplete:Boolean = playerMain_mc.root_xmlnode.attributes.pageComplete == "true";
	if (!usePageComplete) {
		// see if this page was previously selected
		if (selected_mc.visit_str == "0")
		{
			// it was not, check it
			setCheckmark(selected_mc);
			
			// remember this selction in the visited array
			visited_array[selected_mc.nIndex] = "1";
			
			// this is a new selection so we need to update the state
			updateState();
		}
	}
	
	// put the selected movie clip on top of the selected clip
	if (playerMain_mc.leftJustifiedHighlight){
		highlight_mc._x = 0;
	} else {
		highlight_mc._x = 0;//selected_mc._x;
	}
	highlight_mc._y = selected_mc._y;
	if (!playerMain_mc.leftJustifiedHighlight){
		highlight_mc._width = width_total;//highlightSize - (selected_mc.nLevel * nCheckWidth);
	}
	highlight_mc._visible = true;
	
	if (playerMain_mc.highlightIndexColor !== undefined){
		//trace(playerMain_mc.highlightIndexColor)
		//trace(lastSelectedPage + " : " + selected_mc)
		selected_mc.Page_txt.textColor = 0xCCCCCC;//playerMain_mc.highlightIndexColor;
		changeIndexMouseOver(selected_mc);
		if (lastSelectedPage !== undefined && lastSelectedPage != selected_mc){
			lastSelectedPage.Page_txt.textColor = playerMain_mc.indexLinkColor;
			resetIndexMouseOver(lastSelectedPage);
		}
		
	}
	selected_mc.Page_txt.textColor = 0xCCCCCC;
	
	lastSelectedPage = item_mc;
	
	makeNextSelectable()
	
	// see if this selection makes the topic complete
	if (topicComplete(playerMain_mc.currentPage_xmlnode.parentNode))
	{
		// it does, make sure the next topic is selectable
	}
	
	// see if we want to switch the movie
	if (bSwitch)
	{
		// we do, update the current page and topic
		playerMain_mc.currentPage_xmlnode = item_mc.page_xmlnode;
		playerMain_mc.currentTopic_xmlnode = playerMain_mc.currentPage_xmlnode.parentNode;
		
		// show the movie
		playerMain_mc.loadCurrentPage();
	}
	//Make navigation buttons active if necessary
	var showButtons:Boolean = playerMain_mc.currentPage_xmlnode.attributes.hideNavButtons.toUpperCase() != "TRUE";
	//trace(showButtons)
	if (playerMain_mc.backButtonHidden && showButtons){
		playerMain_mc.back_mc._visible = true;
		playerMain_mc.backButtonHidden = false;
	}
	if (playerMain_mc.nextButtonHidden && showButtons){
		playerMain_mc.next_mc._visible = true;
		playerMain_mc.nextButtonHidden = false;
	}
}

// make the next topic selectable if needed
function makeNextSelectable()
{
	// go up through the hierarchy of topics
	for (var curTopic_xmlnode:XMLNode = playerMain_mc.currentTopic_xmlnode;
		 curTopic_xmlnode.nodeName == "topic";
		 curTopic_xmlnode = curTopic_xmlnode.parentNode)
	{
		// see if this topic requires completion
		//if (curTopic_xmlnode.attributes.nav == "complete"){
			// it does, see if it is complete
			//(curTopic_xmlnode.attributes.title);
			//trace(topicComplete(curTopic_xmlnode));
			if (topicComplete(curTopic_xmlnode)){
				// it is, see if there is a child topic
				//trace(playerMain_mc.currentPage_xmlnode.nextSibling != null);
				//trace(playerMain_mc.currentPage_xmlnode.nextSibling.nodeName == "topic");
				//trace(isNavNextTopic(playerMain_mc.currentPage_xmlnode));
				if (playerMain_mc.currentPage_xmlnode.nextSibling != null && isNavNextTopic(playerMain_mc.currentPage_xmlnode)) {
					//activate next topic
					makeSelectable(curTopic_xmlnode.nextSibling,false);
					if (nextNavTopic != undefined) {
						makeSelectable(nextNavTopic,false);
					}
				} else if (curTopic_xmlnode.nextSibling != null){ 
					//If not see if there is next sibling to this topic
					// there is, make it selectable
					makeSelectable(curTopic_xmlnode.nextSibling,false);
				}
			} else if (topicPageComplete(curTopic_xmlnode)){ //See if it is complete except for subtopics
				if (playerMain_mc.currentPage_xmlnode.nextSibling != null && isNavNextTopic(playerMain_mc.currentPage_xmlnode)) { 
						//activate next topic
						if (nextNavTopic != undefined) {
							makeSelectable(nextNavTopic,false);
						}
				}
			}
		//}
	}
}

//Checks to see if next navigation is a topic
function isNavNextTopic(curPage:XMLNode) {
	//Loop through next siblings to find out if a topic is the next navigation point
	for (var nextPage:XMLNode = curPage;nextPage != null;nextPage = nextPage.nextSibling){
		//Find out if it is a page
		if (nextPage.nodeName == "page") {
			//it is, find out if it is not completed
			if (this[nextPage.attributes.mc_str].visit_str !="1") {
				//not completed return false
				nextNavTopic = undefined;
				return false;
			}
		} else if (nextPage.nodeName == "topic") {
			//found topic, return true
			nextNavTopic = nextPage;
			return true;
		}
	}
	//must be false.
	nextNavTopic = undefined;
	return false;
}

// update the state information for the table of contents
//	item_mc - the new item
function updateState()
{
	// save visited array : max selectable : selectable array
	playerMain_mc.apiSetState("toc",visited_array.join(",") + ":" + nMaxSelect + ":" + selectable_array.join(","));
}

// put a check next to a page
//	page_mc - the movie clip for the item
function setCheckmark(page_mc)
{
	// mark it as selected
	page_mc.visit_str = "1";
	
	page_mc.ico_mc.gotoAndStop(2)
	
	// create a movie clip for the chechmark and place it next to the page
	var name_str = "Checkmark_mc" + nLayer;
	Checkmark_mc.duplicateMovieClip(name_str, nLayer);
	this[name_str]._x = page_mc._x;
	this[name_str]._y = page_mc._y;
	
	// increment the layer
	nLayer++;
}

// set the selection in the table of contents when
// outside navigation is used such as back/prev buttons
function tocSetSelection()
{
	
	// get the TOC item for this node
	var item_mc = this[playerMain_mc.currentPage_xmlnode.attributes.mc_str];
	
	// select the toc using this clip
	//trace(playerMain_mc.currentPage_xmlnode)
	//If statement added for version 1.3 SWH 3/25/05
	//trace(item_mc)
	if (item_mc) {
		selectMovie(item_mc, false);
		//Auto scroll the pane if a navigation button was clicked.
		autoScroll(item_mc);
		
		doReviewTopic(item_mc.parentTopic)
	} else {
		highlight_mc._visible = false;
		if (playerMain_mc.highlightIndexColor !== undefined){
			if (lastSelectedPage !== undefined){
				lastSelectedPage.Page_txt.textColor = playerMain_mc.indexLinkColor;
				resetIndexMouseOver(lastSelectedPage);
			}
			
		}
	}
}

// return true if the page containing this topic is complete
function topicComplete(curTopic_xmlnode:XMLNode)
{
	var complete:Boolean;
	
	// loop through all of the pges/topics in this topic
	for(var curPage_xmlnode:XMLNode = curTopic_xmlnode.firstChild;
		curPage_xmlnode != null;
		curPage_xmlnode = curPage_xmlnode.nextSibling)
	{
		// see if this is a page
		if (curPage_xmlnode.nodeName == "page")
		{
			// it is, get the completion status
			complete = this[curPage_xmlnode.attributes.mc_str].visit_str == "1";
		}
		else
		{
			// a topic, get the completion status of the topic
			complete = topicComplete(curPage_xmlnode);
		}
		
		// see if this topic/page is not complete
		if (!complete)
		{
			// it is not, return incomplete
			return false;
		}
	}
	
	// must be complete
	return true;
}

// Similar but only checks pages not Subtopics
function topicPageComplete(curTopic_xmlnode:XMLNode){
	var complete:Boolean;
	
	// loop through all of the pges in this topic
	for(var curPage_xmlnode:XMLNode = curTopic_xmlnode.firstChild;
		curPage_xmlnode != null;
		curPage_xmlnode = curPage_xmlnode.nextSibling)
	{
		// see if this is a page
		//trace(this[curPage_xmlnode.attributes.mc_str].visit_str);
		if (curPage_xmlnode.nodeName == "page"){
			// it is, get the completion status
			//trace(curPage_xmlnode);
			complete = this[curPage_xmlnode.attributes.mc_str].visit_str == "1";
		}
		//trace(curPage_xmlnode.attributes.title);
		//trace(complete);
		// see if this topic/page is not complete
		if (!complete){
			// it is not, return incomplete
			return false;
		}
	}
	// must be complete
	
	trace("************************ TOPIC COMPLETED ")
	
	return true;
}


// make this topic selectable
function makeSelectable(curTopic_xmlnode:XMLNode,pg_activated)
{
	if (pg_activated != undefined) {
		page_activated = pg_activated;
	}
	var this_mc;
	//If it is a page instead of a topic
	if (curTopic_xmlnode.nodeName == "page")
	{
		this_mc = this[curTopic_xmlnode.attributes.mc_str];
		selectable_array[this_mc.nIndex] = "1";
		this_mc.selectable_str = "1";
		//Set correct color
		if (playerMain_mc.useInterfaceColors) {
			this_mc.Page_txt.textColor = playerMain_mc.root_xmlnode.attributes.indexLinkColor;
		} else {
			//trace(playerMain_mc.indexLinkColor)
			if (playerMain_mc.indexLinkColor !== undefined){
				this_mc.Page_txt.textColor = playerMain_mc.indexLinkColor;
			} else {
				this_mc.Page_txt.textColor = 0xCCCCCC;
			}
		}
		page_activated = true;
	}
	// loop through the nodes in this topic
	// loop through all of the pges/topics in this topic
	for(var curPage_xmlnode:XMLNode = curTopic_xmlnode.firstChild;
		curPage_xmlnode != null;
		curPage_xmlnode = curPage_xmlnode.nextSibling)
	{
		// see if this is a page
		if (curPage_xmlnode.nodeName == "page")
		{
			// it is, set it to selectable
			this_mc = this[curPage_xmlnode.attributes.mc_str];
			selectable_array[this_mc.nIndex] = "1";
			this_mc.selectable_str = "1";
			//Set correct color
			if (playerMain_mc.useInterfaceColors) {
				this_mc.Page_txt.textColor = playerMain_mc.root_xmlnode.attributes.indexLinkColor;
			} else {
				//trace(playerMain_mc.indexLinkColor)
				if (playerMain_mc.indexLinkColor !== undefined){
					this_mc.Page_txt.textColor = playerMain_mc.indexLinkColor;
				} else {
					this_mc.Page_txt.textColor = 0xCCCCCC;//0x000000;
				}
			}
			page_activated = true;
			//trace(page_activated)
		}
		else
		{
			// a topic, make this topic selectable
			//trace(page_activated);
			if (!page_activated){//Check to see if pages have already been activated.
				makeSelectable(curPage_xmlnode,false);
			}
		}
	}
}

//Scroll the scroll pane if necessary
function autoScroll(item_mc){
	//trace(item_mc.vScroll);
	var scrollObj:Object = playerMain_mc.topic_index_shell.getScrollPosition();
	var curScrollY:Number = scrollObj.y;
	var curScrollX:Number = scrollObj.x;
	//Do we need to scroll?
	//trace("vscroll: " + item_mc.vScroll + "  curScrollY: " + curScrollY + "  scrollMax: " + scrollMax);
	if (item_mc.vScroll > (scrollMax + curScrollY)) {
		var newScroll:Number = Math.round(Math.abs(item_mc.vScroll - scrollMax) + item_mc._height);
		playerMain_mc.topic_index_shell.setScrollPosition(curScrollX,newScroll);
		
	}
	if (item_mc.vScroll < curScrollY) {
		playerMain_mc.topic_index_shell.setScrollPosition(curScrollX,item_mc.vScroll);
		
	}
}

//Add a blank movie clip so the last topic isn't hidden by the scroll bar
function addBlank() {
	
	var name_str = "blank_mc" + nLayer;
	
	// create a new page item based on our template
	blank_mc.duplicateMovieClip(name_str, nLayer);
	
	// increment the layer number for the next TOC entry
	nLayer++;
	
	// get a handle to this new movie clip
	this_mc = this[name_str];
	
	// set the Y locations
	this_mc._y = nY;

	// increment the location for the next TOC entry
	nY += nHeight;
	
	// Saves this reference
	blank_clip = this_mc;
	
}

//Finds the quiz node that matches a particular id
function findQuizNode(current_quiznode:XMLNode, id_str:String){
	if (current_quiznode.attributes.id == id_str) {
		// it does, return it
		return current_quiznode;
	} else {
		// see if the sibling is null
		if (current_quiznode.nextSibling ==  null) {
			// it is, return null
			return null;
		} else {
			// it is not, recurse down
			return findQuizNode(current_quiznode.nextSibling, id_str);
		}
	}
}

function changeIndexMouseOver(index_mc:MovieClip){
	index_mc.onRollOver = function(){
		// see if this page is selectable
		if (this.selectable_str == "1") {
			// it is, highlight it
			this._y = this._y-1;
			this._x = this._x+1;
			
			this.Page_txt.textColor = 0xCCCCCC;// playerMain_mc.highlightIndexColor;
		}
		var doToolTip:Boolean = (playerMain_mc.root_xmlnode.attributes.indexTooltip.toLowerCase() == "true");
		if (doToolTip){
			playerMain_mc.toolTipObj.showTip(this,this.Page_txt.text);
		}
	}
	index_mc.onRollOut = function() {
		// see if this page is selectable
		if (this.selectable_str == "1") {
			// it is, undo the highlight
			this._y = this._y+1;
			this._x = this._x-1;
			
			this.Page_txt.textColor = playerMain_mc.highlightIndexColor;
		}
	}
}

function resetIndexMouseOver(index_mc:MovieClip){
	index_mc.onRollOver = function(){
		// see if this page is selectable
		if (this.selectable_str == "1")
		{
			// it is, highlight it
			this._y = this._y-1;
			this._x = this._x+1;
			if (playerMain_mc.useInterfaceColors) {
				this.Page_txt.textColor = 0xCCCCCC;//playerMain_mc.root_xmlnode.attributes.indexLinkOverColor;
			} else {
				this.Page_txt.textColor = 0xCCCCCC;//playerMain_mc.indexOverColor;
			}
		}
		var doToolTip:Boolean = (playerMain_mc.root_xmlnode.attributes.indexTooltip.toLowerCase() == "true");
		if (doToolTip){
			playerMain_mc.toolTipObj.showTip(this,this.Page_txt.text);
		}
	}
	index_mc.onRollOut = function() {
		// see if this page is selectable
		if (this.selectable_str == "1")
		{
			// it is, undo the highlight
			this._y = this._y+1;
			this._x = this._x-1;
			if (playerMain_mc.useInterfaceColors) {
				this.Page_txt.textColor = 0xCCCCCC;//playerMain_mc.root_xmlnode.attributes.indexLinkColor;
			} else {
				this.Page_txt.textColor = 0xCCCCCC;//playerMain_mc.indexLinkColor;
			}
		}
	}
}


