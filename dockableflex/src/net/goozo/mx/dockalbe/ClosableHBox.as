package net.goozo.mx.dockalbe
{
	import mx.containers.HBox;
	
	public class ClosableHBox extends HBox implements IDockableTabChild
	{
		public function ClosableHBox()
		{
			super();
		}
		public function get closeTabEnabled():Boolean
		{
			return true;
		}
		public function closeTab():Boolean
		{
			return true;
		}
	}
}
