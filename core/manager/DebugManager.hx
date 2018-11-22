package core.manager;
import core.graph.Graph;
import core.node.Node;
import reflectclass.ReflectHelper;

/**
 * ...
 * @author ...
 */
class DebugManager 
{
	public var pauseGraph:Int;
	
	public var pauseNode:Int;
	
	private var breakPoints:Map<String, Array<String>>;
	
	public var isDebugMode:Bool;
	
	private var bpcbClassName:String;
	
	private var bpcbMethodName:String;
	
	private static var instance:DebugManager;
	
	public function new() 
	{
		pauseGraph = -1;
		pauseNode = -1;
		breakPoints = new Map<String, Array<String>>();
		isDebugMode = false;
	}
	
	public static function GetInstance():DebugManager
	{
		if (instance == null)
			instance = new DebugManager();
			
		return instance;
	}
	
	public function IsDebugMode():Bool
	{
		return this.isDebugMode;
	}
	
	public function SetBreakpointCB(className:String, methodName:String):Void
	{
		this.bpcbClassName = className;
		this.bpcbMethodName = methodName;
	}
	
	public function TriggerBreakPoint(debugStr:String):Void
	{
		if (this.bpcbClassName != "" && this.bpcbMethodName != "") 
		{
			var params:Array<Any> = new Array<Any>();
			params.push(debugStr);
			ReflectHelper.GetInstance().CallSingleMethod(this.bpcbClassName, this.bpcbMethodName, params);
		}
	}
	
	public function IsNodeBreakpointing(gId:Int, nId:Int):Bool
	{
		var graph:Graph = GraphManager.GetInstance().GetGraph(gId);
		if (graph != null) 
		{
			var node:Node = graph.GetNode(nId);
			if (node != null) 
			{
				return node.IsBreakpointing;
			}
			return false;
		}
		return false;
	}
	
	// 节点是否被断点
	public function isNodeBreakpoint(graphName:String, nId:Int):Bool
	{
		if (breakPoints.exists(graphName)) 
		{
			var nids:Array<String> = breakPoints.get(graphName);
			for (nidItem in nids) 
			{
				if (nidItem == Std.string(nId)) 
				{
					return true;
				}
			}
		}
		return false;
	}
	
	public function pause(graph:Int, node:Int):Void
	{
		this.pauseGraph = graph;
		this.pauseNode = node;
	}
	
	public function resume():Void
	{
		var graph:Graph = GraphManager.GetInstance().GetGraph(this.pauseGraph);
		var node:Node = graph.GetNode(this.pauseNode);
		if (node != null) 
		{
			node.SignalInput("In");
		}
		this.pauseGraph = -1;
		this.pauseNode = -1;
	}
	
	// 断点操作
	public function BreakpointHandler(debugOperation:String, debugInfos:Map<String, Array<String>>):Void
	{
		if (debugOperation == "add")  // 增加一个或者断点
		{
			for (graphName in debugInfos.keys()) 
			{
				if (breakPoints.exists(graphName)) 
				{
					var bps:Array<String> = breakPoints.get(graphName);
					for (debugNode in debugInfos.get(graphName)) 
					{
						bps.push(debugNode);
					}
				}
				else
				{
					breakPoints.set(graphName, debugInfos.get(graphName)); 
				}
			}
		}
		else if (debugOperation == "delete") // 删除一个或多个断点
		{
			for (graphName in debugInfos.keys()) 
			{
				if (breakPoints.exists(graphName)) 
				{
					var bps:Array<String> = breakPoints.get(graphName); 
					for (debugNode in debugInfos.get(graphName)) 
					{
						if (bps.indexOf(debugNode) != -1) 
						{
							bps.remove(debugNode);
						}
					}
					if (bps.length == 0) 
					{
						breakPoints.remove(graphName);
					}
				}
			}
		}
		else if (debugOperation == "exit")
		{
			for (graphName in breakPoints.keys()) 
			{
				var bps:Array<String> = breakPoints.get(graphName); 
				for (debugNode in bps) 
				{
					bps.remove(debugNode);
				}
				breakPoints.remove(graphName);
			}
			this.isDebugMode = false;
			
			if (pauseGraph != -1 && pauseNode != -1) 
			{
				var graph:Graph = GraphManager.GetInstance().GetGraph(pauseGraph);
				if (graph != null) 
				{
					graph.ContinueStack();
				}
				pauseGraph = -1;
				pauseNode = -1;
			}
		}
		else if (debugOperation == "next")
		{
			
		}
		else if (debugOperation == "continue")
		{
			if (pauseGraph != -1 && pauseNode != -1) 
			{
				var graph:Graph = GraphManager.GetInstance().GetGraph(pauseGraph);
				if (graph != null) 
				{
					graph.ContinueStack();
				}
				pauseGraph = -1;
				pauseNode = -1;
			}
		}
		else if (debugOperation == "entry")
		{
			this.isDebugMode = true;
			for (graphName in debugInfos.keys()) 
			{
				if (breakPoints.exists(graphName)) 
				{
					var bps:Array<String> = breakPoints.get(graphName);
					for (debugNode in debugInfos.get(graphName)) 
					{
						bps.push(debugNode);
					}
				}
				else
				{
					breakPoints.set(graphName, debugInfos.get(graphName)); 
				}
			}
		}
	}
	
}