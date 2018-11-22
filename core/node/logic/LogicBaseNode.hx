package core.node.logic;
import core.node.Node;
import core.graph.Graph;
import core.slot.Slot;

/**
 * ...
 * @author MibuWolf
 */
class LogicBaseNode extends ExecuteNode
{

	private var slotTrue:String;
	private var slotFalse:String;
	//private var slotIn:String;
	
	public function new(owner:Graph) 
	{
		super(owner);
		
		slotTrue = "True";
		slotFalse = "False";
		//slotIn = "In";
		
		//AddSlot(Slot.INITIALIZE_SLOT(slotIn, SlotType.ExecutionIn));
		AddSlot(Slot.INITIALIZE_SLOT(slotTrue, SlotType.ExecutionOut));
		AddSlot(Slot.INITIALIZE_SLOT(slotFalse, SlotType.ExecutionOut));
		
		this.groupName = "Logic";
		type = NodeType.logic;
	}
	
	
	
	// 评价逻辑(需要重载)
	public function Evaluate():Bool
	{
		return true;
	}
	
	
	// 结果参数传递(需要重载)
	public function EvaluateResult():Void
	{
		
	}
	
	
	// 进入该节点进行逻辑评价
	override public function SignalInput(slotId:String):Void
	{
		if (inSlotId != slotId)
			return;
		
			
		var result:Bool = Evaluate();
		
		EvaluateResult();
		SignalOutput(outSlotId);
		
		SignalOutput(result ? slotTrue : slotFalse);
		
	}
	
	
}