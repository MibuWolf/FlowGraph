package core.graph;
import core.node.Node;
import core.manager.GraphTriggerManager;
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
	
	private var startID:Int = -1;			// 开始节点ID
	private var endID:Int = -1;				// 流图节点结束ID
	
	private var userId:Int;
	
	private var bActivate:Bool = true;			// 流图当前是否激活
	
	public function new(graphId:Int = -1, entityId:Int = -1) 
	{
		this.graphId = graphId;
		this.nodes = new Map<Int, Node>();
		this.connection = new Array<Connection>();
		this.executStack = new ExecutionStack();
		this.userId = entityId;
		this.bActivate = true;
	}
	
	
	// 获取流图ID

	public function GetGraphID()
	{
		return graphId;
	}
	
	// 开始流图
	public function Start():Void
	{
		Activate(true);
		GraphTriggerManager.GetInstance().OnTrigger(["Graph", "GraphStartNode", graphId]);
	}
	
	// 停止流图
	public function Stop():Void
	{
		Activate(false);
		executStack.Release();
	}
	
	
	// 激活/暂停
	public function Activate(bEnable:Bool):Void
	{
		bActivate = bEnable;
		
		for (node in this.nodes)
		{
			if (node != null)
				node.Activate(bEnable);
		}
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
	
	public function GetOwnerID():Int
	{
		return this.userId;
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
	
	// 设置开始节点ID
	public function SetStartNodeID(id:Int):Void
	{
		startID = id;
	}
	
	
	// 获取开始节点ID
	public function GetStartNodeID():Int
	{
		return startID;
	}
	
	
	// 设置结束节点ID
	public function SetEndNodeID(id:Int):Void
	{
		endID = id;
	}
	
	
	// 获取开始节点ID
	public function GetEndNodeID():Int
	{
		return endID;
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
	
	public function GetInTransEndPoint(sNID:Int, sSID:String):EndPoint
	{
		//var con:Connection = null;
		for (con in connection) 
		{
			if (con != null && con.IsTargetEndPoint(sNID, sSID))
			{
				return con.GetSourceEndPoint();
			}
		}
		
		return null;
	}
	
	
	// 根据nodeid slotid查找所有有关的节点数据
	public function GetAllEndPoints(sNID:Int, sSID:String):Array<EndPoint>
	{
		var allEndPoints:Array<EndPoint> = new Array<EndPoint>();
		

		//var con:Connection = null;
		for (con in connection)
		{
			if (con != null && con.IsSourceEndPoint(sNID, sSID))
			{
				allEndPoints.push(con.GetTargetEndPoint());
			}
		}
		
		return allEndPoints;
	}
	
	
	// 清理
	public function Release()
	{
		
	}
	
}