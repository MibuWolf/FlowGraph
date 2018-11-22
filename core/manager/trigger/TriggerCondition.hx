package core.manager.trigger;
import core.datum.Datum;
import core.graph.Graph;
import core.node.event.TriggerNode;

/**
 * ...
 * @author MibuWolf
 */
class TriggerCondition 
{
	private var graphID:Int;
	private var nodeID:Int;
	private var condition:Array<Datum>;
	
	public function new(gID:Int,nID:Int,cons:Array<Datum>) 
	{
		graphID = gID;
		nodeID = nID;
		condition = cons;
	}
	
	
	public function Evaluate(param:Array<Any>):Void
	{
		if (condition == null)
		{
			OnTrigger(param);
			return;
		}
		
		if (condition.length > param.length)
			return;
		
		var index:Int = 0;
		
		for (data in condition)
		{
			if (data.GetDatumType() == DatumType.USERID) 
			{
				var did:Int = Std.parseInt(data.GetValue());
				var pid:Int = Std.parseInt(param[index++]);
				if (did!=pid) 
				{
					return;
				}
			}
			else
			{
				if (data.GetValue() != param[index++])
					return;
			}
		}
		
		OnTrigger(param);
	}
	
	
	// 触发
	private function OnTrigger(param:Array<Any>):Void
	{
		var graph:Graph = GraphManager.GetInstance().GetGraph(graphID);
		
		if (graph == null)
			return;
			
		var triggerNode:TriggerNode = cast(graph.GetNode(nodeID),TriggerNode);
		
		if(triggerNode == null)
			return;
			
		triggerNode.OnTrigger(param);
		
	}
	
	public function Clone():TriggerCondition
	{
		var cloneCondi:Array<Datum> = new Array<Datum>();
		for (item in this.condition)
		{
			cloneCondi.push(item.Clone());
		}
		var data:TriggerCondition = new TriggerCondition(this.graphID, this.nodeID, cloneCondi);
		
		return data;
	}
	
	// 清理
	public function Release():Void
	{
		graphID = -1;
		nodeID = -1;
		condition = null;
	}
}