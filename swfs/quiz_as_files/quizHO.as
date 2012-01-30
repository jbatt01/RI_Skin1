/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications
*/


function showProps( objTest )
{
	var sMsg = '';
	for ( prop in objTest )
	{
		sMsg += '\n' + prop + ' | ' + objTest[prop];
	}
	return sMsg;
}


var aResponseOrder = new Array();	
//Establish a multiple choice Image question.
var g_imagePath:Array = new Array();

update_hoimage_question();

//Sets all the attributes of the multiple choice component
function update_hoimage_question(){
	var tempObj:Object = this.hotobjectimage;
	questionObj = tempObj;
	//Set question text
	var questionText_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "questionText");
	tempObj.Question = questionText_xmlnode.firstChild.nodeValue;
	
	//Set Question parameters
	var quest_params = set_question_params(currentQuestion_xmlnode,tempObj)
	
	//Set Feedback
	var feedback_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild,"feedback");
	do_feedback(feedback_xmlnode,tempObj)
	
	//set distractors
	//get distractor node
	var distractor_xmlnode:XMLNode = matchSiblingNode(currentQuestion_xmlnode.firstChild, "distractors");
	//cycle through distractors
	if (distractor_xmlnode != null) {
		var randomResponse:Boolean = (distractor_xmlnode.attributes.randomize.toUpperCase() == "TRUE");
		var random_response_array:Array = new Array(); //Array of responses
		var next_distractor_xmlnode:XMLNode = distractor_xmlnode.firstChild;
		for(var i:Number = 1; i<=8;i++){
			if (next_distractor_xmlnode != null) {
				//if it exists, add the label
				//check to see if we need to randomize responses
				if (!randomResponse) {//No need to randomize so establish settings.
					aResponseOrder[aResponseOrder.length] = next_distractor_xmlnode;
					//load image
					g_imagePath[i-1] = next_distractor_xmlnode.attributes.filepath;
					//playerMain_mc.presentation["HotObjectI"+i].loadMovie(imagePath);
					//trace("before loading...")
					//this["HotObjectI"+i].loadMovie("swfs/mcimage.swf");
					//Loading Image
					var picture_mcl1:MovieClipLoader = new MovieClipLoader();
					//load the image
					//Get Image node
					var mclListener1:Object = new Object();

					picture_mcl1.addListener(mclListener1);
					
					mclListener1.onLoadInit = function(mc:MovieClip)
					{
						//onPress functionality
						mc.onPress = function() 
						{
							//trace("pressed")
							var router = SessionArray[session];
							if(router.scoreFlag != true){

								router.setComponentState(router.Assets.ControlButton, true);
								router.setComponentState(router.Assets.ResetButton, true);
								router.setFeedback(1);
								var qObj:Object  = _parent.hotobjectimage;
								this.hilite = new Color(this);

								var transform = new Object();
								transform.ra = 100;
								transform.rb = 204;
								transform.ga = 100;
								transform.gb = 0;
								transform.ba = 100;
								transform.bb = 0;
								transform.aa = 20;
								transform.ab = 255;

								restore = new Object();
								restore.ra = 100;
								restore.rb = 0;
								restore.ga = 100;
								restore.gb = 0;
								restore.ba = 100;
								restore.bb = 0;
								restore.aa = 100;
								restore.ab = 0;

								if (this.finished != true){
									this.hilite.setTransform(transform);
									this.finished = true;
									var mcName:String = this._name;
									//var pos:Number = (mcName.charAt(mcName.length - 1)*1);
									for (var i = 1;i<9;i++){
										if (router.hot_objects[i] == mcName) {
											_parent[router.hot_ojbects[i]].selected = true;
											_parent[router.hot_ojbects[i]].finished = true;
										}
									}
									this.selected = true;
								}
								
							}
						}
					}

					var imgLoc:String = next_distractor_xmlnode.attributes.filepath;
					if (imgLoc !== undefined){
						picture_mcl1.loadClip(imgLoc,this["HotObjectI"+i]);//.image_mc);
					}
					//trace("hotobject: " + this["HotObjectI"+j].image_mc)
					//tempObj["Distractor_Label" + i] = next_distractor_xmlnode.firstChild.nodeValue;
					//set correctness
					var correctness = next_distractor_xmlnode.attributes.correct;
					if (correctness != undefined) {
						tempObj["Correct_Response" + i] = (correctness.toUpperCase() == "TRUE");						
					} else {
						tempObj["Correct_Response" + i] = false;
					}
					
				} else { //Need to randomize so store in array.
					random_response_array[i-1] = next_distractor_xmlnode;
				}
			} else {
				//if not hide the checkbox component
				this["HotObjectI" + i]._visible = false;
			}
			next_distractor_xmlnode = next_distractor_xmlnode.nextSibling;
		}
		if (randomResponse) {//Assign Random responses to their location
			var arrayL:Number = random_response_array.length;			
			for (var j:Number = 1;j <= arrayL;j++){
				var new_num:Number = randRange(0,(random_response_array.length - 1))
				var tempArray:Array = random_response_array.splice(new_num,1);
				var response_xmlnode:XMLNode = tempArray[0];
				aResponseOrder[aResponseOrder.length] = response_xmlnode;
				//load image
				g_imagePath[j-1] = response_xmlnode.attributes.filepath;
				//trace("CHANGE: " + g_imagePath);
				//playerMain_mc.presentation["HotObjectI"+i].loadMovie(imagePath);
				//this["HotObjectI"+j].loadMovie("swfs/mcimage.swf");
				//this["HotObjectI"+j].createEmptyMovieClip("image_mc",questionObj.getNextHighestDepth());
				
				
				//Loading Image
				var picture_mcl1:MovieClipLoader = new MovieClipLoader();
				//load the image
				//Get Image node
				var mclListener1:Object = new Object();

				picture_mcl1.addListener(mclListener1);
				
				mclListener1.onLoadInit = function(mc:MovieClip)
				{
					//onPress functionality
					mc.onPress = function() 
					{
						//trace("pressed")
						var router = SessionArray[session];
						if(router.scoreFlag != true){

							router.setComponentState(router.Assets.ControlButton, true);
							router.setComponentState(router.Assets.ResetButton, true);
							router.setFeedback(1);
							var qObj:Object  = _parent.hotobjectimage;
							this.hilite = new Color(this);

							var transform = new Object();
							transform.ra = 100;
							transform.rb = 204;
							transform.ga = 100;
							transform.gb = 0;
							transform.ba = 100;
							transform.bb = 0;
							transform.aa = 20;
							transform.ab = 255;

							restore = new Object();
							restore.ra = 100;
							restore.rb = 0;
							restore.ga = 100;
							restore.gb = 0;
							restore.ba = 100;
							restore.bb = 0;
							restore.aa = 100;
							restore.ab = 0;

							if (this.finished != true){
								this.hilite.setTransform(transform);
								this.finished = true;
								var mcName:String = this._name;
								//var pos:Number = (mcName.charAt(mcName.length - 1)*1);
								for (var i = 1;i<9;i++){
									if (router.hot_objects[i] == mcName) {
										_parent[router.hot_ojbects[i]].selected = true;
										_parent[router.hot_ojbects[i]].finished = true;
									}
								}
								this.selected = true;
							}
							
						}
					}
				}

				var imgLoc:String = response_xmlnode.attributes.filepath;
				if (imgLoc !== undefined){
					picture_mcl1.loadClip(imgLoc,this["HotObjectI"+j]);//.image_mc);
				}
				
				//tempObj["Distractor_Label" + j] = response_xmlnode.firstChild.nodeValue;
				var correctness = response_xmlnode.attributes.correct;
				if (correctness != undefined) {
					tempObj["Correct_Response" + j] = (correctness.toUpperCase() == "TRUE");
				} else {
					tempObj["Correct_Response" + j] = false;
				}			
			}	
		}
	}	
}
