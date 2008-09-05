package net.goozo.mx.dockalbe
{	
	import flash.display.DisplayObject;
	
	import mx.containers.HDividedBox;
	import mx.core.UIComponent;

[IconFile("DockableHDividedBox.png")]

	
	/**
	 *  DockableHDividedBox and DockableVDividedBox can be used just as
	 *  regular DividedBox in the MXML file.
	 *  But do not use them in actionscript file at run time, because they
	 *  will be created and removed automaticly
	 *  according to the layout of the DockablePanel instances.
	 */
	public class DockableHDividedBox extends HDividedBox implements IDockableDividedBox
	{				
		public function DockableHDividedBox()
		{
			super();
		}
		/**
		 *  @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			DockManager.newDockableApp(this);
		}
		
		/**
		 *  If there is only one child after the removing.
		 *  The DockableHDividedBox itself will be removed, and its child
		 *  will be add to its parent. 
		 */
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			var retObj:DisplayObject = super.removeChild(child);
	
			callLater(removeSelf);

			return retObj;
		}
		private function removeSelf():void
		{
			if( numChildren == 0 )
			{
				if(parent)
				{
					parent.removeChild(this);
				}
			}
			else if( numChildren == 1 
				  && ( getChildAt(0) is IDockableDividedBox || parent is IDockableDividedBox )
			){
				var onlyChild:UIComponent = UIComponent(getChildAt(0));

				removeChild(onlyChild);
				
				DockHelper.replace(this,onlyChild);
			}		
		}
		/**
		 *  @private
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			var uChild:UIComponent = UIComponent(child);
			if( (uChild is DockableHDividedBox) && uChild.initialized )
			{
				var dChild:DockableHDividedBox = DockableHDividedBox(uChild);
				
				var indexOffset:Number=0;
				var persentOffset:Number = dChild.width / width;
				

				while(dChild.numChildren>0)
				{
					var subChild:UIComponent = UIComponent(dChild.removeChildAt(0));
					subChild.percentWidth *= persentOffset;
					subChild.percentHeight = 100;
					super.addChildAt(subChild,index+indexOffset);
					indexOffset++;
				}				
			}else{
				uChild.percentHeight = 100;
				super.addChildAt(uChild,index);
			}
			return child;
		}
		/**
		 *  @private
		 */
		override public function get explicitMinWidth():Number
		{
			var superExplicitMinWidth:Number = super.explicitMinWidth;
			if(!isNaN(superExplicitMinWidth))
			{
				return superExplicitMinWidth;
			}
			var mMinWidth:Number = getStyle("paddingLeft")
								 + getStyle("paddingRight")
								 + getStyle("horizontalGap ") * numDividers ;
			for(var i:int=0 ; i<numChildren ; ++i)
			{
				mMinWidth += UIComponent(getChildAt(i)).minWidth;
			}	
			return mMinWidth ;
		}
		/**
		 *  @private
		 */
		override public function get explicitMinHeight():Number
		{
			var superExplicitMinHeight:Number = super.explicitMinHeight;
			if(!isNaN(superExplicitMinHeight))
			{
				return superExplicitMinHeight;
			}
			var mMinHeight:Number = 0;	
			for(var i:int=0 ; i<numChildren ; ++i)
			{
				mMinHeight = Math.max( mMinHeight , UIComponent(getChildAt(i)).minHeight );
			}
			return mMinHeight + getStyle("paddingTop")+ getStyle("paddingBottom");
			
		}
	}
}