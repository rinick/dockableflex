package net.goozo.mx.dockalbe
{
	import flash.events.MouseEvent;
	
	import mx.core.Container;
	import mx.core.UIComponent;
	
	public class DockManager
	{
		public static const LEFT:String = "dockLeft";
		public static const RIGHT:String = "dockRight";
		public static const TOP:String = "dockTop";
		public static const BOTTOM:String = "dockBottom";
		public static const WHOLE:String = "dockWhole";
		public static const FLOAT:String = "dockFloat";

		public static const OUTSIDE:String = "outside";
			
		public static const DRAGTAB:String = "dragTab";
		public static const DRAGPANNEL:String = "dragPannel";
	
		private static var _impl:DockManagerImpl=null;
		private static function get impl():DockManagerImpl
		{
			if(_impl==null)
			{
				_impl=new DockManagerImpl();
			}
			return _impl;
		}
		
		public static function hasApp():Boolean
		{
			return impl.hasApp();
		}
		public static function get app():Container
		{
			return impl.app;
		}
		public static function set app(value:Container):void
		{
			impl.app=value;
		}
						
		public static function doDock( dragInitiator:UIComponent, dockSource:DockSource, e:MouseEvent ):Boolean
		{
			return impl.doDock(dragInitiator,dockSource,e);
		}
		
		public static function newDockableApp(dividedBox:IDockableDividedBox):void
		{
			impl.newDockableApp(UIComponent(dividedBox));
		}


	}
}