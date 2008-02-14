package net.goozo.mx.dockalbe
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.core.Container;
	import mx.core.UIComponent;
	
[IconFile("DockablePanel.png")]

	public class DockablePanel extends ClosablePanel
	{		
				
		private var dragStarter:DragStarter = null;
		
		public var lockPanel:Boolean =  false;

		override public function get allowFloat():Boolean
		{
			return !lockPanel && tabNav.allowFloat;
		}
		        		
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
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			if(lockPanel && child==tabNav)
			{
				return child;
			}
			return super.removeChild(child);
		}

		private function startDragDockPanel(e:MouseEvent):void
		{      
            var dockSource:DockSource = new DockSource(DockManager.DRAGPANNEL, tabNav, tabNav.dockId);
            dockSource.targetPanel = this;
            
            dockSource.allowMultiTab = allowMultiTab;
			dockSource.allowFloat = allowFloat;
			dockSource.allowAutoCreatePanel = allowAutoCreatePanel;
			
			dockSource.lockPanel = lockPanel;
			
			
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