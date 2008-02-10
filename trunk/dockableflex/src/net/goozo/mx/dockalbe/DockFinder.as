package net.goozo.mx.dockalbe
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import mx.controls.Button;
	import mx.controls.TabBar;
	import mx.core.Container;
	import mx.core.UIComponent;

	
	internal class DockFinder
	{
		public var lastBtn:Button;
		public var lastTabBar:TabBar;
		public var lastTabNav:DockableTabNavigator;
		public var lastPanel:DockablePanel;
		
		public var lastAccepter:UIComponent;
		public var lastPosition:String;
		public var lastDistance:Number;
		
		private var checklog:Object;
				
		public function DockFinder()
		{
			super();
			clear();
		}
		public function clear():void
		{
			checklog = new Object();
		}
		public function findTabBar(target:DisplayObject):Boolean
		{
			var getTar:DisplayObject=target;
			
			var nFind:int = 0;
			while(getTar != DockManager.app)
			{
				if(getTar is DockableTabNavigator)
				{
					lastTabNav = DockableTabNavigator(getTar);
					nFind |= 4;
					break;
				}
				else if(getTar is TabBar)
				{
					lastTabBar = TabBar(getTar);
					nFind |= 2;
				}
				else if(getTar is Button)
				{
					lastBtn = Button(getTar);
					nFind |= 1;
				}
				getTar=getTar.parent;
			}
			if(nFind==7)
			{
				lastAccepter = lastBtn;
				return true;			
			}
			return false;
		}
		public function findPanel(target:DisplayObject):Boolean
		{
			var getTar:DisplayObject=target;
			
			while(getTar != DockManager.app)
			{
				if(getTar is DockablePanel)
				{
					lastPanel = DockablePanel(getTar);
					return true;
				}
				getTar=getTar.parent;
			}
			return false;
		}
		public function checkTabBar(source:DockSource):Boolean
		{
			if(source.dockType == DockManager.DRAGTAB)
			{
				lastPosition = closestSideToBtn(lastBtn);
				lastAccepter = lastBtn;
			}else{
				lastPosition = DockManager.WHOLE;
				lastAccepter = lastTabBar;
			}
			
			return lastTabNav.dockAsk(source,lastAccepter,lastPosition);
		}
		public function checkPanel(source:DockSource):Boolean
		{
			lastPosition = closestSideToPanel(lastPanel);
			if( lastDistance>=0.25 )
			{
				return false;
			}
			lastAccepter = findHighestAccepter(lastPanel,lastPosition);
			return lastPanel.dockAsk(source,lastAccepter,lastPosition);
		}
		
		public static function closestSideToBtn(component:UIComponent):String
		{
			var bound:Rectangle=component.getRect(component);
			var leftRate:Number = component.mouseX / bound.width;
			if(leftRate<0.5)
			{
				return DockManager.LEFT;
			}else{
				return DockManager.RIGHT;
			}
		}
		public function closestSideToPanel(component:UIComponent):String
		{
			var bound:Rectangle=component.getRect(component);
			var leftRate:Number = component.mouseX / bound.width;
			var topRate:Number = component.mouseY / bound.height;			
//			if( leftRate<-0.02 || leftRate>1.02 || topRate<-0.02 || topRate>1.02 )
//			{
//				return DockManager.OUTSIDE;
//			}
			var rightRate:Number = 1-leftRate;
			var bottomRate:Number = 1-topRate;
			lastDistance = Math.min(leftRate,topRate,rightRate,bottomRate);			
	
			switch(lastDistance)
			{
				case leftRate:
					return DockManager.LEFT;
				case topRate:
					return DockManager.TOP;
				case rightRate:
					return DockManager.RIGHT;
				case bottomRate:
					return DockManager.BOTTOM;
			}
			return "";
		}
		public static function rateFromMouse(component:UIComponent,side:String):Number
		{
			var bound:Rectangle=component.getRect(component);
			var leftRate:Number = component.mouseX / bound.width;
			var topRate:Number = component.mouseY / bound.height;
			switch(side)
			{
				case DockManager.LEFT:
					return leftRate;
				case DockManager.TOP:
					return topRate;
				case DockManager.RIGHT:
					return 1-leftRate;
				case DockManager.BOTTOM:
					return 1-topRate;
			}
			throw new Error("unknown side");
			return 0;
		}
		
		public static function findHighestAccepter(target:Container,side:String):Container
		{
			switch(side)
			{
				case DockManager.LEFT:
				case DockManager.RIGHT:
					 return findHighestAccepterH(target,side);
				case DockManager.TOP:
				case DockManager.BOTTOM:
					return findHighestAccepterV(target,side);
			}
			return null;
		}
		private static function findHighestAccepterH(target:Container,side:String):Container
		{
			var iterateTarget:Container=target;
			var returnTarget:Container=null;
			var threshold:Number = 0.25;
			while(rateFromMouse(iterateTarget,side)<threshold && rateFromMouse(target,side)<threshold )
			{
				returnTarget = iterateTarget;
				if(iterateTarget.parent is DockableHDividedBox)
				{				
					do{
						iterateTarget=Container(iterateTarget.parent);
					}
					while(iterateTarget.parent is DockableHDividedBox);
				}
				if( iterateTarget.parent is DockableVDividedBox ){
					iterateTarget=Container(iterateTarget.parent);
				}else{
					return returnTarget;
				}
				threshold /= 2;
			}
			return returnTarget;
		}
		private static function findHighestAccepterV(target:Container,side:String):Container
		{
			var iterateTarget:Container=target;
			var returnTarget:Container=null;
			var threshold:Number = 0.25;
			while(rateFromMouse(iterateTarget,side)<threshold && rateFromMouse(target,side)<threshold )
			{
				returnTarget = iterateTarget;
				if(iterateTarget.parent is DockableVDividedBox)
				{				
					do{
						iterateTarget=Container(iterateTarget.parent);
					}
					while(iterateTarget.parent is DockableVDividedBox);
				}
				if( iterateTarget.parent is DockableHDividedBox ){
					iterateTarget=Container(iterateTarget.parent);
				}else{
					return returnTarget;
				}
				threshold /= 2;
			}
			return returnTarget;
		}
	}
}