package core.node.logic;
import core.datum.Datum;
import core.graph.Graph;
import core.slot.Slot;
/**
 * ...
 * @author MibuWolf
 */
class IfNode extends LogicBaseNode
{

	private var slotCondition:Int;
	
	public function new(owner:Graph) 
	{
		super(owner);
		
		slotCondition = AllocationSlotIndex();
		
		AddDatumSlot(Slot.INITIALIZE_SLOT(slotCondition, SlotType.DataIn, "Condition"),Datum.INITIALIZE_BOOL());
	}
	
	
	// 评价逻辑(需要重载)
	override public function Evaluate():Bool
	{
		var data:Datum = GetSlotData(slotCondition);
		
		if (data == null)
			return false;
			
		return data.GetValue();
	}
	
}