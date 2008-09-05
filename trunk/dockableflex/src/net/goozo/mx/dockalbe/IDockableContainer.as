package net.goozo.mx.dockalbe 
{
	import mx.core.IContainer;

[ExcludeClass]

	public interface IDockableContainer extends IContainer
	{
		function get floatEnabled():Boolean;
		function closeChild():void;
	}
	
}