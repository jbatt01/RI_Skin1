/*
====================================================
CLASS TOOLTIPS
====================================================
Sean Clark Hess
revision = 4
date = "Tue, 20 Apr 2007 - 11:27"
---------------------------------------------------
Modified by Steven Hancock for inclusion in Flashform Courses
	Player Version:	 	3
	Updates:	 		Steven Hancock
====================================================

*/

class Tooltips
{
    var rootRef:MovieClip;          // A Reference to the containing clip of the application
    
    var currentTip:Object;          // The handle the tooltip event is coming from.  
    var tipWidth:Number;            // The width of the tooltip movie clip
    var tipHeight:Number;           // The height of the tooltip movie clip
    var tip:TextField;              // The reference to the textfield
	var tip_mc:MovieClip;			 // Movie clip to control onEnterFrame
    
    
    public function Tooltips(rootRef:MovieClip)
    {
        
        this.rootRef = rootRef;
		
		rootRef.createTextField("tooltip_txt",99,0,0,200,20)
        
        tip = rootRef.tooltip_txt;
		
		tip.autoSize = true;
		tip.border = true;
		tip.background = true;
		tip.backgroundColor = 0xFFFFFF;
		
		rootRef.createEmptyMovieClip("tooltip_mc",199);
		
		tip_mc = rootRef.tooltip_mc;
		
        tipWidth = tip._width;
        tipHeight = tip._height;
        
        // Create the tooltip movieclip // 
        
        initTip();
        
    }
    
    public function showTip(obj:MovieClip, tooltip:String)
    {
        currentTip = obj;
        //trace(tip)
        // WAIT // Wait for 6 frames
            var i = 0;
            var thisRef = this;
            var tipStr = tooltip;
            var lObj = obj;
        
            tip_mc.onEnterFrame = function ()
            {
                i ++;
                this = thisRef;
                
                if ( !lObj.hitTest(_root._xmouse, _root._ymouse, true))
                    this.hideTip(lObj);
                    
                else if ( i == 7 )
                {
                    var xpos = _root._xmouse;
                    var ypos = _root._ymouse + 20;
                    
                    this.actuallyShow(thisRef,tipStr, xpos, ypos,lObj);
                    
                    
                }
                
                
            }
        
    }
    
    private function hideTip(obj:Object)
    {
        if (obj == currentTip)
            setIsVisible(false);
        
        delete tip_mc.onEnterFrame;
    }
    
    
    
    
    // CREATION / INIT // 

    private function initTip()
    {
        // Hide it // 
        setIsVisible(false);
        
    }
    
    private function setIsVisible(visible:Boolean)
    {
        tip._visible = visible;
    }
    
    private function setText(text:String)
    {
		var format1_fmt:TextFormat = new TextFormat();
		format1_fmt.font = "Arial";
		
        tip.text = text;
		tip.setTextFormat(format1_fmt);
    }
    
    private function moveToPos(xpos,ypos)
    {
        tip._x = xpos;
        tip._y = ypos;
    }
    
    private function actuallyShow(thisRef,tip,xpos,ypos,lObj)
    {
        setText(tip); 
		if ( (xpos + thisRef.tipWidth) > Stage.width )
			xpos -= thisRef.tipWidth;
		
		if ( (ypos + thisRef.tipHeight) > Stage.height )
			ypos -= (thisRef.tipHeight + lObj._height);
        moveToPos(xpos,ypos);
        setIsVisible(true);
    }
    
}

