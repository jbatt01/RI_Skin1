
class Certificate extends MovieClip {
	
	private var __name:String,__date:String,__title:String,__contact:String,__description:String;
	private var person_name_txt:TextField,course_title_txt:TextField,date_txt:TextField,course_contact_txt:TextField,course_description_txt:TextField;
	private var __origW:Number,__origH:Number,__xscale:Number,__yscale:Number;
	public var back:MovieClip,loadImage_mc:MovieClip,logo_mc:MovieClip;
	public var print_btn:Button;
	public var certificate:Certificate;
	
	
	public function resize(origWidth:Number,origHeight:Number,presentW:Number,presentH:Number){
		__origW = origWidth;
		__origH = origHeight;
		var newSizeH:Number = presentH - 36 - 10; //36 for the button - 10 for position
		var newSizeW:Number = presentW - 10;// - 10 for position
		var diffH:Number = 0;
		var diffW:Number = 0;
		var scaleFact:Number = 0;
		if (newSizeH > __origH && newSizeW > __origW)//Grow it
		{
			
			
			var scaleH = Math.floor(newSizeH/__origH*100);
			var scaleW = Math.floor(newSizeW/__origW*100);
			//trace("scalesH  and W: " + scaleH + " - " + scaleW);
			scaleFact = Math.min(scaleH,scaleW);
			//trace("scaleFact Inside: " + scaleFact)
			
		} else if (newSizeH < __origH || newSizeW < __origW) {//Shrink it
			
			var scaleH = Math.ceil(newSizeH/__origH*100);
			var scaleW = Math.ceil(newSizeW/__origW*100);
			scaleFact = Math.min(scaleH,scaleW);
		} else {
			scaleFact = 100;
			
		}
		//trace("origW: " + __origW + " origH: " + __origH + " presentW: " + newSizeW + " presentH: " + newSizeH);
		//trace("Difference W then H: " + diffW + " - " + diffH);
		//trace("qW: " + quotW + " - qH: " + quotH);
		//resize it.
		__xscale = __yscale = scaleFact;
		//trace("Scaling: " + scaleFact);
		if (scaleFact != 100)
		{
			back = this._parent.back_mc;
			
			this._xscale = __xscale;
			this._yscale = __yscale;
			back._width = this._width + 6;
			back._height = this._height + 6;
			print_btn._x = back._x + back._width - 100;
			print_btn._y = back._y + back._height + 5;
			trace("height: " + (back._y + back._height + 5 + print_btn._height))
		}
		
	}
	
	public function print(){
		var certificate:Certificate = this.certificate;
		//trace(certificate)
		var pj = new PrintJob();
		var success = pj.start();

		if (success){
			//trace(pj.orientation)
			if (pj.orientation == "portrait"){
				
				//var scaleFact:Number = Math.round(certificate.__xscale * .7);
				//trace("portrait: " + scaleFact)
				certificate._xscale = 92;
				certificate._yscale = 92;
			} else if (pj.orientation == "landscape") {
				certificate._xscale = 120;
				certificate._yscale = 120;
			}
			pj.addPage(certificate,{xMin:0,xMax:certificate.__origW,yMin:0,yMax:certificate.__origH});
			pj.send();
			certificate._xscale = certificate.__xscale;
			certificate._yscale = certificate.__yscale;
		}
		delete pj;
	}
	
	public function populateFields(personsName:String,theDate:String,courseTitle:String,contact:String,courseDesc:String){
		this.person_name_txt.text = __name = personsName;
		this.course_title_txt.text = __title = courseTitle;
		this.date_txt.text = __date = theDate;
		if (contact !== undefined)
		{
			this.course_contact_txt.html = true;
			this.course_contact_txt.htmlText = __contact = contact;
		}
		if (courseDesc !== undefined)
		{
			this.course_description_txt.html = true;
			this.course_description_txt.htmlText = __description = courseDesc;
		}
	}
	
	public function loadArt(filePath:String)
	{
		//Loader 
		var mcLoader2:MovieClipLoader = new MovieClipLoader();
		var mcLoadListen2:Object = new Object();
		mcLoader2.addListener(mcLoadListen2);
		
		mcLoader2.loadClip(filePath, loadImage_mc);

		mcLoadListen2.onLoadInit = function(mc:MovieClip) {
			//trace(mc._width);
			//trace(mc._height);
			mc._width = 642;
			mc._height = 496;
			
		}
	}
	
	public function loadLogo(filePath:String,theWidth:Number,theHeight:Number)
	{
		var logoLoader:MovieClipLoader = new MovieClipLoader();
		var logoListener:Object = new Object();
		logoLoader.addListener(logoListener);
		
		logoLoader.loadClip(filePath,logo_mc);
		
		logoListener.onLoadInit = function(mc:MovieClip)
		{
			var curW:Number = mc._width;
			var curH:Number = mc._height;
			
			if (theWidth !== undefined && theHeight !== undefined)
			{
				var lScaleH = Math.floor(theHeight/curH*100);
				var lScaleW = Math.floor(theWidth/curW*100);
				
				var lScaleFact = Math.min(lScaleH,lScaleW);
				mc._xscale = lScaleFact;
				mc._yscale = lScaleFact;
			}
		}
	}
	
	function Certificate(){
		//Costructor function
		certificate = this;
		print_btn = this._parent.print_cert_btn;
		//print_btn.jump = certificate;
	}
}