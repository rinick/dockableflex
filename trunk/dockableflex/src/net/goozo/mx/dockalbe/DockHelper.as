package net.goozo.mx.dockalbe
{
	import mx.core.Container;
	import mx.core.UIComponent;
	
	internal class DockHelper
	{		
		public static function replace(dest:UIComponent,source:UIComponent):void
		{
			if(dest.parent==null)
			{
				return;
			}
			source.x = dest.x;
			source.y = dest.y;
			source.height = dest.height;
			source.width = dest.width;
			source.percentHeight = dest.percentHeight;
			source.percentWidth = dest.percentWidth;
			source.setStyle("left",dest.getStyle("left"));
			source.setStyle("right",dest.getStyle("right"));
			source.setStyle("top",dest.getStyle("top"));
			source.setStyle("bottom",dest.getStyle("bottom"));
			source.setStyle("baseline",dest.getStyle("baseline"));
			source.setStyle("horizontalCenter",dest.getStyle("horizontalCenter"));
			source.setStyle("verticalCenter",dest.getStyle("verticalCenter"));
				
			var findIndex:int=dest.parent.getChildIndex(dest);
			dest.parent.addChildAt(source,findIndex);
			dest.parent.removeChild(dest);			
		}
		
		public static function createPanel(item:Container):DockablePanel
		{
			var newPanel:DockablePanel = new DockablePanel();
			var newTabNav:DockableTabNavigator = new DockableTabNavigator();
			newPanel.addChild(newTabNav);
			if( item.parent!=null && item.parent is DockableTabNavigator )
			{
				var oldTabNav:DockableTabNavigator = DockableTabNavigator(item.parent);
				newTabNav.allowAutoCreatePanel = oldTabNav.allowAutoCreatePanel;
				newTabNav.allowFloat = oldTabNav.allowFloat;
				newTabNav.allowMultiTab = oldTabNav.allowMultiTab;
				
				item.parent.removeChild(item);
			}
			
			newPanel.addChild(item);
			return newPanel;
		}
		
			
	}
}