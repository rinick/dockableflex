package net.goozo.mx.dockalbe
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.core.Container;
	import mx.core.UIComponent;
	
	[Event(name="titleChange", type="net.goozo.mx.dockable.TitleChanGeEvent")]
		
[IconFile("DockableTabNavigator.png")]
		
	public class DockableTabNavigator extends ClosableTabNavigator
	{
		public var allowMultiTab:Boolean = true;
		public var allowFloat:Boolean = true;
		public var allowAutoCreatePanel:Boolean = true;
		public var dockId:String = "";
		
		private var dragStarter:DragStarter;
		
		
				
		private var bPanelFloat:Boolean=false;
		public function toFloat():void
		{
			bPanelFloat=true;
		}		
        		
		public function DockableTabNavigator()
		{
			super();
		}
		

		override protected function childrenCreated():void
		{
			super.childrenCreated();
			dragStarter = new DragStarter(tabBar);
			dragStarter.startListen(startDragTab);
					
		}
		
		
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
            dockSource.allowMultiTab = allowMultiTab;
			dockSource.allowFloat = allowFloat;
			dockSource.allowAutoCreatePanel = allowAutoCreatePanel;
			
            DockManager.doDock(dragInitiator,dockSource,e);           	
		}
		
		public function dockAsk(source:DockSource, btn:UIComponent, position:String):Boolean
		{
			if( allowMultiTab
			 && (source.targetChild != selectedChild || tabBar.getChildIndex(btn)!=tabBar.selectedIndex )
			 && dockId==source.dockId
			 && ( source.dockType==DockManager.DRAGTAB || source.targetTabNav!=this )
			){
				return true;
			}else{
				return false;
			}
		}
		public function dockIn(source:DockSource, btn:UIComponent, position:String):void
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