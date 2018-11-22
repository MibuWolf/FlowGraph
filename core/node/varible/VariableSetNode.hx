package core.node.varible;
import core.datum.Datum;
import core.graph.Graph;
import core.slot.Slot;
/**
 * ...
 * @author ...
 */
class VariableSetNode extends ExecuteNode
{
	
	private var paramSlots:String;
	
	public function new(owner:Graph) 
	{
		super(owner);
	
		this.name = "Set";
		this.groupName = "VariableGraph";
	}
	
	public function Initialization(data:Datum):Bool
	{
		if (data == null) 
		{
			return false;
		}
		this.paramSlots = data.GetName();
		
		var paramSlot:Slot = Slot.INITIALIZE_SLOT(data.GetName(), SlotType.DataIn);
		this.AddDatumSlot(paramSlot, data);
		
		return true;
	}
	
	
	// 进入该节点进行逻辑评价
	override public function SignalInput(outSlot:String):Void
	{
		if (CheckDeActivate(outSlot))
			return;
			
		var data:Datum = this.GetSlotData(paramSlots);
		graph.SetVaribleValue(paramSlots, data.GetValue());
		
		SignalOutput(outSlotId);
	}
	
	override public function Release()
	{
		super.Release();
	}
	
}