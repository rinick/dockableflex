package net.goozo.mx.dockalbe
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.core.Container;
	import mx.core.UIComponent;
	
	[Event(name="childChange", type="net.goozo.mx.dockable.ChildChangeEvent")]
		
[IconFile("DockableTabNavigator.png")]

	/**
	 *  <p>DockableTabNavigator is a special TabNavigator control
	 */
	public class DockableTabNavigator extends ClosableTabNavigator implements IDockableContainer
	{
		/**
		 *  @private
		 */
		protected var _floatEnabled:Boolean = true;
		
		/**
		 *  floatEnabled indicates whether the children in this tabnavigator
		 *  can be dragged out and canverted to a FloatPanel.
		 *  @default true
		 * 
		 *  @see FloatPanel
		 */
		public function get floatEnabled():Boolean
		{
			return _floatEnabled;
		}
		public function set floatEnabled( value:Boolean):void
		{
			_floatEnabled = value;
		}
		
		/**
		 *  multiTabEnabled indicates whether the tabNavigator allows
		 *  more than one child.
		 *  @default true
		 */
		public var multiTabEnabled:Boolean = true;
		
		/**
		 *  If autoCreatePanelEnabled is false, the children in this
		 *  DockableTabNavigator can only be dropped into another existing
		 *  DockableTabNavigator. 
		 * 
		 *  If autoCreatePanelEnabled is true, A DockablePanel or a FloatPanel
		 *  will be created when necessary. And the child will be put into a
		 *  new DockableTabNavigator.
		 *  @default true
		 */
		public var autoCreatePanelEnabled:Boolean = true;
		
		/**
		 *  A DockableTabNavigator will refused to accept the child from
		 *  another DockableTabNavigator with a different dockId.
		 *  @default ""
		 */
		public var dockId:String = "";
		
		private var dragStarter:DragStarter;
		
		
				
		private var bPanelFloat:Boolean = false;
		
		/**
		 *  @private
		 */
		internal function toFloat():void
		{
			bPanelFloat=true;
		}		
        
		/**
		 *  Constructor
		 */
		public function DockableTabNavigator()
		{
			super();
		}
		
		/**
		 *  @private
		 */
		override protected function childrenCreated():void
		{
			super.childrenCreated();
			dragStarter = new DragStarter(tabBar);
			dragStarter.startListen(startDragTab);
					
		}
		
		/**
		 *  @private
		 */
		override public function get explicitMinWidth():Number
		{
			var superExplicitMinWidth:Number = super.explicitMinWidth;
			if(!isNaN(superExplicitMinWidth))
			{
				return superExplicitMinWidth;
			}
			if(selectedChild!=null && !isNaN(selectedChild.explicitMinWidth) )
			{
				return selectedChild.explicitMinWidth + getStyle("paddingLeft")+ getStyle("paddingRight");
			}else{
				return getStyle("paddingLeft")+ getStyle("paddingRight");
			}
			
		}
		/**
		 *  @private
		 */
		override public function get explicitMinHeight():Number
		{
			var superExplicitMinHeight:Number = super.explicitMinHeight;
			if(!isNaN(superExplicitMinHeight))
			{
				return superExplicitMinHeight;
			}
			if( selectedChild!=null && !isNaN(selectedChild.explicitMinHeight) )
			{
				return tabBar.minHeight+selectedChild.explicitMinHeight + getStyle("paddingTop")+ getStyle("paddingBottom");
			}else{
				return tabBar.minHeight + getStyle("paddingTop")+ getStyle("paddingBottom");
			}
		}
				
		private function startDragTab(e:MouseEvent):void
		{
            var dragInitiator:UIComponent=UIComponent(e.target);
            
            var dockSource:DockSource = new DockSource(DockManager.DRAGTAB, this, dockId);
            dockSource.targetChild = selectedChild;
            dockSource.tabInFloatPanel = bPanelFloat;
            dockSource.multiTabEnabled = multiTabEnabled;
			dockSource.floatEnabled = floatEnabled;
			dockSource.autoCreatePanelEnabled = autoCreatePanelEnabled;
			
            DockManager.doDock(dragInitiator,dockSource,e);           	
		}
		/**
		 *  @private
		 */
		internal function dockAsk(source:DockSource, btn:UIComponent, position:String):Boolean
		{
			if( multiTabEnabled
			 && (source.targetChild != selectedChild || tabBar.getChildIndex(btn)!=tabBar.selectedIndex )
			 && dockId==source.dockId
			 && ( source.dockType==DockManager.DRAGTAB || source.targetTabNav!=this )
			){
				return true;
			}else{
				return false;
			}
		}
		/**
		 *  @private
		 */
		internal function dockIn(source:DockSource, btn:UIComponent, position:String):void
		{			
			switch(source.dockType)
			{
				case DockManager.DRAGTAB:
					tabDroped( source, btn, position );
					break;
				case DockManager.DRAGPANNEL:
					panelDroped( source )
					break;
			}
		}

		private function tabDroped(source:DockSource, btn:UIComponent, position:String):void
		{

			source.targetTabNav.removeChild(source.targetChild);
			
			var tabIndex:int = this.tabBar.getChildIndex(btn);

			if(position==DockManager.RIGHT)
			{
				++tabIndex;
			}		
			addChildAt(source.targetChild,tabIndex);				

			tabBar.getChildAt(tabIndex)["selected"]=true;//tab selection fix1
			tabBar.getChildAt(selectedIndex)["selected"]=false;//tab selection fix1
			getChildAt(selectedIndex).visible = false;//tab selection fix1
			selectedIndex=tabIndex;		
		}
		private function panelDroped(source:DockSource):void
		{
			if(source.targetTabNav==this)
			{
				return;
			}
			while(source.targetTabNav.numChildren>0)
			{
				addChild(source.targetTabNav.removeChildAt(0));
			}
		}
	}
}