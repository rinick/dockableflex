package net.goozo.mx.dockalbe
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.TabNavigator;
	import mx.containers.TitleWindow;
	import mx.core.Container;
	import mx.core.ScrollPolicy;
	import mx.events.CloseEvent;

	public class ClosablePanel extends TitleWindow
	{
		protected var tabNav:DockableTabNavigator=null;

		public function get allowMultiTab():Boolean
		{
			if(tabNav!=null)
			{
				return tabNav.allowMultiTab;
			}
			return false;
		}
		public function get allowFloat():Boolean
		{
			if(tabNav!=null)
			{
				return tabNav.allowFloat;
			}
			return false;
		}
		public function get allowAutoCreatePanel():Boolean
		{
			if(tabNav!=null)
			{
				return tabNav.allowAutoCreatePanel;
			}
			return false;
		}
		
		
//		private var dragStarter:DragStarter=null;
//		
//		private var dockAccepter:Container;
		       		
//		private function setTypeDock():void
//		{
//			if(_dockState != DOCKING)
//			{
//				_dockState = DOCKING;
//				dragStarter.startListen(startDragDockPanel);	
//			}			
//		}

//		public function setTypeFloat():void
//		{			
//			if(_dockState != FLOATING)
//			{
//				_dockState = FLOATING;
//				if(parent!=null)
//				{
//					parent.removeChild(this);
//				}
//				DockManager.app.addChild(this);
//				tabNav.toFloat();
//							
//				dragStarter.startListen(startDragFloatPanel);
//				
//				addEventListener(MouseEvent.MOUSE_DOWN,floatClickPanel);
//				callLater(fixFloatSize);
//			}
//		}
//		private function fixFloatSize():void
//		{
//			if(Application(Application.application).initialized)
//			{
//				var tMinWidth:Number = minWidth;
//				var tMinHeight:Number = minHeight;
//				if( width < tMinWidth
//				 && width < tMinWidth*2
//				 && height < tMinHeight
//				 && height < tMinHeight*2
//				){
//					width = width;
//					height = height;
//				}else{
//					width = Math.max(DockManager.app.width/3,tMinWidth);
//					height = Math.max(DockManager.app.height/3,tMinHeight);					
//				}
//			}
//		}
		
		public function ClosablePanel( fromChild:Container = null )
		{
			super();
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;
			addEventListener(CloseEvent.CLOSE,handleCloseTab);
			
			if( fromChild != null )
			{
				if( fromChild is DockableTabNavigator )
				{
					addChild(fromChild);
				}else{
					var newTabNav:DockableTabNavigator = new DockableTabNavigator();
					addChild(newTabNav);
					if( fromChild.parent!=null && fromChild.parent is DockableTabNavigator )
					{
						var oldTabNav:DockableTabNavigator = DockableTabNavigator(fromChild.parent);
						newTabNav.allowAutoCreatePanel = oldTabNav.allowAutoCreatePanel;
						newTabNav.allowFloat = oldTabNav.allowFloat;
						newTabNav.allowMultiTab = oldTabNav.allowMultiTab;
					}			
					addChild(fromChild);					
				}	
			}
		}
		override public function addChild(child:DisplayObject):DisplayObject
		{
			return addChildAt(child, -1);
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(tabNav!=null)
			{
				if( index == -1 )
				{
					return  tabNav.addChild(child);
				}else{
					return  tabNav.addChildAt(child,index);
				}
				
			}else{
				if( child is TabNavigator )
				{
					tabNav = DockableTabNavigator(child);
					super.addChildAt(tabNav,0);		
				}else{
					tabNav = new DockableTabNavigator();
					super.addChildAt(tabNav,0);
					tabNav.addChildAt(child,0);
					title = Container(child).label;
				}

				tabNav.percentWidth = 100;
				tabNav.percentHeight = 100;
				tabNav.addEventListener(ChildChangeEvent.CHANGE,handleChangeChild);

				return child;
			}		
		}
		private function handleChangeChild(e:ChildChangeEvent):void
		{
			title=e.newTitle;
			showCloseButton = e.useCloseButton;
		}

		
//		override protected function createChildren():void
//		{
//			super.createChildren();
//			
//			if(dragStarter==null)
//			{
//				dragStarter = new DragStarter(titleBar);
//			}			
//			
//			
//			if(parent ==DockManager.app
//			 && _dockState!=FLOATING
//			 && isNaN(percentHeight)
//			 && isNaN(percentWidth)
//			 && !Application(Application.application).initialized
//			){
//				_dockState = TOFLOATING;
//			}
//			switch(_dockState)
//			{
//				case TODOCKING:
//					setTypeDock();
//					break;
//				case TOFLOATING:
//					setTypeFloat();
//					break;
//			}					
//		}
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			var retObj:DisplayObject = super.removeChild(child);
			if(numChildren == 0 )
			{
				parent.removeChild(this);
			}
			return retObj;
		}
		override public function get explicitMinWidth():Number
		{
			var superExplicitMinWidth:Number = super.explicitMinWidth;
			if(!isNaN(superExplicitMinWidth))
			{
				return superExplicitMinWidth;
			}
			if(tabNav!=null)
			{
				return tabNav.explicitMinWidth + getStyle("paddingLeft")+ getStyle("paddingRight");
			}else{
				return getStyle("paddingLeft")+ getStyle("paddingRight");
			}
			
		}
		override public function get explicitMinHeight():Number
		{
			var superExplicitMinHeight:Number = super.explicitMinHeight;
			if(!isNaN(superExplicitMinHeight))
			{
				return superExplicitMinHeight;
			}
			if(tabNav!=null)
			{
				return tabNav.explicitMinHeight + getStyle("paddingTop")+ getStyle("paddingBottom");
			}else{
				return getStyle("paddingTop")+ getStyle("paddingBottom");
			}
		}

//		private function startDragDockPanel(e:MouseEvent):void
//		{      
//            var dockSource:DockSource = new DockSource(DockManager.DRAGPANNEL, tabNav, tabNav.dockId);
//            dockSource.targetPanel = this;
//            
//            dockSource.allowMultiTab = allowMultiTab;
//			dockSource.allowFloat = allowFloat;
//			dockSource.allowAutoCreatePanel = allowAutoCreatePanel;
//			
//            DockManager.doDock(this,dockSource,e);			
//		}
//		public function dockAsk(source:DockSource, target:UIComponent, position:String):Boolean
//		{
//			if( ( target!=this || source.targetPanel!=this ) 
//			 && _dockState==DOCKING
//			 && ( tabNav.numChildren!=1 || source.targetTabNav!=tabNav )
//			){
//				return true;
//			}else{
//				return false;
//			}
//		}
//		
//		private function startDragFloatPanel(e:MouseEvent):void
//		{
//			startDrag();
//			stage.addEventListener(MouseEvent.MOUSE_UP,stopDragFloatPanel);
//		}
//		private function stopDragFloatPanel(e:MouseEvent):void
//		{
//			stage.removeEventListener(MouseEvent.MOUSE_UP,stopDragFloatPanel);
//			stage.removeEventListener(MouseEvent.MOUSE_MOVE,ajustFloatSize);
//			stopDrag();
//		}
//		private function floatClickPanel(e:MouseEvent):void
//		{
//			parent.setChildIndex(this,parent.numChildren-1);
//			if( mouseX<width && mouseX>width-6 && mouseY<height && mouseY>height-6 )
//			{
//				stage.addEventListener(MouseEvent.MOUSE_MOVE,ajustFloatSize);
//				stage.addEventListener(MouseEvent.MOUSE_UP,stopDragFloatPanel);
//			}
//		}
//		private function ajustFloatSize(e:MouseEvent):void
//		{
//			width = Math.max(mouseX+3,minWidth);
//			height = Math.max(mouseY+3,minHeight);
//		}
		private function handleCloseTab(e:Event):void
		{
			tabNav.closeTab();
		}
		
	}
}