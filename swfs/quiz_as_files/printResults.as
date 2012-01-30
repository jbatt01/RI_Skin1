/*
Flash Companion, Copyright 2004, 2005, 2006, 2008, 2009 Rapid Intake, Inc.

	Player Version:	 	3.1
	Updates:	 		Steven Hancock

	Makes it possible to print quiz results.
	
	- Added ability to send email to server side script
*/
//Establish data variables.
import mx.containers.Window;

var cr:String = "%0d";
var theDate:Date = new Date();

print_btn._visible = false;
email_btn._visible = false;
playerMain_mc.print_btn.tabIndex = 21;
playerMain_mc.email_btn.tabIndex = 22;

var printResultsPG:Boolean = (currentQuiz_xmlnode.attributes.print_results.toUpperCase() == "TRUE");
var emailResultsPG:Boolean = (currentQuiz_xmlnode.attributes.email_results.toUpperCase() == "TRUE");
var incName:Boolean = (currentQuiz_xmlnode.attributes.LMS_name.toUpperCase() == "TRUE");
var incTitle:Boolean = (currentQuiz_xmlnode.attributes.incQuizTitle.toUpperCase() == "TRUE");

var email_win:MovieClip;

//Print the results page.
//Print the progress report.
function printResults(){
	var theDate:Date = new Date();
	
	playerMain_mc.presentation.createTextField("header_txt",playerMain_mc.presentation.getNextHighestDepth(),0,playerMain_mc.presentSizeH - 55,playerMain_mc.presentSizeW,55);
	header_txt.multiline = true;
	header_txt.wordWrap = true;
	header_txt.styleSheet = playerMain_mc.quizCSS;
	header_txt.html = true;
	
	//header32_txt._visible = true;
	
	header_txt.htmlText = "<p class = 'message'>Printed results for the " + playerMain_mc.root_xmlnode.attributes.title + " course. Printed: " + (theDate.getMonth()+1) + "/" + theDate.getDate() + "/" + theDate.getFullYear();
	if (incTitle && incName)
	{
		var theTitle:String = playerMain_mc.currentPage_xmlnode.attributes.title;
		header_txt.htmlText += "\nQuiz: " + theTitle;
		var theName:String = playerMain_mc.scormValue_array[8];
		header_txt.htmlText += "\nResults for: " + theName  + "</p>";
	} else if (incTitle){
		var theTitle:String = playerMain_mc.currentPage_xmlnode.attributes.title;
		header_txt.htmlText += "\nQuiz: " + theTitle   + "</p>";
	} else if (incName) {
		var theName:String = playerMain_mc.scormValue_array[8];
		header_txt.htmlText += "\nResults for: " + theName  + "</p>";
	} else {
		header_txt.htmlText += "</p>";
	}

	//Hide buttons
	print_btn.visible = false;
	email_btn._visible = false
	if (quizReview)	reviewBtn.visible = false;
	//trace("print")
	var pj = new PrintJob();
	var success = pj.start();
	if (success){
		//trace(pj.orientation)
		if (pj.orientation == "portrait"){
			trace("portrait")
			playerMain_mc.presentation._xscale = 70;
			playerMain_mc.presentation._yscale = 70;
		}
		pj.addPage(playerMain_mc.presentation,{xMin:0,xMax:playerMain_mc.presentSizeW,yMin:0,yMax:playerMain_mc.presentSizeH});
		pj.send();
		playerMain_mc.presentation._xscale = 100;
		playerMain_mc.presentation._yscale = 100;
	}
	delete pj;
	//Show buttons
	print_btn._visible = printResultsPG;
	email_btn._visible = emailResultsPG;
	header_txt._visible = false;
	if (quizReview) reviewBtn.visible = true;
}

function sendTheEmail(userName:String,fromEmail:String){
	var headerTxt:String = "Course results for the " + playerMain_mc.root_xmlnode.attributes.title + " course."
	if (incName){
		var theName:String = playerMain_mc.scormValue_array[8];
		var userInfo:String = "User: " + theName;
	}
	if (incTitle)
	{
		var theTitle:String = playerMain_mc.currentPage_xmlnode.attributes.title;
	} 
	var theDate:String = (theDate.getMonth()+1) + "/" + theDate.getDate() + "/" + theDate.getFullYear();
	var dateComplete:String = "Date completed: " + theDate;
	var totCorrect:String = "Total Correct Questions: " + correct_txt.text;
	var totIncorrect:String = "Total Incorrect Questions: " + incorrect_txt.text;
	var percCorrect:String	= "Percent Correct: " + percent;
	var theSubject:String = currentQuiz_xmlnode.attributes.emailSubject;
	var sendEmail:String = currentQuiz_xmlnode.attributes.sendToEmail;
	
	
	var serverEmail:Boolean = currentQuiz_xmlnode.attributes.useServer.toUpperCase() == "TRUE";
	//Create body
	if (!serverEmail)
	{
		var theBody:String = "Make sure you finish sending this email so the results will be sent to the appropriate person.";
	
		for (var i:Number = 1;i<5;i++)
		{
			theBody += cr;
		}
	} else {
		var theBody:String = "";
	}
	
	theBody += (headerTxt + cr + cr);
	if (incTitle)
	{
		theBody += ("Quiz: " + theTitle + cr + cr);
	}
	if (incName){
		theBody += userInfo + cr + cr;
	}
	
	if (serverEmail)
	{
		playerMain_mc.certUserName = userName;
		playerMain_mc.certFromEmail = fromEmail;
		//encrypt data
		var userInfo:String = "Learner: " + userName;
		theBody += userInfo + cr + cr;
		
		var idag = "4/5/20106-7-0910/10/2011" + theDate + "3/4/0911/12/20091-1-12";
		var riktig = "1468790234" + correct_txt.text + "0223859410";
		var ikkerett = "938547012312" + incorrect_txt.text + "7894728301";
		var fin = "01293847563459" + percent + "6758102938"; 
	} else {
	
		theBody += dateComplete + cr + cr;
		theBody += totCorrect + cr;
		theBody += totIncorrect + cr;
		theBody += percCorrect + cr + cr;
	}

	if (!serverEmail)
	{
		getURL('mailto:' + sendEmail + '?subject=' + theSubject + '&body=' + theBody);
	} else {
		//Close window
		email_win.deletePopUp();
		var serverLoc:String = currentQuiz_xmlnode.attributes.serverURL;
		if (serverLoc === undefined || serverLoc == null || serverLoc == "")
			serverLoc = "http://www.rapidintake.net/send_email.asp";
		//Add server code stuff
		if (fromEmail == "" || fromEmail === undefined || fromEmail == null)
			fromEmail = "none_entered@rapidintake.com";
		getURL(serverLoc + "?From=" + fromEmail + "&To=" + sendEmail + "&Subject=" + theSubject + "&Body=" + theBody + "&idag=" + idag + "&riktig=" + riktig + "&ikkerett=" + ikkerett + "&fin=" + fin,"_blank")
	}
}

function sendEmail(){
	// Instantiate Window.
	email_win = mx.managers.PopUpManager.createPopUp(_level0, Window, true, {closeButton:true,title:"Enter Name", contentPath:"swfs/emailForm.swf"});
	email_win.setSize(300, 210);
	email_win._x = 400;
	email_win._y = 200;
	var winListener:Object = new Object();
	winListener.click = function() {
		 email_win.deletePopUp();
	};
	email_win.addEventListener("click", winListener);

/*
	
	*/
}

var the_node_xmlnode:XMLNode = matchSiblingNode(currentQuiz_xmlnode.firstChild,"printMessage")
	//trace(the_node_xmlnode);
	//if found return the value
if (the_node_xmlnode != null && the_node_xmlnode !== undefined) {
	print_instruct_txt.html = true;
	print_instruct_txt.styleSheet = playerMain_mc.quizCSS;
	print_instruct_txt.htmlText = "<p class = 'message'>" + the_node_xmlnode.firstChild.nodeValue + "</p>";
} else {
	print_instruct_txt.text = "";
}

if (printResultsPG)
{
	print_btn.setStyle("color",buttonC);
	print_btn.setStyle("buttonColor",buttonColor);
	
	
	print_btn._visible = true;
	print_btn.labelPath.styleSheet = playerMain_mc.quizCSS;
	print_btn.labelPath.html = true;
	print_btn.labelPath.htmlText = "<p class='buttontext'>Print Results</p>";

	print_btn.addEventListener("click", printResults);
}

if (emailResultsPG)
{
	email_btn.setStyle("color",buttonC);
	email_btn.setStyle("buttonColor",buttonColor);
	
	email_btn._visible = true;
	email_btn.labelPath.styleSheet = playerMain_mc.quizCSS;
	email_btn.labelPath.html = true;
	email_btn.labelPath.htmlText = "<p class='buttontext'>Email Results</p>";
	
	var serverEmail:Boolean = currentQuiz_xmlnode.attributes.useServer.toUpperCase() == "TRUE";
	if (serverEmail)
	{
		email_btn.addEventListener("click", sendEmail);
	} else {
		email_btn.addEventListener("click", sendTheEmail);
	}
}

if (printResultsPG && emailResultsPG)
{
	//Move the buttons so they line up correctly.
	
	email_btn.move(email_btn.x - 50,email_btn.y);
	print_btn.move(print_btn.x - 50,print_btn.y);
} else if (emailResultsPG) {
	email_btn.move(reviewBtn.x,email_btn.y)
}
