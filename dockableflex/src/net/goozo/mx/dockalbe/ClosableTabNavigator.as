package net.goozo.mx.dockalbe
{
	import flash.display.DisplayObject;
	
	import mx.containers.TabNavigator;
	import mx.core.Container;
	import mx.styles.StyleProxy;

[ExcludeClass]

	internal class ClosableTabNavigator extends TabNavigator
	{
		
		public var autoRemove:Boolean = true;
		
		public function ClosableTabNavigator()
		{
			super();
		}

	    override public function set selectedIndex(value:int):void
	    {
	    	super.selectedIndex = value;
	    	
	    	var childChangeEvent:ChildChangeEvent = new ChildChangeEvent(ChildChangeEvent.CHANGE);	
	    	if(value>=0)
	    	{
		    	var newChild:Container = Container(getChildAt(value)); 	    	    	
		    	childChangeEvent.newTitle = newChild.label;
		    	if(newChild is IDockableChild)
		    	{
		    		childChangeEvent.useCloseButton = IDockableChild(newChild).tabCloseEnabled;
		    	}					    		
	    	}
	    	dispatchEvent(childChangeEvent);
	    }
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			if(child==selectedChild)
			{
				if( selectedIndex != numChildren-1 )
				{
					var childChangeEvent:ChildChangeEvent = new ChildChangeEvent(ChildChangeEvent.CHANGE);
					var newChild:Container = Container(getChildAt(selectedIndex+1));
					childChangeEvent.newTitle = newChild.label;
					if(newChild is IDockableChild)
		    		{
		    			childChangeEvent.useCloseButton = IDockableChild(newChild).tabCloseEnabled;
		    		}
		    		dispatchEvent(childChangeEvent);
				}		
			}
			
			var retObj:DisplayObject = super.removeChild(child);
			if(numChildren == 0)
			{
				if(autoRemove)
				{
					parent.removeChild(this);
				}else{
					dispatchEvent(new ChildChangeEvent(ChildChangeEvent.CHANGE));
				}
				
			}
			return retObj;
		}
		public function closeTab():void
		{
			if( selectedChild is IDockableChild
			 && IDockableChild(selectedChild).tabCloseEnabled
			 ){
			 	IDockableChild(selectedChild).closeTab();
			 	removeChild(selectedChild);
			 }
		}
	}

}