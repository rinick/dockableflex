package
{
	import mx.containers.VBox;
	
	import net.goozo.mx.dockalbe.IDockableTabChild;

	public class ClosableBox extends VBox implements IDockableTabChild
	{
		public function ClosableBox()
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
