	import 	mx.utils.Delegate;
	import flash.geom.Rectangle;
		
	class Scrollbar extends MovieClip
	{
		var targetMC:MovieClip;	
		var top:Number;
		var bottom:Number;
		var dragBot:Number;
		var range:Number;
		var ratio:Number;
		var sPos:Number;
		var sRect:Rectangle;
		var ctrl:Number;//This is to adapt to the target's position
		var isUp:Boolean;
		var isDown:Boolean;
		var isArrow:Boolean;
		var arrowMove:Number;
		var upScrollControlHeight:Number;
		var downScrollControlHeight:Number;
		var sBuffer:Number;
		var dragHandleMC:MovieClip;
		var track:MovieClip;
		var upScrollControl:MovieClip;
		var downScrollControl:MovieClip;
		var sBar:MovieClip;
		public function Scrollbar(target:MovieClip,sBar:MovieClip) {
											
			
			dragHandleMC = sBar.dragHandleMC;
			track = sBar.track;
			upScrollControl = sBar.upScrollControl;
			downScrollControl = sBar.downScrollControl;
			
			dragHandleMC.onPress = Delegate.create(this,dragScroll);
			dragHandleMC.onRelease = dragHandleMC.onReleaseOutside =  Delegate.create(this,stopScroll);	
			init(target,sBar);
			
			
		}
		//
		public function init(target:MovieClip,sBar:MovieClip) {	
			targetMC = target;
			sBuffer = 1;
			ratio = 2;
						
						
			trace(targetMC._height +"<="+ track._height)
			
			if (targetMC._height <= track._height) {
				sBar._visible = false;
				trace(sBar+" ... "+sBar._visible);
			}			
			else
			{
				sBar._visible = true;
				}

			//
			upScrollControlHeight = upScrollControl._height;
			downScrollControlHeight = downScrollControl._height;
			
			top = dragHandleMC._y;
			dragBot = (dragHandleMC._y + track._height) - dragHandleMC._height;
			bottom = track._height - (dragHandleMC._height/sBuffer);
		
			
			range = bottom - top;
						
			
			sRect = new Rectangle(0,top,0,dragBot);
			ctrl = targetMC._y;
			//set Mask
			isUp = false;
			isDown = false;
			arrowMove = 10;
			
			
			upScrollControl.onEnterFrame = Delegate.create(this,upScrollControlHandler);
			upScrollControl.onPress = Delegate.create(this,upScroll);
			upScrollControl.onRelease = upScrollControl.onReleaseOutside = Delegate.create(this,stopScroll);
			//
			downScrollControl.onEnterFrame = Delegate.create(this,downScrollControlHandler);
			downScrollControl.onPress = Delegate.create(this,downScroll);
			downScrollControl.onRelease = downScrollControl.onReleaseOutside =  Delegate.create(this,stopScroll);
	
			setMask();
			this._x = targetMC._x+targetMC._width + 5;
			this._y = targetMC._y+5;
		}
		
		function setMask() {
			/*
			var square:Sprite = new Sprite();
			square.graphics.beginFill(0x000000);
			square.graphics.drawRect(targetMC.x, targetMC.y, targetMC.width+5, (track.height+upScrollControlHeight+downScrollControlHeight));
			targetMC.parent.addChild(square);			
			targetMC.mask = square;	
			*/
			
		}
		
		public function upScroll() {
			isUp = true;
		}
		
		public function downScroll() {
			isDown = true;
		}
		
		public function upScrollControlHandler() {
			if (isUp) {
				if (dragHandleMC._y > top) {
					dragHandleMC._y-=arrowMove;
					if (dragHandleMC._y < top) {
						dragHandleMC._y = top;
					}
					startScroll();
				}
			}
		}
		
		//
		public function downScrollControlHandler() {
			if (isDown) {
				if (dragHandleMC._y < dragBot) {
					dragHandleMC._y+=arrowMove;
					if (dragHandleMC._y > dragBot) {
						dragHandleMC._y = dragBot;
					}
					startScroll();
				}
			}
		}
		//
		public function dragScroll() {			
			trace("START DRAG "+dragHandleMC+" this "+this);
			dragHandleMC.startDrag(false,0,top,0,dragBot) //; , sRect);
			/*
			stage.addEventListener(MouseEvent.MOUSE_MOVE, moveScroll);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			this.addEventListener(MouseEvent.MOUSE_MOVE, moveScroll);
			*/
			
			dragHandleMC.onMouseMove = Delegate.create(this,moveScroll);
			
		}
		//

		public function stopScroll() {
			 
			isUp = false;
			isDown = false;
			dragHandleMC.stopDrag();
			
			/*
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveScroll);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScroll);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, moveScroll);
			*/
			
			delete dragHandleMC.onMouseMove;
		}
		//
		public function moveScroll() {
			startScroll();

		}
		public function startScroll() {
			ratio = (targetMC._height -dragHandleMC._height - range)/range;
			sPos = (dragHandleMC._y * ratio) - ctrl;	
			targetMC._y = -sPos;						
	
		}
	
		public function resetDrag()
		{
			dragHandleMC._y = 0;
			}
	
	}
	