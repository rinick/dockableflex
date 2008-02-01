package net.goozo.mx.dockalbe
{
	import mx.core.Container;
	
	public class DockSource
	{
		public var dockType:String;
		public var dockId:String;
		
		public var allowMultiTab:Boolean=true;
		public var allowFloat:Boolean=true;
		public var allowAutoCreatePanel:Boolean=true;
		public var tabInFloatPanel:Boolean=false;
		
		public var targetTabNav:DockableTabNavigator
		public var targetChild:Container;
		public var targetPanel:DockablePanel;
		
		

		
		public function DockSource(dockType:String,targetTabNav:DockableTabNavigator,dockId:String="")
		{
			this.dockType = dockType;
			this.targetTabNav = targetTabNav;
			this.dockId = dockId;
		}

	}
}