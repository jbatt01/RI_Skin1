stop();
var certType:String = playerMain_mc.currentPage_xmlnode.attributes.certificate;
var promptName:Boolean = (playerMain_mc.currentPage_xmlnode.attributes.promptForName == "true");
var nameReceived:Boolean = false;

//Gather Data
var personsName:String = playerMain_mc.scormValue_array[8];
if (personsName === undefined) 
{
	personsName = "";
}
else if (personsName.indexOf(",") > -1)
{
	var nameParts:Array = new Array();
	nameParts = personsName.split(",");
	personsName = nameParts[1] + " " + nameParts[0];//.substr(nameParts[1].indexOf(" "))
	if (personsName.charAt(0) == " ")
	{
		personsName = personsName.slice(1);
	}
}

var courseName:String = playerMain_mc.root_xmlnode.attributes.title;
if (courseName === undefined) courseName = "";
var a_node_xmlnode:XMLNode = matchSiblingNode(playerMain_mc.currentPage_xmlnode.firstChild,"courseDescription");
var courseDesc:String = a_node_xmlnode.firstChild.nodeValue;
var theDate:Date = new Date();
var todaysDate:String = (theDate.getMonth()+1) + "/" + theDate.getDate() + "/" + theDate.getFullYear();
a_node_xmlnode = matchSiblingNode(playerMain_mc.currentPage_xmlnode.firstChild,"courseContact");
var courseContact:String = a_node_xmlnode.firstChild.nodeValue;
//Set size data for resizing
var origSizeW:Number = 642;// + 10;//+ 10 for position
var origSizeH:Number = 496;// + 10;//+ 10 for position
var presentSizeW:Number = playerMain_mc.presentSizeW;
var presentSizeH:Number = playerMain_mc.presentSizeH;
//trace(presentSizeW + " ---- " + presentSizeH)
//Check for certificate
this.createEmptyMovieClip("checkCert_mc",this.getNextHighestDepth());
checkCert_mc.onEnterFrame = function(){
	if (certificate_mc){
		delete checkCert_mc.onEnterFrame;
		setUpCertificate();
	}
}

//For page complete function
var usePageComplete:Boolean = playerMain_mc.root_xmlnode.attributes.pageComplete.toLowerCase() == "true";
if (usePageComplete)
{
	playerMain_mc.apiPageComplete();
}

function setUpCertificate() {
	certificate_mc.populateFields(personsName,todaysDate,courseName,courseContact,courseDesc)
	if (certType.toLowerCase() == "upload")
	{
		var artPath:String = playerMain_mc.currentPage_xmlnode.attributes.certificateFileName;
		certificate_mc.loadArt(artPath)
	}
	var logoFilePath:String = playerMain_mc.currentPage_xmlnode.attributes.logoFilePath;
	if (certType.toLowerCase() == "bluecert")
	{
		if (logoFilePath !== undefined)
			certificate_mc.loadLogo(logoFilePath,210,75);
	}
	if (certType.toLowerCase() == "greencert")
	{
		if (logoFilePath !== undefined)
			certificate_mc.loadLogo(logoFilePath,130,46);
	}
	certificate_mc.resize(origSizeW,origSizeH,presentSizeW,presentSizeH)
	print_cert_btn.certificate = certificate_mc.certificate;
	print_cert_btn.addEventListener("click", certificate_mc.print);
}

//Go to that certificate
//trace("certType: " + certType)
var restrictCert:Boolean = (playerMain_mc.currentPage_xmlnode.attributes.restrictCertificate.toLowerCase() == "true");
var restrictType:String = playerMain_mc.currentPage_xmlnode.attributes.restrict_type;
if (restrictType.toLowerCase() == "visit")
	restrictType = "visit";

	
if (restrictCert)
{
	if (restrictType == "visit")
	{
		var indexObj:Object = playerMain_mc.topic_index_shell.getScrollContent();
		trace(indexObj.visited_array)
		var compStat:Boolean = doCompletion(indexObj.visited_array.join(",") + ":" + "0" + ":" + indexObj.selectable_array.join(","));
		if (compStat)
		{
			goToCertificate();//this.gotoAndStop(certType);
		}
		else 
		{
			this.gotoAndStop("error")
		}
	}
	else
	{
		//if (playerMain_mc.scormValue_array[4] == "passed")//
		if (playerMain_mc.scormValue_array[4] == "completed" || playerMain_mc.scormValue_array[4] == "passed")
		{
			playerMain_mc.apiSetCompletion(true,"completed");
			goToCertificate();//this.gotoAndStop(certType);
		}
		else
		{
			this.gotoAndStop("error")
		}
	}
}
else
{
	goToCertificate();//this.gotoAndStop(certType);
}


function goToCertificate()
{
	if (promptName && !nameReceived)
	{
		this.gotoAndStop("name");
	} else {
		this.gotoAndStop(certType);
	}
}

//Check completion

//Cycles through visited array to chec completion
function doCompletion(sValue){
	// break it apart (visited array)
	var suspend_array:Array = sValue.split(":");
	var visit_array:Array = suspend_array[0].split(",");
	if (visit_array.length > 0) {
		var course_complete:Boolean = true;
		for (i = 0;i < visit_array.length;i++){
			//Has the page been visited?
			if (visit_array[i] != "1"){
				course_complete = false;
			}
		}
	} else {
		var course_complete:Boolean = false;//default to not complete if array doesn't exist;
	}
	//trace(visit_array);
	//trace(course_complete);
	return course_complete;
	/*if (course_complete){//Every page visited?
		apiSetCompletion(true,completion);//record it
	}*/
}