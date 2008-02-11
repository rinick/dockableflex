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

		private function handleCloseTab(e:Event):void
		{
			tabNav.closeTab();
		}
		
	}
}