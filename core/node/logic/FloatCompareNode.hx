package core.node.logic;
import core.datum.Datum;
import core.graph.Graph;
import core.slot.Slot;
/**
 * ...
 * @author MibuWolf
 */
class FloatCompareNode extends LogicBaseNode
{

	private var paramSlot1:String;
	private var compareSlot:String;
	private var paramSlot2:String;

	public function new(owner:Graph) 
	{
		super(owner);
		name = "FloatCompare";
		paramSlot1 = "Param1";
		compareSlot = "Op";
		paramSlot2 = "Param2";
		
		AddDatumSlot(Slot.INITIALIZE_SLOT(paramSlot1, SlotType.DataIn), Datum.INITIALIZE_FLOAT("Param1"));
		AddDatumSlot(Slot.INITIALIZE_SLOT(compareSlot, SlotType.DataIn), Datum.INITIALIZE_STRING("Op","=="));
		AddDatumSlot(Slot.INITIALIZE_SLOT(paramSlot2, SlotType.DataIn),Datum.INITIALIZE_FLOAT("Param2"));
	}
	
	
	// 评价逻辑(需要重载)
	override public function Evaluate():Bool
	{
		var param1:Datum = GetSlotData(paramSlot1);
		var param2:Datum = GetSlotData(paramSlot2);
		var op:Datum = GetSlotData(compareSlot);
		
		if (param1 == null || param2 == null || op == null)
			return false;
		
		var fParam1:Float = param1.GetValue();
		var fParam2:Float = param2.GetValue();
		var sOp:String = op.GetValue();
		
		if (sOp == "==")
		{
			return (fParam1 == fParam2);
		}
		
		if (sOp == ">=")
		{
			return (fParam1 >= fParam2);
		}
		
		if (sOp == "<=")
		{
			return (fParam1 <= fParam2);
		}
		
		if (sOp == "!=")
		{
			return (fParam1 != fParam2);
		}
		
		if (sOp == ">")
		{
			return (fParam1 > fParam2);
		}
		
		if (sOp == "<")
		{
			return (fParam1 < fParam2);
		}
		
		return false;
	}
	
}