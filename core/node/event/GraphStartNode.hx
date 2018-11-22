package core.node.event;
import core.node.Node;
import core.graph.Graph;
import core.manager.GraphTriggerManager;
import core.datum.Datum;
/**
 * ...
 * @author MibuWolf
 */
class GraphStartNode extends TriggerNode
{

	public function new(owner:Graph) 
	{
		super(owner);
	}
	
	override public function Initialize(_nodeId:Int, _type:NodeType, _name:String = "", _groupName:String = ""):Void
	{
		super.Initialize(_nodeId, _type, _name, _groupName);
		
		GraphTriggerManager.GetInstance().RegisterTrigger(this.graph.GetGraphID(), _nodeId, "Graph", "GraphStartNode", [Datum.INITIALIZE_INT("GraphID", graph.GetGraphID())]);
	}
	
	
	override public function OnTrigger(params:Array<Any>):Void
	{
		super.OnTrigger(params);
		if (CheckDeActivate(params))
			return;
		
		this.SignalOutput(outSlotID);
	}
	
	override public function Release()
	{
		GraphTriggerManager.GetInstance().UnRegisterTrigger(this.graph.GetGraphID(), nodeId, "Graph", "GraphStartNode");
	}
	
}