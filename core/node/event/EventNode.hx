package core.node.event;
import core.graph.Graph;
import core.node.Node;
import core.slot.Slot;
/**
 * 事件触发节点基类
 * @author MibuWolf
 */
class EventNode extends Node
{
	// 输出参数插槽
	private var paramSlots:Array<String>;
	
	// 输出插槽
	private var outSlotID:String = "Out";
	
	public function new(graph:Graph) 
	{
		super(graph);
	
		AddSlot(Slot.INITIALIZE_SLOT(outSlotID, SlotType.ExecutionOut));
		
		paramSlots = new Array<String>();
	}
	
}