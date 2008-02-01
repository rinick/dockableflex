package net.goozo.mx.dockalbe
{
	import flash.events.Event;

	public class ChildChangeEvent extends Event
	{
		public static const CHANGE:String = "titleChange";
			
		public var newTitle:String="";
		public var useCloseButton:Boolean=false;
		public function ChildChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}