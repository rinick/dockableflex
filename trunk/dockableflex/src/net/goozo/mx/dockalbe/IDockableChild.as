package net.goozo.mx.dockalbe
{
	import mx.core.IContainer;
	
	public interface IDockableChild extends IContainer
	{
		function get tabCloseEnabled():Boolean;
		function closeTab():void;
	}
}