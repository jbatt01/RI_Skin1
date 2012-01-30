/*
Flash Companion, Copyright 2004, 2005, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications made to this page for version 1.3:
		- Changed XML functions to globals (45, 73, & 100).
		- Added two new XML functions: matchSiblingNode and matchPreviousSiblingNode
		- Added error checking for the parsing of the XML file in the readXML function.
		- Updated XML loading to work with pre-loader.
		- Created global variable for main Timeline so player can play inside another Flash movie.
	Modifications made for version 3
		- added a cache fix for Unison.
*/

// stop on frame one until we have loaded the XML
stop();

//*******************Solves Caching Issue*************************
_global.getSkipCacheString = function(){
  if(getSkipCacheString.isLocalPlayback){
    return "";
  }
  dStr = "&timestamp="+new Date().getTime();
  return "?CacheBuster="+Math.random()+dStr;
};
getSkipCacheString.isLocalPlayback = _url.indexOf("file") == 0;
//**************************END***********************************

//Global for main timeline
_global.playerMain_mc = this;

var sco_xml:XML = new XML(); //creates the XML object in Flash
var cacheString1:String = getSkipCacheString();
if (cacheString1 === undefined)
	cacheString1 = "";
sco_xml.load("sco.xml" + cacheString1);     //load the SCO's XML data into the XML object
//trace("sco.xml" + getSkipCacheString())
sco_xml.onLoad = readXML;   //execute this function after loading XML
sco_xml.ignoreWhite = true;  //ignore white space between tags in the XML file

// Global values pointing to XML nodes
var root_xmlnode:XMLNode;          // root node of XML
var topics_xmlnode:XMLNode;        // topics node     
var firstTopic_xmlnode:XMLNode;    // first topic 
var currentTopic_xmlnode:XMLNode;  // current topic visited by learner
var currentPage_xmlnode:XMLNode;   // current page cisited by learner
var firstPage_xmlnode:XMLNode      // first page in the XML
var lastPage_xmlnode:XMLNode       // last page in the XML

// readXML - called once XML object is loaded
//	load_boolean - true is the XML file could be loaded
function readXML(load_boolean)
{
	// see if the XML was loaded
	if (load_boolean)
	{
		// it was, get global values from the XML
		root_xmlnode       = sco_xml.firstChild;
		topics_xmlnode     = getFirst(root_xmlnode.firstChild, "topics");
		firstTopic_xmlnode = getFirst(topics_xmlnode.firstChild, "topic");
		firstPage_xmlnode  = getFirstPage(topics_xmlnode.firstChild);
		lastPage_xmlnode   = getLast(topics_xmlnode.lastChild, "page");
		//(lastPage_xmlnode)
		lastPage_xmlnode	= getLastPage(lastPage_xmlnode);
		//trace(lastPage_xmlnode)
		// initialize the first topic and page
		// The data we get from SCORM may override these values later
		currentTopic_xmlnode = firstPage_xmlnode.parentNode;
		currentPage_xmlnode  = firstPage_xmlnode;
		
		// we have loaded all of the XML data, get the SCORM data on frame 4
		gotoAndStop(4);
		//Display error message if there was one.
		if (sco_xml.status != 0) {
			var errorMessage:String;
			switch (sco_xml.status) {
				case -2 :
				  errorMessage = "A CDATA section was not properly terminated.";
				  break;
				case -3 :
				  errorMessage = "The XML declaration was not properly terminated.";
				  break;
				case -4 :
				  errorMessage = "The DOCTYPE declaration was not properly terminated.";
				  break;
				case -5 :
				  errorMessage = "A comment was not properly terminated.";
				  break;
				case -6 :
				  errorMessage = "An XML element was malformed.";
				  break;
				case -7 :
				  errorMessage = "Out of memory.";
				  break;
				case -8 :
				  errorMessage = "An attribute value was not properly terminated.";
				  break;
				case -9 :
				  errorMessage = "A start-tag was not matched with an end-tag.";
				  break;
				case -10 :
				  errorMessage = "An end-tag was encountered without a matching start-tag.";
				  break;
				default :
				  errorMessage = "An unknown error has occurred.";
				  break;
			}
			trace("The XML file did not parse correctly -- status: "+sco_xml.status+" ("+errorMessage+")");
		}
	}
}

// return a node that matches the name, recurse down if needed
//	current_xmlnode - a node
//	name_str - the name to look for
_global.matchNode = function(current_xmlnode, name_str)
{
//trace(current_xmlnode.nodeName + ":" + name_str);
	// see if this node matches the name string
	if (current_xmlnode.nodeName == name_str)
	{
		// it does, return it
		return current_xmlnode;
	}
	else
	{
		// see if the child is null
		if (current_xmlnode.firstChild ==  null)
		{
			// it is, return null
			return null;
		}
		else
		{
			// it is not, recurse down
			return matchNode(current_xmlnode.firstChild, name_str);
		}
	}
}

// gets the first child node that matches the name
//	current_xmlnode - a node
//	name_str - the name to look for
_global.getFirst = function(current_xmlnode, name_str)
{
	var return_xmlnode:XMLNode;
	
	// loop through the siblings
	for (var node_xmlnode:XMLNode = current_xmlnode;
		 node_xmlnode != null;
		 node_xmlnode = node_xmlnode.nextSibling)
	{
		// look for a match along this node
		return_xmlnode = matchNode(node_xmlnode, name_str);
		
		// see if we found a match
		if (return_xmlnode != null)
		{
			// we did, return it 
			return return_xmlnode;
		}
	}
	
	// could not find a match
	return null;
}

// get the last child node that matches the name. This will recurse down
//	current_xmlnode - a node
//	name_str - the name to look for
_global.getLast = function(current_xmlnode, name_str)
{
	// see if this node matches the name string
	if (current_xmlnode.nodeName == name_str)
	{
		// it does, return it
		return current_xmlnode;
	}
	else
	{
		// not a match, see if there is a last child
		if (current_xmlnode.lastChild != null)
		{
			// there is, recurse down
			return getLast(current_xmlnode.lastChild, name_str);
		}
		else
		{
			// no match
			return null;
		}
	}
}

//Returns a node that matches the name_str
//cur_xmlnode - a node 
//id attribute
_global.matchSiblingNode = function(cur_xmlnode:XMLNode, name_str:String){
	// see if this node matches the name string
	if (cur_xmlnode.nodeName == name_str) {
		// it does, return it
		return cur_xmlnode;
	} else {
		// see if the sibling is null
		if (cur_xmlnode.nextSibling ==  null) {
			// it is, return null
			return null;
		} else {
			// it is not, recurse down
			return matchSiblingNode(cur_xmlnode.nextSibling, name_str);
		}
	}
}

//Returns a node that matches the name_str but search previous sibling
//cur_xmlnode - a node 
//id attribute
_global.matchPreviousSiblingNode = function(cur_xmlnode:XMLNode, name_str:String){
	// see if this node matches the name string
	if (cur_xmlnode.nodeName == name_str) {
		// it does, return it
		return cur_xmlnode;
	} else {
		// see if the sibling is null
		if (cur_xmlnode.previousSibling ==  null) {
			// it is, return null
			return null;
		} else {
			// it is not, recurse down
			return matchPreviousSiblingNode(cur_xmlnode.previousSibling, name_str);
		}
	}
}

function getFirstPage(nextPageSib_xmlnode) {//Used so we can eliminate any hidden pages as the first page.
	//nextPageSib_xmlnode = nextPage_xmlnode.nextSibling;
	// see if the next sibling exists
	if (nextPageSib_xmlnode != null)
	{
		// it does, get the first page for this sibling
		nextPageSib_xmlnode = getFirst(nextPageSib_xmlnode, "page");
	}
	else
	{
		// there is no next sibling, look up through parent topics
		for (var curTopic_xmlnode:XMLNode = nextPage_xmlnode.parentNode;
			 curTopic_xmlnode != null;
			 curTopic_xmlnode = curTopic_xmlnode.parentNode)
		{
			// get the next sibling for this topic
			var nextTopic_xmlnode = curTopic_xmlnode.nextSibling;
			
			// see if this next sibling exists
			if (nextTopic_xmlnode != null)
			{
				// it does, find the fist page in this topic
				nextPageSib_xmlnode = getFirst(nextTopic_xmlnode, "page");
				
				// we found the next node so stop looking
				break;
			}
		}
	}
	//Check to see if page is hidden
	//trace("isTocEntry: " + nextPage_xmlnode.parentNode.attributes.isTocEntry + " - nonNavPage: " + nextPage_xmlnode.attributes.nonNavPage)
	if ((nextPageSib_xmlnode.attributes.nonNavPage.toUpperCase() == "TRUE") || (nextPageSib_xmlnode.parentNode.attributes.showTopicPages.toUpperCase() == "FALSE")){
		return(getFirstPage(nextPageSib_xmlnode.nextSibling))
	} else {
		return(nextPageSib_xmlnode);
	}
}

function getLastPage(prevPageO_xmlnode){
	//Check to see if page is hidden
	//trace("isTocEntry: " + prevPage_xmlnode.parentNode.attributes.isTocEntry + " - nonNavPage: " + prevPage_xmlnode.attributes.nonNavPage)
	if ((prevPageO_xmlnode.attributes.nonNavPage.toUpperCase() == "TRUE") || (prevPageO_xmlnode.parentNode.attributes.showTopicPages.toUpperCase() == "FALSE")){
		prevPage_xmlnode = prevPageO_xmlnode.previousSibling
		// see if their is a previous page in this topic
		//trace(prevPage_xmlnode)
		if (prevPage_xmlnode == null)
		{
			// there is no previous page, look up through parent topics
			for (var curTopic_xmlnode:XMLNode = prevPageO_xmlnode.parentNode;
				 curTopic_xmlnode != null;
				 curTopic_xmlnode = curTopic_xmlnode.parentNode)
			{
				//trace(prevTopic_xmlnode)
				// get the previous sibling for this topic
				var prevTopic_xmlnode = curTopic_xmlnode.previousSibling;
				//trace(prevTopic_xmlnode)
				// see if this previous sibling exists
				if (prevTopic_xmlnode != null)
				{
					// it does, find the last page in this topic
					prevPage_xmlnode = getLast(prevTopic_xmlnode, "page");
					break;
				}
			}
		}
		if(prevPage_xmlnode.nodeName == "topic") {//Is it a topic?
			//trace(currentPage_xmlnode.parentNode);
			// it is, get the last page for the topic
			prevPage_xmlnode = getLast(prevPage_xmlnode, "page");
		}
		return getLastPage(prevPage_xmlnode);
	} else {
		return(prevPageO_xmlnode);
	}
}

