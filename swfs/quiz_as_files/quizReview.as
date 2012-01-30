/*
Flash Companion, Copyright 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Reviewing quizzes.
*/

stop();

var asLetters = new Array( 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h' );
	
review_txt.html = true;
var cssBlock = new TextField.StyleSheet();
cssBlock.setStyle( "embedFonts", "true" );
cssBlock.setStyle( ".correctmark", {fontStyle:'italic',fontSize:'18px',color:'#00ff00'} );
cssBlock.setStyle( ".incorrectmark", {fontWeight:'bold',fontSize:'18px',color:'#ff0000'} );
cssBlock.setStyle( ".questionnum", {fontStyle:'italic' } );
cssBlock.setStyle( ".question", {fontStyle:'italic',color:'#999999' } );
cssBlock.setStyle( ".categories", {fontWeight:'bold',fontSize:'14px',textDecoration:'underline' } );
review_txt.styleSheet = cssBlock;
correct_txt.text = correct + ' of ' + SessionArray.length + ' correct';
score_txt.text = 'score ' + percent + '%';


//Show Retake Button?
var retakeButton:Boolean = (currentQuiz_xmlnode.attributes.incRetakeButton.toLowerCase() == "true");
if (retakeButton) {
	retakeBtn._visible = true;
	retakeBtn.labelPath.styleSheet = playerMain_mc.quizCSS;
	retakeBtn.labelPath.html = true;
	retakeBtn.labelPath.htmlText = "<p class='buttontext'>Retake Test</p>";
} else {
	retakeBtn._visible = false;
}


//retake button
retakeBtn.onPress = function(){
	for (var y:Number = 0;y < SessionArray.length; y++){
		delete SessionArray[y].aResponseOrder;
	}
	delete aResponseOrder;
	delete SessionArray;// = null;
	gotoAndPlay(1);
	resetNavButtonsOnRetake();
}


function resetNavButtonsOnRetake(){
	playerMain_mc.next_mc.enabled = true;
	playerMain_mc.next_mc.gotoAndStop("up");
}


var sReviewFeedback:String = '';

for ( var i:Number = 0 ; i < SessionArray.length; i++ )
{
	sCorrect = ( SessionArray[i].result == 'C' ) ?  '<span class="correctmark">Correct</span>' : '<span class="incorrectmark">Incorrect</span>' ; 
	sReviewFeedback += '<p class="questionnum">Question ' + ( i + 1 ) + ' of ' + SessionArray.length + '   -    ' + sCorrect + '</p>';
	sReviewFeedback += '<p class="question">' + SessionArray[i].question + '</p>';

	sReviewFeedback += buildFoilsAndStudentResponse( i );

	sReviewFeedback += '<br>';

	if ((( SessionArray[i].result == 'C' ) && ( this.currentQuiz_xmlnode.attributes.showCorrect == 'true' )) || ( SessionArray[i].result == 'W' ) || ( SessionArray[i].result == undefined ) )
	{
		sReviewFeedback += getCorrectAnswerStatement( i );
	}
	sReviewFeedback += '--------------------------------------------------------------------------------------------<br><br><br>';
	
}

review_txt.text = sReviewFeedback;




function buildFoilsAndStudentResponse( i:Number )
{
	var sFoils = '<p>&nbsp;</p><p>Your answers were:</p>';
	if (( ( SessionArray[i].interaction_type == 'C' ) && ( SessionArray[i].hot_objects ==  undefined ))  || ( SessionArray[i].interaction_type == 'T' ))					// C is multiple choice and multiple correct, T is true/false
	{
		var sLetter = '';		
		var anSelectedFoils:Array = new Array();
		var anCorrectFoils:Array = new Array();	
		if ( SessionArray[i].interaction_type == 'C' )
		{
			anSelectedFoils = getFoilNumbersFromLetters( SessionArray[i].student_response );
			anCorrectFoils = getFoilNumbersFromLetters( SessionArray[i].correct_response );
		}
		else	// it's a true/false and will only have one answer
		{
			anSelectedFoils[0] = getFoilNumberFromResponseText( i ) ;
			anCorrectFoils[0] = ( SessionArray[i].correct_response ) ? 0 : 1 ;
		}
		
		if (SessionArray[i].distractor_labels !== undefined){
			var k:Number = 0;																										// we'll use this to manually increment through the anSelectFoils based on there being a match																							// we'll use this to manually increment through the anCorrectFoils based on there being a match
			for ( var j:Number = 0; j < SessionArray[i].distractor_labels.length; j++ )
			{				
				if (( SessionArray[i].distractor_labels[j] != undefined ) && ( SessionArray[i].distractor_labels[j] != '' ) &&  ( j == anSelectedFoils[k]  ))	// is the current foil one that was selected by the student?
				{		
					var bCorrect = false;
					trace("legnth: " + anCorrectFoils.length)
					for ( var l:Number = 0; l < anCorrectFoils.length; l++ )
					{
						trace("j: " + j + " - " + anCorrectFoils[l])
						if ( j == anCorrectFoils[l] )																					// now we know it was selected, was it supposed to be? If so put a checkmark and increment to the next correctanswer, if not put an X
						{
							var sFdbkMark:String = '<span class="correctmark">C</span>';
							bCorrect = true;
							break;
						}
					}
					
					if ( !bCorrect )
					{
						var sFdbkMark:String =   '<span class="incorrectmark">X</span>' ;		
					}
				
					sLetter = ( SessionArray[i].interaction_type != 'T' ) ? asLetters[j] + '. ' : ''; 
					//trace(sLetter);
					sFoils += '<p>' + sFdbkMark + ' ' + sLetter +  '&nbsp;&nbsp;' + SessionArray[i].distractor_labels[j] + '</p>';				// write out the feedback mark plus the text for the foil	
					
					if ( k < anSelectedFoils.length - 1 )																				// if there are more student selected foils increment the counter so next loop through we can use the next foil
					{
						k++;
					}	
				}
				else if (( SessionArray[i].distractor_labels[j] != undefined ) && ( SessionArray[i].distractor_labels[j] != '' ))  
				{
					sLetter = ( SessionArray[i].interaction_type != 'T' ) ? asLetters[j] + '. '  : '';
					sFoils += '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + sLetter + '&nbsp;&nbsp;' + SessionArray[i].distractor_labels[j] + '</p>';				
				}
			}	
		} else {
			for (var n:Number = 0; n < anCorrectFoils.length;n++){
				var bCorrect = false;
				for ( var l:Number = 0; l < anSelectedFoils.length; l++ )
				{
					if ( anCorrectFoils[n] == anSelectedFoils[l] )																					// now we know it was selected, was it supposed to be? If so put a checkmark and increment to the next correctanswer, if not put an X
					{
						var sFdbkMark:String = '<span class="correctmark">C</span>';
						bCorrect = true;
						break;
					}
				}
				
				if ( !bCorrect )
				{
					var sFdbkMark:String =   '<span class="incorrectmark">X</span>' ;		
				}
				if (isNaN(anSelectedFoils[n])){
					sFoils += '<p>&nbsp;</p>';//Question not answered.
				} else {
					sFoils += '<p>&nbsp;' + sFdbkMark + '&nbsp;&nbsp;Object:&nbsp;&nbsp;' + (anSelectedFoils[n] + 1) + '</p>';
					
				}
			}
			
		}
	}
	else if (( SessionArray[i].interaction_type == 'C' ) && ( SessionArray[i].hot_objects !=  undefined ))
	{
		var anSelectedFoils:Array = getFoilNumbersFromLetters( SessionArray[i].student_response );
		var anCorrectFoils:Array = getFoilNumbersFromLetters( SessionArray[i].correct_response );
		
		var Question_xmlnode = null;
		for ( var z:Number = 0; z < this.currentQuiz_xmlnode.childNodes.length; z++ )
		{
			if (( this.currentQuiz_xmlnode.childNodes[z].attributes.id  != undefined ) && ( this.currentQuiz_xmlnode.childNodes[z].attributes.id == SessionArray[i].interaction_id ))
			{
				Question_xmlnode = this.currentQuiz_xmlnode.childNodes[z];	
			}
		}

		if ( Question_xmlnode.attributes.qtype.toUpperCase() == 'HOIMAGE' ){
		
			var k:Number = 0;																										// we'll use this to manually increment through the anSelectFoils based on there being a match																							// we'll use this to manually increment through the anCorrectFoils based on there being a match
			for ( var j:Number = 0; j < SessionArray[i].aResponseOrder.length; j++ )
			{							
				if  ( j == anSelectedFoils[k]  )																						// is the current foil one that was selected by the student?
				{					
					var bCorrect = false;
					for ( var l:Number = 0; l < anCorrectFoils.length; l++ )
					{
						if ( j == anCorrectFoils[l] )																					// now we know it was selected, was it supposed to be? If so put a checkmark and increment to the next correctanswer, if not put an X
						{
							var sFdbkMark:String = '<span class="correctmark">C</span>';
							bCorrect = true;
							break;
						}
					}
					
					if ( !bCorrect )
					{
						var sFdbkMark:String =   '<span class="incorrectmark">X</span>' ;		
					}
				

					sFoils += '&nbsp;' + sFdbkMark + '&nbsp;&nbsp;<img src=\'' + SessionArray[i].aResponseOrder[j].attributes.filepath + '\' height=\'100%\' width=\'100%\' ><br><br><br><br><br><br><br><br>';		// write out the feedback mark plus the text for the foil
					
					if ( k < anSelectedFoils.length - 1 )																				// if there are more student selected foils increment the counter so next loop through we can use the next foil
					{
						k++;
					}	
				}
			}	
		} else { //HO1 question instead of Image multiple choice.
		
			for (var n:Number = 0; n < anSelectedFoils.length; n++){
				var bCorrect = false;
				for ( var l:Number = 0; l < anCorrectFoils.length; l++ )
				{
					if ( anSelectedFoils[n] == anCorrectFoils[l] )																					// now we know it was selected, was it supposed to be? If so put a checkmark and increment to the next correctanswer, if not put an X
					{
						var sFdbkMark:String = '<span class="correctmark">C</span>';
						bCorrect = true;
						break;
					}
				}
				if ( !bCorrect )
				{
					var sFdbkMark:String =   '<span class="incorrectmark">X</span>' ;		
				}
				if (anSelectedFoils[n] == undefined){
					sFoils += '<p>&nbsp;</p>';//Question not answered
				} else {
					sFoils += '<p>&nbsp;' + sFdbkMark + '&nbsp;&nbsp;Object:&nbsp;&nbsp;' + (anSelectedFoils[n] + 1) + '</p>';
				}
			}
		}
	}	
	else if ( SessionArray[i].interaction_type == 'F' )																				// F is fill in the blank
	{
		var sCorrectness:String = ( SessionArray[i].result == 'W' ) ? '<span class="incorrectmark">X</span>' : ( SessionArray[i].result == undefined ) ? '  ' : '<span class="correctmark">C</span>' ;
		var sIndicator:String = sCorrectness;
		var sResponse:String = SessionArray[i].student_response.substring( 1, SessionArray[i].student_response.length - 1 );
		if (sResponse == undefined){
			sResponse = ""
		}
		sFoils += '<p>&nbsp;' + sIndicator + '&nbsp;&nbsp;' + sResponse + '</p>';
	}
	else if ( SessionArray[i].interaction_type == 'M' )																				// M is DragNDrop matching
	{
		//  SessionArray[i].correct_response is a string in the form {1.a,2.b,3.b,4.a} which means foil #1 should be in the 'a' column or 'a' target, foil 2 in the 'b' column/target, etc.. SessionArray[i].student_response 
		//  is also in this format with the caveat that if the student failed to match one of the foils it will simply not be listed - e.g. if they didn't match foil #3 then 
		//  SessionArray[i].student_response will be {1.a,2.b,4.a}. There are also instances in which the brackets are not included and the contents aren't a string. 
		//
		//  We will caste it to a string (just in case), then we will remove the brackets if they are there. Next we will split both correct_response and student_response into arrays, then reverse each element from the form Number.Letter to Letter.Number
		//  In the case of student_response we need to determine if there are any columns/targets not represented in the array. If so, in the corresponding array index put in a null

		var sTemp = SessionArray[i].correct_response.toString();
		sTemp = (( sTemp.indexOf != undefined ) && ( sTemp.indexOf( '{' ) != undefined ) && ( sTemp.indexOf( '{' ) != -1 )) ? sTemp.substring( 1, sTemp.length - 1 ) : sTemp ; 			// Strip off the { and } from the string if they are present. If they are not present, for some reason the function that builds this, doesn't build it as a string
		var anCorrectReponses:Array =  sTemp.split( ',' );																				// This will produce array elements such as 1.a  and 2.b. Later we take the number and period off, leaving just the letter 'a' or 'b' meaning column 1 or 2. We'll then convert 'a' or 'b' to 1 or 2 respectively.
			
		sTemp = SessionArray[i].student_response.toString();
		sTemp = (( sTemp.indexOf != undefined ) && ( sTemp.indexOf( '{' ) != undefined ) && ( sTemp.indexOf( '{' ) != -1 )) ? sTemp.substring( 1, sTemp.length - 1 ) : sTemp ; 			// Strip off the { and } from the string if they are present
		var asTempStudntRspns = new Array();
		
		if (( sTemp.indexOf != undefined ) && ( sTemp.indexOf( ',' ) != undefined ))
		{
			asTempStudntRspns = sTemp.split( ',' );
		}
		else
		{
			asTempStudntRspns[0] = sTemp;
		}


		for ( var j:Number = 0; j < asTempStudntRspns.length; j++ )
		{
			if ( asTempStudntRspns[j].indexOf( 'k' ) != -1 )
			{
				asTempStudntRspns[j] = asTempStudntRspns[j].substring( 1, asTempStudntRspns[j].length ); 
			}
		}

		// for DragNDrops there are various pieces of information not stored in the SessionArray or other objects so we need to go back to the xml and get it from there. Determine the xml question node that goes with this SessionArray object		
		var Question_xmlnode = null;
		for ( var j:Number = 0; j < this.currentQuiz_xmlnode.childNodes.length; j++ )
		{
			if (( this.currentQuiz_xmlnode.childNodes[j].attributes.id  != undefined ) && ( this.currentQuiz_xmlnode.childNodes[j].attributes.id == SessionArray[i].interaction_id ))
			{
				Question_xmlnode = this.currentQuiz_xmlnode.childNodes[j];	
			}
		}

		if ( Question_xmlnode.attributes.qtype.toUpperCase() == 'DDTASK' )
		{
			// The numbering of the columns changes based on which matchelement attribute the first textelement has. So if the first element matches to column two/b, two/b becomes one/a. Compensate for this below
			var nHeaderA;
			var nHeaderB;
			if ( SessionArray[i].aResponseOrder[0].attributes.matchelement == Question_xmlnode.attributes.target1 )
			{
				nHeaderA = 1;
				nHeaderB = 2;
			}
			else
			{
				nHeaderA = 2;
				nHeaderB = 1;
			}


			var anStudentReponses:Array = new Array();
			var k:Number = 0;
			for ( var j:Number = 0; j < anCorrectReponses.length; j++ )																// We'll look through the asTempStudntRspns but because there might be values missing if the student failed to match a foil, use anCorrectReponses.length
			{
				if (( asTempStudntRspns[k].split( '.' )[0] != undefined ) && ( j + 1 == parseInt( asTempStudntRspns[k].split( '.' )[0] ) ))			// Get the number from the left hand side of the period and see if it's the next one sequentially. If so, we'll grab the value on the right hand side of the period. If not then we'll assign null
				{
					sTemp = asTempStudntRspns[k].split( '.' )[1];			
					anStudentReponses[j] = ( sTemp == 'a' ) ? nHeaderA : nHeaderB;			
					k++;
				}
				else
				{
					anStudentReponses[j] = null;		
				}
				
				sTemp = anCorrectReponses[j].split( '.' )[1];																		// change values from the format '1.a' to simply 'a'
				anCorrectReponses[j] = ( sTemp == 'a' ) ? nHeaderA : nHeaderB;
			}
			if ( Question_xmlnode != null ) 
			{		
				var nNumberOfPossibleTargets:Number = 2;
				var asGroups:Array = new Array();																				// this will become a multidimensional array - 1 array for each target with the target as element 0 of it's array and the items matched to it as the later items 
            	
				for ( var k:Number = 1; k <= nNumberOfPossibleTargets; k++)
				{		
					if ( eval( "Question_xmlnode.attributes.target" + k ) != undefined )
					{
						asGroups[k-1] = new Array();
						asGroups[k-1][0] = eval( "Question_xmlnode.attributes.target" + k );
						sFoils += '<p>&nbsp;</p><p>&nbsp;&nbsp;&nbsp;&nbsp;<span class="categories">' + asGroups[k-1][0] + '</span></p>';						 
						for ( var l:Number = 0; l < SessionArray[i].aResponseOrder.length; l++ )
						{							
							if ( anStudentReponses[l] == k )		// in the DDTask the 
							{			
								var sCorrectness:String = ( anStudentReponses[l] != anCorrectReponses[l] ) ? '<span class="incorrectmark">X</span>' : '&nbsp;&nbsp;&nbsp;&nbsp;' ;
								var sIndicator:String = sCorrectness;
								asGroups[k-1][asGroups[k-1].length] = SessionArray[i].aResponseOrder[l].firstChild.nodeValue;
								sFoils += '<p>&nbsp;' + sIndicator + '&nbsp;&nbsp;' + asGroups[k-1][asGroups[k-1].length-1]  + '</p>';
							}
						}
					}
				}
			}	
		}
		else if  ( Question_xmlnode.attributes.qtype.toUpperCase() == 'DDNUM' )
		{
			for ( var j:Number = 0; j < asTempStudntRspns.length; j++)
			{
				if ( asTempStudntRspns[j] != undefined )
				{
					asTempStudntRspns[j] = stringReverse( asTempStudntRspns[j] );
				}	
			}

			for ( var j:Number = 0; j < anCorrectReponses.length; j++ )	
			{
				anCorrectReponses[j] = stringReverse( anCorrectReponses[j] );
			}

			var anStudentReponses:Array = new Array();
			var bLetterIsPresent:Boolean;
			for ( var j:Number = 0; j < anCorrectReponses.length; j++ )																// We'll look through the asTempStudntRspns but because there might be values missing if the student failed to match a foil, use anCorrectReponses.length
			{	
				var sToFind = anCorrectReponses[j].split( '.' )[0];																	// get a foil number
				
				bLetterIsPresent = false;
				for ( var k:Number = 0; k < asTempStudntRspns.length; k++)															// loop through the student responses to see if the column letter we're looking for is present 
				{					
					if ( ( asTempStudntRspns[k].split( '.' )[0] != undefined ) && ( sToFind == asTempStudntRspns[k].split( '.' )[0] ) )			// it is!
					{ 						
						anStudentReponses[j] = asTempStudntRspns[k];															// get the value						
						bLetterIsPresent = true;
						break;
					}
				}
				if ( !bLetterIsPresent )																							// after looping through all the student responses, the foil number was not present, so set value to null	
				{
					anStudentReponses[j] = asLetters[j] + '.' +  null;
				}
			}
			
			
			anStudentReponses.sort();
			anCorrectReponses.sort();
			
			for ( var j = 0; j < SessionArray[i].aResponseOrder.length; j++ )
			{
				var sCorrectness:String = ( anStudentReponses[j] != anCorrectReponses[j] ) ? '<span class="incorrectmark">X</span>' : '&nbsp;&nbsp;&nbsp;' ;
				var sIndicator:String = sCorrectness;
					
				var sResponse:String = (( anStudentReponses[j].split( '.' )[1]  == 'null' ) || ( anStudentReponses[j].split( '.' )[1]  == undefined )) ? ' &nbsp;' : anStudentReponses[j].split( '.' )[1] ;	
				sFoils += '<p>&nbsp;' + sIndicator + '&nbsp;&nbsp;' + sResponse + ' -- ' + SessionArray[i].aResponseOrder[j].firstChild.nodeValue  + '</p>';
			}
		} else {
			for ( var j:Number = 0; j < asTempStudntRspns.length; j++)
			{
				if ( asTempStudntRspns[j] != undefined )
				{
					asTempStudntRspns[j] = stringReverse( asTempStudntRspns[j] );
				}	
			}

			for ( var j:Number = 0; j < anCorrectReponses.length; j++ )	
			{
				anCorrectReponses[j] = stringReverse( anCorrectReponses[j] );
			}

			var anStudentReponses:Array = new Array();
			var bLetterIsPresent:Boolean;
			for ( var j:Number = 0; j < anCorrectReponses.length; j++ )																// We'll look through the asTempStudntRspns but because there might be values missing if the student failed to match a foil, use anCorrectReponses.length
			{	
				var sToFind = anCorrectReponses[j].split( '.' )[0];																	// get a foil number
				
				bLetterIsPresent = false;
				for ( var k:Number = 0; k < asTempStudntRspns.length; k++)															// loop through the student responses to see if the column letter we're looking for is present 
				{					
					if ( ( asTempStudntRspns[k].split( '.' )[0] != undefined ) && ( sToFind == asTempStudntRspns[k].split( '.' )[0] ) )			// it is!
					{ 						
						anStudentReponses[j] = asTempStudntRspns[k];															// get the value						
						bLetterIsPresent = true;
						break;
					}
				}
				if ( !bLetterIsPresent )																							// after looping through all the student responses, the foil number was not present, so set value to null	
				{
					anStudentReponses[j] = asLetters[j] + '.' +  null;
				}
			}
			
			
			anStudentReponses.sort();
			anCorrectReponses.sort();
			
			for ( var j = 0; j < anCorrectReponses.length; j++ )
			{
				var sCorrectness:String = ( anStudentReponses[j] != anCorrectReponses[j] ) ? '<span class="incorrectmark">X</span>' : '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' ;
				var sIndicator:String = sCorrectness;
					
				var sResponse:String = (( anStudentReponses[j].split( '.' )[1]  == 'null' ) || ( anStudentReponses[j].split( '.' )[1]  == undefined )) ? ' &nbsp;' : anStudentReponses[j].split( '.' )[1] ;	
				var sTarget:String = (( anStudentReponses[j].split( '.' )[0]  == 'null' ) || ( anStudentReponses[j].split( '.' )[0]  == undefined )) ? ' &nbsp;' : anStudentReponses[j].split( '.' )[0] ;
				sFoils += '<p>&nbsp;' + sIndicator + '&nbsp;&nbsp;Drag object: ' + sResponse + ' -- ' + 'Target object: ' + sTarget  + '</p>';
			}
		}
	}

	sFoils += '<p>&nbsp;</p>';
	return sFoils;
}



function stringReverse( sIn:String )
{
	var sReverse:String = '';
	for ( var i:Number = sIn.length - 1; i >= 0; i-- )
	{	
		sReverse += '' + sIn.charAt( i );	
	}	
	return sReverse; 
}



function getCorrectAnswerStatement( i:Number )
{
	if (( SessionArray[i].interaction_type == 'C' ) && ( SessionArray[i].hot_objects ==  undefined )) 
	{
		var Question_xmlnode = null;
		for ( var j:Number = 0; j < this.currentQuiz_xmlnode.childNodes.length; j++ )
		{
			if (( this.currentQuiz_xmlnode.childNodes[j].attributes.id  != undefined ) && ( this.currentQuiz_xmlnode.childNodes[j].attributes.id == SessionArray[i].interaction_id ))
			{
				Question_xmlnode = this.currentQuiz_xmlnode.childNodes[j];	
			}
		}


		if ( Question_xmlnode != null )
		{	
			if (SessionArray[i].correct_response != undefined){
				if ( Question_xmlnode.attributes.qtype.toUpperCase() == 'MC' || Question_xmlnode.attributes.qtype.toUpperCase() == 'MCH'){
					var anCorrectFoils:Array = getFoilNumbersFromLetters( SessionArray[i].correct_response );
				
					if ( anCorrectFoils.length > 1 )
					{
						return '<p>Correct Answers: ' + SessionArray[i].correct_response.substring( 1, SessionArray[i].correct_response.length - 1 ) + '</p>';			
					}
					else
					{
						return '<p>Correct Answer: ' + SessionArray[i].correct_response + '</p>';
					}
				} else {
					var anCorrectFoils:Array = getFoilNumbersFromLetters( SessionArray[i].correct_response );
					if (anCorrectFoils[0] != undefined){
						return '<p>Correct Answer: Object:   ' + (anCorrectFoils[0]+1) + '</p>';
					} else{
						return '<p>The question was not answered.</p>';
					}
					
				}
			} else {
				return '<p>The question was not answered.</p>';
			}
		}

	}
	else if (( SessionArray[i].interaction_type == 'C' ) && ( SessionArray[i].hot_objects !=  undefined )) 
	{
		var anCorrectReponses:Array = getFoilNumbersFromLetters( SessionArray[i].correct_response );
		var sCorrectAnswer = ( anCorrectReponses.length > 1 ) ? '<br><br>The Correct Answers are:<br>' : '<br><br>The Correct Answer is:<br>';
		trace("aRespo: " + SessionArray[i].aResponseOrder)
		if (SessionArray[i].aResponseOrder!==undefined){
			
			for ( var j:Number = 0; j < anCorrectReponses.length; j++ )
			{ 
				if (anCorrectReponses[j] == null){
					sCorrectAnswer = '<p>The question was not answered.</p>'
				} else {
					sCorrectAnswer += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src=\'' + SessionArray[i].aResponseOrder[ anCorrectReponses[j] ].attributes.filepath + '\'><br><br><br><br><br><br><br><br>';
				}
			}	
		} else {//HO1 question instead of Image multiple choice
			for ( var j:Number = 0; j < anCorrectReponses.length; j++ )
			{ 
				if (anCorrectReponses[j] == null){
					sCorrectAnswer = '<p>The question was not answered.</p>'
				} else {
					sCorrectAnswer += '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Object:&nbsp;&nbsp;' +(anCorrectReponses[j]+1)+'</p><br><br>';
				}
			}
		}
		/*if (SessionArray[i].correct_response == undefined || isNaN(SessionArray[i].correct_response)){
			sCorrectAnswer = '<p>The question was not answered.</p>'
		} */
		return sCorrectAnswer;
	}
	else if ( SessionArray[i].interaction_type == 'T' )
	{	
		return '<p>Correct Answer: ' + SessionArray[i].correct_response + '</p>';
	}
	else if ( SessionArray[i].interaction_type == 'F' )
	{
		// Here is how the final output should read for this interaction_tpe based on the give conditions:
		// If there is 1 correct answer:  	 Correct Answer: ABC
		// If there are 2 correct answers:   Correct Answers are: "ABC" or "ABC"							-- note there is no comma just an "or"
		// If there are 3 correct answers:   Correct Answers are: "ABC", "ABC", or "ABC"					-- note there are commas between items _with_ a comma before the "or" and the last item

		// get the list of answers, which is a string, and remove the leading and trailing curly brace
		var sTemp:String = SessionArray[i].correct_response.substring( 1, SessionArray[i].correct_response.length - 1 );
		// first we need to weed out '' (blanks) and 'undefined's from the answer pool 
		var asTemp:Array = sTemp.split( ',' );// temp array to hold all portions of the correct_response string 
		var asAnswers:Array = new Array();																						// real answers array, will only hold valid answers
		var j:Number = 0;
		for ( var i:Number = 0; i < asTemp.length; i++ )
		{
			if (( asTemp[i] != '' ) && ( asTemp[i] != 'undefined' ) && ( asTemp[i] != 'null' ))																		// if there is a value... ('undefined' comes from the correct_response string and will therefore be a string, not a keyword)
			{
				asAnswers[j] = asTemp[i];
				j++
			}
		}
		
		// now figure out the possible variations for the final output based on the number of answers
		var sCorrectAnswer:String = '';
		
		if ( asAnswers.length == 1 ) 
		{
			sCorrectAnswer = '<p>Correct Answer: ' + asAnswers[0] + '</p>';
		}
		else if ( asAnswers.length == 2 ) 
		{
			sCorrectAnswer = '<p>Correct Answers are: "' + asAnswers[0] + '" or "' + asAnswers[1] + '"</p>';
		}
		else
		{
			var sTemp:String = '"';
			for ( var i:Number = 0; i < asAnswers.length - 2; i++ )
			{
				sTemp += asAnswers[i] + '", "';
			}
			sTemp += asAnswers[asAnswers.length - 2] + '", or "' + asAnswers[asAnswers.length - 1] + '"';
			
			sCorrectAnswer = '<p>Correct Answers are: ' + sTemp + '</p>';
		}
		
		return sCorrectAnswer;
	}	
	else if ( SessionArray[i].interaction_type == 'M' )																				// M is DragNDrop matching
	{
		// For DragNDrops the text of the dragable items and the targets are not in the SessionArray object so we need to go back to the xml and get it from there. Find the xml question node that corresponds to this SessionArray object
		var Question_xmlnode = null;
		for ( var j:Number = 0; j < this.currentQuiz_xmlnode.childNodes.length; j++ )
		{
			if (( this.currentQuiz_xmlnode.childNodes[j].attributes.id  != undefined ) && ( this.currentQuiz_xmlnode.childNodes[j].attributes.id == SessionArray[i].interaction_id ))
			{
				Question_xmlnode = this.currentQuiz_xmlnode.childNodes[j];	
			}
		}


		if ( Question_xmlnode != null )
		{		
			if ( Question_xmlnode.attributes.qtype.toUpperCase() == 'DDTASK' )
			{		
				var nNumberOfPossibleTargets:Number = 2;
				var asGroups:Array = new Array();																				// this will become a multidimensional array - 1 array for each target with the target as element 0 of it's array and the items matched to it as the later items 
            	
				var sCorrectAnswer = '<p>The Correct Answers are shown below:</p>';
				for ( var k:Number = 1; k <= nNumberOfPossibleTargets; k++)
				{
					if ( eval( "Question_xmlnode.attributes.target" + k ) != undefined )
					{
						asGroups[k-1] = new Array();
						asGroups[k-1][0] = eval( "Question_xmlnode.attributes.target" + k );
						trace("ASGroups: " + asGroups[k-1][0])
						sCorrectAnswer += '<p>&nbsp;</p><p class="categories">' + asGroups[k-1][0] + '</p>';

						for ( var l:Number = 0; l < Question_xmlnode.childNodes.length; l++ )
						{
							if ( Question_xmlnode.childNodes[l].nodeName == 'dragobjects' )
							{
								for ( var m:Number = 0; m < Question_xmlnode.childNodes[l].childNodes.length; m++ )
								{
									if ( Question_xmlnode.childNodes[l].childNodes[m].attributes.matchelement == asGroups[k-1][0] || Question_xmlnode.childNodes[l].childNodes[m].attributes.matchelement == k)
									{					
										asGroups[k-1][asGroups[k-1].length] = Question_xmlnode.childNodes[l].childNodes[m].firstChild.nodeValue;
										sCorrectAnswer += '<p>' + asGroups[k-1][asGroups[k-1].length-1]  + '</p>';
									}
								}
							}
						}
					}
				}
				return sCorrectAnswer;
			}
			else if  ( Question_xmlnode.attributes.qtype.toUpperCase() == 'DDNUM' )
			{			
				var sTemp = SessionArray[i].correct_response.toString();
				sTemp = (( sTemp.indexOf != undefined ) && ( sTemp.indexOf( '{' ) != undefined )  && ( sTemp.indexOf( '{' ) != -1 ) ) ?  sTemp.substring( 1, sTemp.length - 1 ) : sTemp ; 			// Strip off the { and } from the string if they are present. If they are not present, for some reason the function that builds this, doesn't build it as a string
				var anCorrectReponses:Array =  sTemp.split( ',' );	
				var sCorrectAnswer = '<p>The Correct Answers are shown below:</p>';
				for ( var j:Number = 0; j < anCorrectReponses.length; j++ )
				{
					sCorrectAnswer += '<p>' + anCorrectReponses[j].split( '.' )[0] + ' -- ' + SessionArray[i].aResponseOrder[j].firstChild.nodeValue + '</p>';
				}	
								
				return sCorrectAnswer;
			} else {
				var sTemp = SessionArray[i].correct_response.toString();
				sTemp = (( sTemp.indexOf != undefined ) && ( sTemp.indexOf( '{' ) != undefined )  && ( sTemp.indexOf( '{' ) != -1 ) ) ?  sTemp.substring( 1, sTemp.length - 1 ) : sTemp ; 			// Strip off the { and } from the string if they are present. If they are not present, for some reason the function that builds this, doesn't build it as a string
				var anCorrectReponses:Array =  sTemp.split( ',' );	
				var sCorrectAnswer = '<p>The Correct Answers are shown below:</p>';
				for ( var j:Number = 0; j < anCorrectReponses.length; j++ )
				{
					sCorrectAnswer += '<p>Drag object: ' + anCorrectReponses[j].split( '.' )[0] + ' -- Target object: ' + anCorrectReponses[j].split( '.' )[1] + '</p>';
				}	
								
				return sCorrectAnswer;
			}
		}
	}
}




function getFoilNumbersFromLetters( sLetters:String )
{
	var asTemp:Array = new Array();
	var anTemp:Array = new Array();
	if ( sLetters.indexOf( '{' ) == 0 )																								// there are multiple responses
	{
		sLetters = sLetters.substring( 1, sLetters.length - 1 )
		asTemp = sLetters.split( ',' );	
	}
	else
	{
		asTemp[0] = sLetters.toString();
	}

	
	for ( var i:Number = 0; i < asTemp.length; i++ )
	{
		anTemp[i] = getFoilNumberFromLetter( asTemp[i] );	
	}
	
	return anTemp;	
}




function getFoilNumberFromLetter( sLetter:String )
{
	for ( var i:Number = 0; i < asLetters.length; i++ )
	{
		if ( asLetters[i] == sLetter )
		{
			return i;
		}
	}	
}




function getFoilNumberFromResponseText( i:Number )
{
	var sStudentResponse:String  = SessionArray[i].student_response + '';		
	trace("Sresponse: " + sStudentResponse)// force to a string (true false is a boolean)
	sStudentResponse = sStudentResponse.toLowerCase();
	var sFoilText:String;

	for ( var j:Number = 0; j < SessionArray[i].distractor_labels.length; j++ )
	{	
		sFoilText = SessionArray[i].distractor_labels[j].toLowerCase();
		if ( sFoilText.indexOf( sStudentResponse ) != -1 )
		{
			return j;		
		}
	}		
}
