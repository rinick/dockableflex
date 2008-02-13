package net.goozo.mx.dockalbe
{
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.core.Container;
	import mx.styles.StyleProxy;
	
	public class FloatPanel extends ClosablePanel
	{
		private var resizeButton:Button=null;
		
		private var _showResizeButton:Boolean=true;;
		
		private static var _resizeButtonStyleFilters:Object = 
		{
			"resizeButtonUpSkin" : "upSkin", 
			"resizeButtonOverSkin" : "overSkin",
			"resizeButtonDownSkin" : "downSkin",
			"resizeButtonDisabledSkin" : "disabledSkin",
			"resizeButtonSkin" : "skin",
			"repeatDelay" : "repeatDelay",
			"repeatInterval" : "repeatInterval"
	    };
	    
		protected function get resizeButtonStyleFilters():Object
		{
			return _resizeButtonStyleFilters;
		}
	
		public function get showResizeButton():Boolean
		{
			return _showResizeButton;
		}
		public function set showResizeButton(value:Boolean):void
		{
			_showResizeButton = value;
			resizeButton.visible = value;			
		}
		
    	[Inspectable(category="General", enumeration="true,false", defaultValue="true")]
	    override public function set enabled(value:Boolean):void
	    {
	        super.enabled = value;
	        
	        if(resizeButton)
	        	resizeButton.enabled = value;
	    }
	    
		public function FloatPanel( fromChild:Container = null )
		{
			super( fromChild );
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
	        
	        if (!resizeButton)
	        {
	            resizeButton = new Button();
	            resizeButton.styleName = new StyleProxy(this, resizeButtonStyleFilters);	
	            
	            resizeButton.focusEnabled = false;

	            resizeButton.enabled = enabled;
	            resizeButton.visible = _showResizeButton;

	            rawChildren.addChild(resizeButton);
				resizeButton.owner = this;
	
				titleBar.addEventListener(MouseEvent.MOUSE_DOWN,handleStartDragTitle);
	 			resizeButton.addEventListener(MouseEvent.MOUSE_DOWN,handleStartResize);
	 						
				callLater(fixFloatSize);
	        }									
		}
		override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.layoutChrome(unscaledWidth,unscaledHeight);
			
			// The previewer in Flex builder can not get the getStyle properly, so ..
			if( _showResizeButton && resizeButton )
			{
				var resizeButtonWidth:Number = getStyle("resizeButtonWidth");
				var resizeButtonHeight:Number = getStyle("resizeButtonHeight");
				if( resizeButtonWidth>0 && resizeButtonHeight>0 )
				{
					resizeButton.width = getStyle("resizeButtonWidth");
					resizeButton.height = getStyle("resizeButtonHeight");					
				}else{
					resizeButton.width = 7;
					resizeButton.height = 7;	
				}			
				resizeButton.move( unscaledWidth - resizeButton.width , unscaledHeight - resizeButton.height );				
			}	
		}
		
		private function handleStartResize(e:MouseEvent):void
		{
			if(_showResizeButton)
			{
				stage.addEventListener(MouseEvent.MOUSE_UP,handleStopResize);
				stage.addEventListener(MouseEvent.MOUSE_MOVE,handleResize);				
			}
		}
		private function handleStopResize(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP,handleStopResize);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,handleResize);			
		}
		private function handleResize(e:MouseEvent):void
		{
			width = Math.max( mouseX + resizeButton.width/2, minWidth );
			height = Math.max( mouseY + resizeButton.height/2, minHeight );			
		}
		
		private function handleStartDragTitle(e:MouseEvent):void
		{
			startDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP,handleStopDragTitle);
		}
		private function handleStopDragTitle(e:MouseEvent):void
		{
			stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP,handleStopDragTitle);
		}

		private function fixFloatSize():void
		{
			if(initialized)
			{
				var tMinWidth:Number = minWidth;
				var tMinHeight:Number = minHeight;
				if( width < tMinWidth
				 && width < tMinWidth*2
				 && height < tMinHeight
				 && height < tMinHeight*2
				){
					width = width;
					height = height;
				}else{
					width = Math.max(DockManager.app.width/3,tMinWidth);
					height = Math.max(DockManager.app.height/3,tMinHeight);					
				}
			}else{
				callLater(fixFloatSize);
			}
		}
	}
}