package core.node.graphnode;
import core.graph.Graph;
import core.datum.Datum;
import core.node.event.TriggerNode;
import core.manager.GraphTriggerManager;
import core.node.Node.NodeType;
import core.manager.GraphManager;

/**
 * ...
 * @author ...
 */
class GraphEndNode extends TriggerNode
{

	public function new(owner:Graph) 
	{
		super(owner);
	}
	
	
	override public function Initialize(_nodeId:Int, _type:NodeType, _name:String = "", _groupName:String = ""):Void
	{
		super.Initialize(_nodeId, _type, _name, _groupName);
		
		GraphTriggerManager.GetInstance().RegisterTrigger(this.graph.GetGraphID(), _nodeId, "Graph", "EndGraph", [Datum.INITIALIZE_INT("GraphID", graph.GetGraphID())]);
	}
	
	
	override public function OnTrigger(params:Array<Any>):Void
	{
		super.OnTrigger(params);
		if (CheckDeActivate(params))
			return;
		this.graph.Stop();
		GraphManager.GetInstance().RemoveGraph(this.graph.GetGraphID());
	}
	
	override public function Release()
	{
		GraphTriggerManager.GetInstance().UnRegisterTrigger(this.graph.GetGraphID(), nodeId, "Graph", "EndGraph");
	}
}