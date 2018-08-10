package core.node.logic;
import core.node.Node;
import core.graph.Graph;
import core.slot.Slot;

/**
 * ...
 * @author MibuWolf
 */
class LogicBaseNode extends Node
{

	private var slotIn:String;
	private var slotTrue:String;
	private var slotFalse:String;
	
	public function new(owner:Graph) 
	{
		super(owner);
		
		slotIn = "In";
		slotTrue = "True");
		slotFalse = "False";
		
		AddSlot(Slot.INITIALIZE_SLOT(slotIn, SlotType.ExecutionIn));
		AddSlot(Slot.INITIALIZE_SLOT(slotTrue, SlotType.ExecutionOut));
		AddSlot(Slot.INITIALIZE_SLOT(slotFalse, SlotType.ExecutionOut));
		
		this.groupName = "Logic";
		type = NodeType.LOGIC;
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
		if (slotIn != slotId)
			return;
			
		var result:Bool = Evaluate();
		
		EvaluateResult();
		
		SignalOutput(result ? slotTrue : slotFalse);
		
	}
	
	
}