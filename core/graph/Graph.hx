package core.graph;
import core.node.Node;
import core.slot.Slot;

/**
 * 流图类
 * @author confiner
 */
class Graph
{
	private var graphId(default, null):Int;		// 流图id
	
	private var nodes:Map<Int, Node>;			// 所有节点信息
	private var connection:Array<Connection>;		// 所有节点关系
	private var executStack:ExecutionStack;
	
	public function new(graphId:Int = -1) 
	{
		this.graphId = graphId;
		this.nodes = new Map<Int, Node>();
		this.connection = new Array<Connection>();
		this.executStack = new ExecutionStack();
	}
	
	
	// 获取流图ID
	public function GetGraphID()
	{
		return graphId;
	}
	
	// 开始流图
	public function Start():Void
	{
		Clear();
		
		Execute();
	}
	
	// 停止流图
	public function Stop():Void
	{
		Clear();
	}
	
	// 清理流图
	private function Clear():Void
	{
		
	}
	
	
	// 添加进入执行栈
	public function AddToExecutionStack(endPoint:EndPoint):Void
	{
		if(executStack != null && endPoint != null)
			executStack.Add(endPoint);
	}
	
	// 执行
	public function Execute():Void
	{
		while (executStack.GetCount() > 0)
		{
			//if (executStack.GetCount() > 1000)
			//	// 死循环?
				
			var endpoint:EndPoint = executStack.Get();
			var node:Node = GetNode(endpoint.GetNodeID());
			
			if (node != null)
			{
				// 节点存在则进入节点相应的插槽
				node.SignalInput(endpoint.GetSlotID());
			}
		}
	}
	
	// 添加节点
	public function AddNode(node:Node):Void
	{
		this.nodes.set(node.GetNodeID(),node);
	}
	
	
	// 查找节点
	public function GetNode(nodeID:Int):Node
	{
		if(nodes.exists(nodeID))
			return this.nodes.get(nodeID);
			
		return null;
	}
	
	// 移除节点
	public function RemoveNode(nodeID:Int):Void
	{
		if (nodes.exists(nodeID))
			nodes.remove(nodeID);
	}
	
	// 添加关系
	public function AddConnection(sNID:Int, sSID:String, tNID:Int, tSID:String):Bool
	{
		if (FindConnection(sNID, sSID, tNID, tSID) != -1)
			return false;

		var con:Connection = new Connection(sNID, sSID, tNID, tSID);
		this.connection.push(con);

		return true;
	}
	
	
	// 查找关系
	public function FindConnection(sNID:Int, sSID:String, tNID:Int, tSID:String):Int
	{
		var con:Connection = null;
		var index:Int = -1;
		
		for (con in connection)
		{
			index++;
			if (con != null && con.IsEqual(sNID, sSID, tNID, tSID))
				return index;
		}
		
		return -1;
	}
	
	
	// 删除关系
	public function RemoveConnection(sNode:Int, sSlot:String, tNode:Int, tSlot:String):Void
	{
		var index:Int = FindConnection(sNode, sSlot, tNode, tSlot);
		
		if (index == -1)
			return;
			
		this.connection.remove(this.connection[index]);
	}
	
	
	// 根据nodeid slotid查找所有有关的节点数据
	public function GetAllEndPoints(sNID:Int, sSID:String):Array<EndPoint>
	{
		var allEndPoints:Array<EndPoint> = new Array<EndPoint>();
		
		var con:Connection = null;
		for (con in connection)
		{
			if (con != null && con.IsSourceEndPoint(sNID, sSID))
			{
				allEndPoints.push(con.GetTargetEndPoint());
			}
		}
		
		return allEndPoints;
	}
	
}