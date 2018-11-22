package core.graph;
import core.node.Node;
import core.manager.GraphTriggerManager;
import core.datum.Datum;
import reflectclass.CustomNodeInfo;
import core.debug.DebugRuntimeGraphInfo;
import core.slot.Slot;
import haxe.Json;
import core.manager.DebugManager;
import core.manager.GraphManager;
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
	
	private var graphVaribles:Map<String, Datum>;
	
	private var customNodeTempletes:Map<String, CustomNodeInfo>;
	
	private var graphName:String = "";
	
	private var isStop:Bool;
	
	// 当前流图的堆栈信息
	private var debugStack:Array<DebugRuntimeGraphInfo>;
	
	// 流图是否正处在断点调试
	private var isBreakpointRunning:Bool = false;
	
	public function new(graphId:Int = -1, entityId:Int = -1) 
	{
		this.graphId = graphId;
		this.nodes = new Map<Int, Node>();
		this.connection = new Array<Connection>();
		this.executStack = new ExecutionStack();
		this.userId = entityId;
		this.bActivate = true;
		graphVaribles = new Map<String, Datum>();
		customNodeTempletes = new Map<String, CustomNodeInfo>();
		debugStack = new Array<DebugRuntimeGraphInfo>();
		this.isBreakpointRunning = false;
		SetIsStop(true);
	}
	
	public function DebugStack():Array<DebugRuntimeGraphInfo>
	{
		return this.debugStack;
	}
	
	public function SetIsStop(value:Bool):Void
	{
		this.isStop = value;
	}
	
	public function GetIsStop():Bool
	{
		return this.isStop;
	}
	
	// 获取流图ID

	public function GetGraphID()
	{
		return graphId;
	}
	
	public function SetGraphName(name:String):Void
	{
		this.graphName = name;
	}
	
	public function GetGraphName():String
	{
		return this.graphName;
	}
	
	// 开始流图
	public function Start():Void
	{
		if (executStack != null) 
		{
			executStack.Release();
		}
		SetIsStop(false);
		GraphTriggerManager.GetInstance().OnTrigger(["Graph", "GraphStartNode", graphId]);
	}
	
	// 开始流图
	public function Quit():Void
	{
		//Activate(true);
		GraphTriggerManager.GetInstance().OnTrigger(["Graph", "EndGraph", graphId]);
	}
	
	// 停止流图
	public function Stop():Void
	{
		Activate(false);
		SetIsStop(true);
		executStack.Release();
		this.Release();
	}
	
	// debug信息加入到当前流图的堆栈
	public function AddDebugStack(debugInfo:DebugRuntimeGraphInfo, isMarge:Bool):Void
	{
		if (debugInfo == null) 
		{
			return;
		}
		var node2:Node = GetNode(debugInfo.GetCurrNode());
		if (node2 != null && node2.GetNodeType() == NodeType.event) 
		{
			while (debugStack.length > 0)
			{
				debugStack.pop();
			}
		}
		
		if (debugStack.length >= 100) 
		{
			debugStack.shift();
		}
		debugStack.push(debugInfo);
		
		if (!isMarge) 
		{
			// 如果当前流图运行的节点被断点了，触发断点
			if (DebugManager.GetInstance().isDebugMode && !DebugManager.GetInstance().IsNodeBreakpointing(debugInfo.GetGraphId(), debugInfo.GetCurrNode()) && DebugManager.GetInstance().isNodeBreakpoint(debugInfo.GetGraphName(), debugInfo.GetCurrNode())) 
			{
				this.isBreakpointRunning = true;
				DebugManager.GetInstance().pauseGraph = debugInfo.GetGraphId();
				DebugManager.GetInstance().pauseNode = debugInfo.GetCurrNode();
				var node:Node = GetNode(debugInfo.GetCurrNode());
				if (node!= null) 
				{
					node.IsBreakpointing = true;
					
					node.Activate(false);
				}
				
				for (item in executStack.Elements()) 
				{
					var node:Node = GetNode(item.GetNodeID());
					if (node != null)
					{
						node.Activate(false);
					}
				}
				var result:Map<String, Array<DebugRuntimeGraphInfo>> = new Map<String, Array<DebugRuntimeGraphInfo>>();
				result.set("stacks", debugStack);
				var debugStr:String = Json.stringify(result);
				DebugManager.GetInstance().TriggerBreakPoint(debugStr);
			}
		}
	}
	
	// 继续断点运行
	public function ContinueStack():Void
	{
		this.isBreakpointRunning = false;
		
		var node:Node = GetNode(DebugManager.GetInstance().pauseNode);
		if (node!= null) 
		{
			node.Activate(true);
			node.IsBreakpointing = false;
		}
				
		for (item in executStack.Elements()) 
		{
			if (item.GetNodeID() == DebugManager.GetInstance().pauseNode) 
			{
				continue;
			}
			var node:Node = GetNode(item.GetNodeID());
			if (node != null )
			{
				node.Activate(true);
			}
		}
	}
	
	public function Nodes():Map<Int, Node>
	{
		return this.nodes;
	}
	
	// 增加自定义节点模板
	public function AddCustomNodeTemplete(name:String, templete:CustomNodeInfo):Void
	{
		if (!customNodeTempletes.exists(name)) 
		{
			customNodeTempletes.set(name, templete);
		}
		else{
			customNodeTempletes.remove(name);
			customNodeTempletes.set(name, templete);
		}
	}
	
	// 得到自定义节点模板
	public function GetCustomNodeTemplete(name:String):CustomNodeInfo
	{
		if (customNodeTempletes.exists(name)) 
		{
			return customNodeTempletes.get(name);
		}
		return null;
	}
	
	// 所有的变量
	public function Variables():Map<String, Datum>
	{
		return this.graphVaribles;
	}
	
	// 增加一个变量
	public function AddVarible(varName:String, data:Datum)
	{
		if (!graphVaribles.exists(varName))
		{
			graphVaribles.set(varName, data);
		}
	}
	
	// 移除一个变量
	public function RemoveVarible(varName:String)
	{
		if (!graphVaribles.exists(varName))
		{
			graphVaribles.remove(varName);
		}
	}
	
	// 通过名字得到变量
	public function GetVariableData(varName:String):Datum
	{
		if (graphVaribles.exists(varName))
		{
			var d:Datum = graphVaribles.get(varName);
			return d;
		}
		return null;
	}
	
	// 得到变量里保存的值
	public function GetVaribleValue(varName:String):Any
	{
		if (graphVaribles.exists(varName))
		{
			var d:Datum = graphVaribles.get(varName);
			return d.GetValue();
		}
		return null;
	}
	
	// 设置变量里的值
	public function SetVaribleValue(varName:String, value:Any):Void
	{
		if (graphVaribles.exists(varName))
		{
			var d:Datum = graphVaribles.get(varName);
			return d.SetValue(value);
		}
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
		if (this.isBreakpointRunning || this.GetIsStop()) 
		{
			return;
		}
		if(executStack != null && endPoint != null)
			executStack.Add(endPoint);
	}
	
	// 执行
	public function Execute():Void
	{
		while (executStack.GetCount() > 0)
		{
			var count = executStack.GetCount();
			trace(count);
			//if (executStack.GetCount() > 1000)
			//	// 死循环?
				
			var endpoint:EndPoint = executStack.Get();
			var node:Node = GetNode(endpoint.GetNodeID());
			
			if (node != null)
			{
				AddRuntimeDebugToStack(node.GetNodeID());
				// 节点存在则进入节点相应的插槽
				GraphManager.GetInstance().currGraph = this.graphId;
				GraphManager.GetInstance().currNode = node.GetNodeID();
				node.ClearLogs();
				node.SignalInput(endpoint.GetSlotID());
				node.ClearLogs();
			}
		}
	}
	
	public function AddRuntimeDebugToStack(nodeid:Int):Void
	{
		#if !debug
		var debugInfo:DebugRuntimeGraphInfo = new DebugRuntimeGraphInfo(this.GetGraphName(),this.GetGraphID(), nodeid);
		for (nodeItem in this.Nodes().keys()) 
		{
			var gNode:Node = this.Nodes().get(nodeItem);
			var debugNode:Map<String, Any> = new Map<String, Any>();
			for (slotItemInfo in gNode.GetAllSlotMap().keys()) 
			{
				var slotItem:Slot = gNode.GetAllSlotMap().get(slotItemInfo);
				if (slotItem.slotType == SlotType.DataIn) 
				{
					var nodeslot:Datum = gNode.GetAllDatumMap().get(slotItemInfo);
					if (nodeslot.GetDatumType() == DatumType.USERID) 
					{
						var uid:Int = Std.parseInt(nodeslot.GetValue());
						debugNode.set(slotItem.slotId, uid);
					}
					else
					{
						debugNode.set(slotItem.slotId, nodeslot.GetValue());
					}
				}
			}
			
			var logs:Array<String> = new Array<String>();
			for (log in gNode.logs) 
			{
				logs.push(log);
			}
			
			debugNode.set("logs", logs);
			
			debugInfo.AddNodeInfo(gNode.GetNodeID(), debugNode);
		}
		
		for (varitem in this.Variables().keys())
		{
			debugInfo.AddGraphVariable(varitem, this.Variables().get(varitem));
		}
		
		this.AddDebugStack(debugInfo, false);
		#end
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