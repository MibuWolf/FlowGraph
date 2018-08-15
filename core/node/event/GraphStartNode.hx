package core.node.event;
import core.node.Node;
import core.slot.Slot;
import core.graph.Graph;
/**
 * ...
 * @author MibuWolf
 */
class GraphStartNode extends EventNode
{

	private var slotOutput:String;
	
	public function new(owner:Graph) 
	{
		super(owner);
		
		slotOutput = "Out";
		
		AddSlot(Slot.INITIALIZE_SLOT(slotOutput, SlotType.ExecutionOut));
	}
	
	
	public function OnTrigger():Void
	{
		this.SignalOutput(slotOutput);
	}
	
}