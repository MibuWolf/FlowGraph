package core.graphmanager;
import core.graph.Graph;
import core.node.reflect.TriggerNode;
import reflectclass.TriggerInfo;

/**
 * 运行时每个节点触发回调信息
 * @author MibuWolf
 */
class GraphTriggerInfo 
{
	// 所属流图ID
	private var graphID:Int;

	// 流图节点事件触发
	private var eventNodeList:Map<String,Array<Int>>;
	 
	public function new(id:Int) 
	{
		graphID = id;
		
		eventNodeList = new Map<String, Array<Int>>();
	}
	
	// 获取所属流图ID
	public function GetGraphID():Int
	{
		return graphID;
	}
	
	
	// 注册流图节点事件
	public function AddTriggerNode(eventName:String, nodeID:Int):Void
	{
		var nodeList:Array<Int> = null;
		
		if (eventNodeList.exists(eventName))
			nodeList = eventNodeList.get(eventName);
		else
		{
			nodeList = new Array<Int>();
			eventNodeList.set(eventName, nodeList);
		}
		
		if (nodeList.indexOf(nodeID) == -1)
		{
			nodeList.push(nodeID);
		}
	}
	
	
	// 触发事件
	public function OnTrigger(eventName:String, info:TriggerInfo):Void
	{
		var graph:Graph = GraphManager.GetInstance().GetGraph(this.graphID);
		if (graph != null && eventNodeList.exists(eventName))
		{
			var nodeList:Array<Int> = eventNodeList.get(eventName);
			
			for (nodeID in nodeList)
			{
				var triggerNode:Dynamic = graph.GetNode(nodeID);
				
				if (triggerNode != null)
					triggerNode.OnTrigger(info);
			}
		}
	}
}