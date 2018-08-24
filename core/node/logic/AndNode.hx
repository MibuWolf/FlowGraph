package core.node.logic;
import core.datum.Datum;
import core.graph.Graph;
import core.slot.Slot;

/**
 * ...
 * @author MibuWolf
 */
class AndNode extends LogicBaseNode
{

	private var paramSlot1:String;
	private var paramSlot2:String;
	
	public function new(owner:Graph) 
	{
		super(owner);
		name = "And";
		paramSlot1 = "Param1";
		paramSlot2 = "Param2";
		
		AddDatumSlot(Slot.INITIALIZE_SLOT(paramSlot1, SlotType.DataIn), Datum.INITIALIZE_BOOL("Param1"));
		AddDatumSlot(Slot.INITIALIZE_SLOT(paramSlot2, SlotType.DataIn),Datum.INITIALIZE_BOOL("Param2"));
	}
	
	
	// 评价逻辑(需要重载)
	override public function Evaluate():Bool
	{
		var param1:Datum = GetSlotData(paramSlot1);
		var param2:Datum = GetSlotData(paramSlot2);
		
		if (param1 == null || param2 == null)
			return false;
		
		var bParam1:Bool = param1.GetValue();
		var bParam2:Bool = param2.GetValue();
		
		return  bParam1 && bParam2;
	}
}