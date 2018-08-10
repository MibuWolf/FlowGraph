package core.node.logic;
import core.datum.Datum;
import core.graph.Graph;
import core.slot.Slot;

/**
 * ...
 * @author MibuWolf
 */
class OrNode extends LogicBaseNode
{

	private var paramSlot1:String;
	private var paramSlot2:String;
	
	public function new(owner:Graph) 
	{
		super(owner);
		
		paramSlot1 = "Param1";
		paramSlot2 = "Param2";
		
		AddDatumSlot(Slot.INITIALIZE_SLOT(paramSlot1, SlotType.DataIn), Datum.INITIALIZE_BOOL());
		AddDatumSlot(Slot.INITIALIZE_SLOT(paramSlot2, SlotType.DataIn),Datum.INITIALIZE_BOOL());
	}
	
	
	// 评价逻辑(需要重载)
	override public function Evaluate():Bool
	{
		var param1:Datum = GetSlotData(paramSlot1);
		var param2:Datum = GetSlotData(paramSlot2);
		
		var bParam1:Bool = false;
		var bParam2:Bool = false;
		
		if (param1 != null )
			bParam1 = param1.GetValue();
			
		if (param2 != null )
			bParam2 = param2.GetValue();
		
		return  bParam1 || bParam2;
	}
}