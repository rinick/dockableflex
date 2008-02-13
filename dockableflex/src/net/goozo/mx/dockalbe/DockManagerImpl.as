package net.goozo.mx.dockalbe
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.core.Application;
	import mx.core.Container;
	import mx.core.IFlexDisplayObject;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.managers.CursorManager;
	import mx.managers.DragManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
		

	internal class DockManagerImpl
	{
		private static const TAB:String = "dockTAB";
		private static const PANEL:String = "dockPANEL";
		private static const FLOAT:String = "dockFloat";
		private static const DISABLE:String = "dockDisable";
		
		private var state:String = DISABLE;
		
		private var _app:Container = null;
		private var PendApp:Container = null;
		
		private var stage:Stage;
		
		private var dragInitiator:UIComponent;
		
		private var dockHint:IFlexDisplayObject = null;
		private var dragImage:DragProxyImage = null;
		private var cursorClass:Class = null;
		private var cursorID:int = CursorManager.NO_CURSOR;
			
		private var bDoingDock:Boolean=false;
				
		private var hintFocus:DisplayObject = null;
		private var dockSource:DockSource;
		
		private var finder:DockFinder;
		
		public function DockManagerImpl()
		{
			super();
			finder = new DockFinder();
		}
					
		public function hasApp():Boolean
		{
			return (_app==null);
		}
		public function get app():Container
		{
			if(_app!=null)
			{
				return _app;
			}else{
				return Container(Application.application);
			}
		}
		public function set app(value:Container):void
		{
			if(bDoingDock)
			{
				PendApp = value;
			}else{
				_app = value;
			}			
		}	
		public function newDockableApp(dividedBox:UIComponent):void
		{

			if(_app!=null)
			{
				return;
			}
			var getTar:DisplayObject=dividedBox;
			
			while(getTar != null)
			{
				if(getTar is Canvas || getTar is Application)
				{
					_app = Container(getTar);
					_app.horizontalScrollPolicy = ScrollPolicy.OFF;
					_app.verticalScrollPolicy = ScrollPolicy.OFF;
					return;
				}
				getTar=getTar.parent;
			}
			return;
		}				
	

		private function createDockHint():IFlexDisplayObject
		{
			var dockHintClass:Class=null;
			var inColor:uint=0xFFFF00;
			var outColor:uint=0xFF0000;
			var hintRadius:Number=5;
			var hintAlpha:Number=-1;
			
			var dockHintStyle:CSSStyleDeclaration = StyleManager.getStyleDeclaration("DockHint");
			
			if(dockHintStyle!=null)
			{
				dockHintClass = dockHintStyle.getStyle("hintSkin");
				inColor = dockHintStyle.getStyle("hintColorIn");
				outColor = dockHintStyle.getStyle("hintColorOut");
				hintAlpha = dockHintStyle.getStyle("hintAlpha");
				hintRadius = dockHintStyle.getStyle("hintRadius");
			}
			
			if(dockHintClass == DockHint)
			{
				dockHint = new DockHint(inColor,outColor,hintRadius);
			}else if(dockHintClass != null){
				dockHint = new dockHintClass();
			}else{
				dockHint = new DockHint();
			}
			
			if(hintAlpha>=0)
			{
				dockHint.alpha = hintAlpha;
			}
			dragInitiator.systemManager.popUpChildren.addChild(DisplayObject(dockHint));	
			return dockHint;
		}
		protected function removeDockHint():void
		{
			if(dockHint)
			{
				dockHint.parent.removeChild(DisplayObject(dockHint));
				dockHint=null;				
			}
		}
		private function createDragProxyImage(source:UIComponent, e:MouseEvent ):DragProxyImage
		{
			dragImage = new DragProxyImage();			
			dragInitiator.systemManager.popUpChildren.addChild(dragImage);
			dragImage.dragSource(source,e);
			return dragImage;
		}
		private function removeDragProxyImage():void
		{
			if(dragImage)
			{
				dragImage.parent.removeChild(dragImage);
				dragImage=null;					
			}		
		}

		public function get dockType():String
		{
			return dockSource.dockType;
		}
		public function doDock( dragInitiator:UIComponent, dockSource:DockSource, e:MouseEvent ):Boolean
		{
			if( bDoingDock || DragManager.isDragging)
			{
				return false;
			}
			this.dragInitiator = dragInitiator;
			stage = dragInitiator.stage;
			this.dockSource = dockSource;
			createDockHint();
			createDragProxyImage(dragInitiator,e);
			
			
			stage.addEventListener(MouseEvent.MOUSE_UP,handleDockComplete);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,handleDockMove);
			
			bDoingDock = true;
			return true;
		}	

		private function endDock():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP,handleDockComplete);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,handleDockMove);
			
			dockSource = null;
			bDoingDock = false;
			removeDockHint();
			removeDragProxyImage();
			finder.clear();
			
			CursorManager.removeCursor(cursorID);
        	cursorID = CursorManager.NO_CURSOR;
        
			if(PendApp!=null)
			{
				_app=PendApp;
				PendApp=null;
			}
		}

		private function handleDockMove(e:MouseEvent):void
		{			
			var appMousePt:Point = new Point(app.mouseX, app.mouseY);
			var appRect:Rectangle = app.getBounds(app);
			
			if(!appRect.containsPoint(appMousePt))
			{
				updateState(DISABLE);
				return;
			}

			var newTarget:DisplayObject = findObjectsUnderPoint();	
			if(newTarget==null)
			{
				handleHitNothing();
				return;
			}
					
			if( dockSource.allowMultiTab && finder.findTabBar(newTarget))
			{
				if( finder.checkTabBar(dockSource) )
				{
					updateState(TAB);
				}else{
					updateState(DISABLE);
				}
				return;
			}
			if( ( dockSource.dockType==DockManager.DRAGPANNEL || dockSource.allowAutoCreatePanel )
			 && finder.findPanel(newTarget)
			){
				if( finder.checkPanel(dockSource) )
				{
					updateState(PANEL);
					return;
				}
			}
			handleHitNothing();
		}
		private function findObjectsUnderPoint():DisplayObject
		{
			var targetList:Array = app.getObjectsUnderPoint(new Point(app.stage.mouseX,app.stage.mouseY));
			
			var newTarget:DisplayObject;
		
			var targetIndex:int = targetList.length - 1;
			while (targetIndex >= 0)
			{
				newTarget = targetList[targetIndex];
				if( newTarget != dockHint 
				 //&& !dockHint.contains(newTarget)
				 && newTarget != dragImage 
				 && !dragImage.contains(newTarget)
				){
					return newTarget;
				}
				targetIndex--;
			}
			return null;		
		}

		private function updateState(state:String):void
		{
			if(this.state != state)
			{
				updateCursor(state);
			}
			this.state = state;
			if( state==TAB || state==PANEL )
			{
				setHintposition(finder.lastAccepter,finder.lastPosition);
				dockHint.visible=true;
			}else{
				dockHint.visible = false;
			}
			if(state==FLOAT)
			{
				dragImage.alpha = 1;
			}else{
				dragImage.alpha = 0.5;
			}			
		}
		private function setHintposition(dragAaccepter:UIComponent,position:String):void
		{
			var fullArea:Rectangle=dragAaccepter.getRect(dockHint.parent);
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
			dockHint.width = fullArea.width;
			dockHint.height = fullArea.height;
			dockHint.move(fullArea.x,fullArea.y);			
		}
	   	public function updateCursor(state:String):void
	    {
	        var newCursorClass:Class;
			var styleSheet:CSSStyleDeclaration =
							StyleManager.getStyleDeclaration("DragManager");
	
	        if (state == TAB)
	            newCursorClass = styleSheet.getStyle("copyCursor");
	        else if (state == FLOAT)
	            newCursorClass = styleSheet.getStyle("linkCursor");
	        else if (state == DISABLE)
	            newCursorClass = styleSheet.getStyle("rejectCursor");
	        else
	            newCursorClass = styleSheet.getStyle("moveCursor");
	
	        if (newCursorClass != cursorClass)
	        {
	            cursorClass = newCursorClass;
	            if (cursorID != CursorManager.NO_CURSOR)
	                CursorManager.removeCursor(cursorID);
	            cursorID = CursorManager.setCursor(cursorClass, 2, 0, 0);
	        }
	    }
		private function handleHitNothing():void
		{
			if( !dockSource.allowFloat 
			 || dockSource.tabInFloatPanel
			 || ( dockSource.dockType==DockManager.DRAGTAB && !dockSource.allowAutoCreatePanel )
			){
				updateState(DISABLE);
			}else{
				updateState(FLOAT);
			}
		}
		
		private function handleDockComplete(e:MouseEvent):void
		{

			switch(state)
			{
				case TAB:
				{
					finder.lastTabNav.dockIn(dockSource,finder.lastBtn,finder.lastPosition);
					break;
				}
				case PANEL:
				{
					movePanel(Container(finder.lastAccepter),finder.lastPosition);
					break;
				}
				case FLOAT:
				{
					floatPanel();
					break;
				}				
			}
			endDock();
		}	
		public function movePanel(accepter:Container,side:String):void
		{
			var newPanel:DockablePanel;
			if(dockSource.dockType==DockManager.DRAGTAB)
			{
				newPanel=new DockablePanel(dockSource.targetChild);
			}else if(dockSource.dockType==DockManager.DRAGPANNEL){
				newPanel = dockSource.targetPanel;
			}else{
				newPanel = new DockablePanel();
			}
			switch(side)
			{
				case DockManager.LEFT:
				case DockManager.RIGHT:
					insertPanelH(newPanel,accepter,side);
					return;
				case DockManager.TOP:
				case DockManager.BOTTOM:
					insertPanelV(newPanel,accepter,side);
					return;
			}
		}
		private function floatPanel():void
		{
			var newPanel:FloatPanel;
			if(dockSource.dockType==DockManager.DRAGTAB)
			{
				newPanel = new FloatPanel(dockSource.targetChild);
			}else if(dockSource.dockType==DockManager.DRAGPANNEL){
				newPanel = new FloatPanel(dockSource.targetTabNav);
			}else{
				newPanel = new FloatPanel(); 
			}
			
			DockManager.app.addChild(newPanel);
			
			var boundsRect:Rectangle = dragImage.getBounds(app);
			newPanel.move(boundsRect.x,boundsRect.y);
		}
				
		private function insertPanelH(dragPanel:DockablePanel,accepter:Container,side:String):void
		{
			var dAccepter:DockableHDividedBox;
			var accepterIndex:int=0;
			if(accepter.parent is DockableHDividedBox)
			{
				dAccepter = DockableHDividedBox(accepter.parent);
				accepterIndex = dAccepter.getChildIndex(accepter);
			}else{
				dAccepter = new DockableHDividedBox();
				DockHelper.replace(accepter,dAccepter);
				accepter.percentWidth = 100;
				dAccepter.addChild(accepter);
			}
			dragPanel.percentWidth = accepter.percentWidth/4;
			accepter.percentWidth *= 0.75;
			
			switch(side)
			{
				case DockManager.LEFT:
					dAccepter.addChildAt(dragPanel,accepterIndex);
					return;	
				case DockManager.RIGHT:
					dAccepter.addChildAt(dragPanel,accepterIndex+1);
					return;				
			}

		}
		private function insertPanelV(dragPanel:DockablePanel,accepter:Container,side:String):void
		{
			var dAccepter:DockableVDividedBox;
			var accepterIndex:int=0;
			if(accepter.parent is DockableVDividedBox)
			{
				dAccepter = DockableVDividedBox(accepter.parent);
				accepterIndex = dAccepter.getChildIndex(accepter);
			}else{
				dAccepter = new DockableVDividedBox();
				DockHelper.replace(accepter,dAccepter);
				accepter.percentHeight = 100;
				dAccepter.addChild(accepter);
			}
			dragPanel.percentHeight = accepter.percentHeight/4;
			accepter.percentHeight *= 0.75;
			
			switch(side)
			{
				case DockManager.TOP:
					dAccepter.addChildAt(dragPanel,accepterIndex);
					return;	
				case DockManager.BOTTOM:
					dAccepter.addChildAt(dragPanel,accepterIndex+1);
					return;				
			}
		}
		

	}
}