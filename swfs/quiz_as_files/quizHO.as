/*
Flash Companion, Copyright 2004, 2005, 2006, 2008 Rapid Intake, Inc.

	Player Version:	 	3
	Updates:	 		Steven Hancock

	Modifications
*/

//==================================================================================//
//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
import com.greensock.*;
import com.greensock.easing.*;
//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
//==================================================================================//


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
						
						//==================================================================================//
						//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
						
						imageInit(mc);
						
						//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
						//==================================================================================//
						
						
						
						
						//onPress functionality
						mc.onPress = function() 
						{
							//trace("pressed")
							var router = SessionArray[session];
							if(router.scoreFlag != true){

								router.setComponentState(router.Assets.ControlButton, true);
								router.setComponentState(router.Assets.ResetButton, true);
								router.setFeedback(1);
								
								//==================================================================================//
								//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
								
								var qObj:Object  = _parent._parent.hotobjectimage;
								
								//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
								//==================================================================================//
								
								
								
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
						
						//==================================================================================//
						//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
						
						picture_mcl1.loadClip(imgLoc,this["HotObjectI"+i].holder_mc);
						
						//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
						//==================================================================================//
						
						
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

					//==================================================================================//
					//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
					
					imageInit(mc);
					
					//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
					//==================================================================================//
					
					
					//onPress functionality
					mc.onPress = function() 
					{
						//trace("pressed")
						var router = SessionArray[session];		
						if(router.scoreFlag != true){

							router.setComponentState(router.Assets.ControlButton, true);
							router.setComponentState(router.Assets.ResetButton, true);
							router.setFeedback(1);
							
							//==================================================================================//
							//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//							
							var qObj:Object  = _parent._parent.hotobjectimage;
							//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
							//==================================================================================//
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
					
					//==================================================================================//
					//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//							
					
					picture_mcl1.loadClip(imgLoc,this["HotObjectI"+j].holder_mc);
					
					//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//							
					//==================================================================================//
					
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





//==================================================================================//
//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//

function imageInit(mc)
{
	mc.forceSmoothing = true;	

	var wr = mc._width/mc._parent.dummy_mc._width;
	var hr = mc._height/mc._parent.dummy_mc._height;
	
	if(wr>hr)
	{
		//limit W		
		mc._width = mc._parent.dummy_mc._width;
		mc._yscale = mc._xscale;		
		
		//center in Y
		var posY = mc._parent.dummy_mc._height-mc._height			
		mc._y = posY/2;
	}
	else
	{
		//limit H		
		mc._height = mc._parent.dummy_mc._height;
		mc._xscale = mc._yscale;
		
		//center in X			
		var posX = mc._parent.dummy_mc._width-mc._width		
		mc._x = posX/2;
	}
	
	mc._parent.zoom_btn._x = mc._x+mc._width;
	mc._parent.zoom_btn._y = mc._y+mc._height;	
	
	
	mc._parent.zoom_btn.onRollOver = function(){ this.gotoAndStop("over")};
	mc._parent.zoom_btn.onRollOut = function(){ this.gotoAndStop("out")};
	
	mc._parent.zoom_btn.onRelease = zoomIn;
	mc._parent.zoom_btn._visible = true;

	mc._parent.zoomOut_btn.onRelease = zoomOut;
	mc._parent.zoomOut_btn._visible = false;	
	mc._parent.zoomOut_btn._x = mc._x;
	mc._parent.zoomOut_btn._y = mc._y;
	mc._parent.zoomOut_btn._width = mc._width;
	mc._parent.zoomOut_btn._height = mc._height;
		

	mc._parent.W = mc._parent._width;
	mc._parent.H = mc._parent._height;
	mc._parent.X = mc._parent._x;
	mc._parent.Y = mc._parent._y;		

}

// ZoomIn the loadImage container, based on the playerMain_mc size.
function zoomIn()
{	
	var max = -255000;
	var max_item;
	for(var i=1;i<=8;i++)
	{		
		if(eval("HotObjectI"+i).getDepth()>max)
		{
			max = eval("HotObjectI"+i).getDepth();
			max_item = eval("HotObjectI"+i);
		}
	}	
	this._parent.swapDepths(locked_mc);
		
	this._visible = false;	
		
	this._parent.zoomOut_btn._visible = true;
	
	locked_mc._alpha = 0;	
	locked_mc._visible = true
	locked_mc.resize(playerMain_mc);
	TweenLite.to(locked_mc, 0.6, {_alpha:100});
	
		
	locked2_mc._alpha = 0;	
	locked2_mc._visible = true
	locked2_mc.resize(playerMain_mc);
	TweenLite.to(locked2_mc, 0.6, {_alpha:100});
	
	
	var wr = playerMain_mc.presentSizeW/this._parent._width;
	var hr = playerMain_mc.presentSizeH/this._parent._height;
		
	var newW, newH, newX, newY, newScale;	
		
	if(wr<hr)
		{
			//limit W			
			this._parent._width = playerMain_mc.presentSizeW;
			this._parent._yscale = this._parent._xscale;			
			newW = playerMain_mc.presentSizeW;
			newH = this._parent._height;			
			var posY = playerMain_mc.presentSizeH-this._parent._height			
			
			this._parent._width = this._parent.W;
			this._parent._height = this._parent.H;
					
			//center in Y			
			newX = 0;
			newY = posY/2;			
									
			TweenLite.to(this._parent,0.6,{_x:newX, _y:newY, _width:newW, _height:newH});
		}
		else
		{
			//limit H			
			this._parent._height = playerMain_mc.presentSizeH;
			this._parent._xscale = this._parent._yscale;			
			newH = playerMain_mc.presentSizeH;
			newW = this._parent._width;
			var posX = playerMain_mc.presentSizeW-this._parent._width;			
			
			this._parent._width = this._parent.W;
			this._parent._height = this._parent.H;
			
			//center in X			
			newY = 0;
			newX = posX/2;
	
			TweenLite.to(this._parent,0.6,{_x:newX, _y:newY, _width:newW, _height:newH});
		}
}


// ZoomOut the loadImage container, to the original values.
function zoomOut()
{		
	this._parent.swapDepths(locked_mc);
	
	this._visible = false;
	TweenLite.to(this._parent, 0.6, {_x:this._parent.X, _y: this._parent.Y, _width:this._parent.W, _height:this._parent.H});	
	TweenLite.to(locked_mc, 0.6, {_alpha:0, onComplete:hideLock, onCompleteParams:[this._parent]});			
	TweenLite.to(locked2_mc, 0.6, {_alpha:0, onComplete:hideLock, onCompleteParams:[null]});	
}

function hideLock(_param)
{	
	_param.zoom_btn._visible = true;
	locked_mc.hide();
	
	locked2_mc.hide();
}

//==================== CUSTOMIZED CODE: IMAGES ZOOM-IN, ZOOM-OUT ===================//
//==================================================================================//
