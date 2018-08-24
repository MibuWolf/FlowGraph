package core.node.logic;
import core.datum.Datum;
import core.graph.Graph;
import core.slot.Slot;
/**
 * ...
 * @author MibuWolf
 */
class StringCompareNode extends LogicBaseNode
{
	private var paramSlot1:String;
	private var paramSlot2:String;
	
	public function new(owner:Graph) 
	{
		super(owner);
		name = "StringCompare";
		paramSlot1 = "Param1";
		paramSlot2 = "Param2";
		
		AddDatumSlot(Slot.INITIALIZE_SLOT(paramSlot1, SlotType.DataIn), Datum.INITIALIZE_STRING("Param1"));
		AddDatumSlot(Slot.INITIALIZE_SLOT(paramSlot2, SlotType.DataIn),Datum.INITIALIZE_STRING("Param2"));
	}
	
	
	// 评价逻辑(需要重载)
	override public function Evaluate():Bool
	{
		var param1:Datum = GetSlotData(paramSlot1);
		var param2:Datum = GetSlotData(paramSlot2);
		
		if (param1 == null || param2 == null)
			return false;
		
		var fParam1:String = param1.GetValue();
		var fParam2:String = param2.GetValue();
		
		return (fParam1==fParam2);
	}
	
}