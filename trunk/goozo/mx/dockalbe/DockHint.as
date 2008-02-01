package net.goozo.mx.dockalbe
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
[ExcludeClass]

	internal class DockHint extends UIComponent
	{
		private var pendingCheckVisible:Boolean = false;
		private var focusTarget:UIComponent = null;
		
		public function DockHint()
		{
			super();
		}
		override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			graphics.clear();
			graphics.lineStyle(2,0xffFF00,0.3,true);
			graphics.drawRoundRect(3,3,unscaledWidth-6,unscaledHeight-6,5);
			graphics.lineStyle(2,0xff0000,0.3,true);
			graphics.drawRoundRect(1,1,unscaledWidth-2,unscaledHeight-2,5);			
		}

		public function setDockHint(dragAaccepter:UIComponent,position:String):void
		{
			focusTarget = dragAaccepter;
			
			var fullArea:Rectangle=dragAaccepter.getRect(parent);

			switch(position)
			{
				case DockManager.LEFT:
					fullArea.width/=4;
					break;
				case DockManager.TOP:
					fullArea.height/=4;
					break;
				case DockManager.RIGHT:
					fullArea.x += 3*fullArea.width/4
					fullArea.width/=4;
					break;
				case DockManager.BOTTOM:
					fullArea.y += 3*fullArea.height/4
					fullArea.height/=4;
					break;
			}
			width = fullArea.width;
			height = fullArea.height;
			move(fullArea.x,fullArea.y);

		}
	}
}