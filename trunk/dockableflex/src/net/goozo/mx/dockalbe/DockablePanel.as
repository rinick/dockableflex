package net.goozo.mx.dockalbe
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.TabNavigator;
	import mx.core.Application;
	import mx.core.Container;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	
[IconFile("DockablePanel.png")]

	public class DockablePanel extends ClosablePanel
	{		
				
		private var dragStarter:DragStarter=null;
		        		
		public function DockablePanel( fromChild:Container = null )
		{
			super( fromChild );
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(dragStarter==null)
			{
				dragStarter = new DragStarter(titleBar);
			}			

			dragStarter.startListen(startDragDockPanel);					
		}

		private function startDragDockPanel(e:MouseEvent):void
		{      
            var dockSource:DockSource = new DockSource(DockManager.DRAGPANNEL, tabNav, tabNav.dockId);
            dockSource.targetPanel = this;
            
            dockSource.allowMultiTab = allowMultiTab;
			dockSource.allowFloat = allowFloat;
			dockSource.allowAutoCreatePanel = allowAutoCreatePanel;
			
            DockManager.doDock(this,dockSource,e);			
		}
		public function dockAsk(source:DockSource, target:UIComponent, position:String):Boolean
		{
			if( ( target!=this || source.targetPanel!=this ) 
			 && ( tabNav.numChildren!=1 || source.targetTabNav!=tabNav )
			){
				return true;
			}else{
				return false;
			}
		}
	}
}