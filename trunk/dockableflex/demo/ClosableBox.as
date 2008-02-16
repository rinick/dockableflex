package
{
	import mx.containers.VBox;
	
	import net.goozo.mx.dockalbe.IDockableChild;

	public class ClosableBox extends VBox implements IDockableChild
	{
		public function ClosableBox()
		{
			super();
		}
		public function get tabCloseEnabled():Boolean
		{
			return true;
		}
		public function closeTab():Boolean
		{
			return true;
		}
	}
}