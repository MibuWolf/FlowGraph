package core.serialization.laybox;
import core.graph.Graph;
import core.node.Node;
import core.node.graphnode.GraphNode;
import core.node.logic.AndNode;
import core.node.logic.IfNode;
import core.node.logic.LogicBaseNode;
import core.node.logic.NotNode;
import core.node.logic.OrNode;
import core.node.logic.StringCompareNode;
import core.node.logic.FloatCompareNode;
import core.node.reflect.MethodNode;
import core.node.reflect.ReflectTriggerNode;
import haxe.Json;
import reflectclass.ClassInfo;
import reflectclass.MethodInfo;
import reflectclass.ReflectHelper;
import reflectclass.TriggerInfo;
import core.node.event.GraphStartNode;
import core.datum.Datum;
/**
 * ...
 * @author MibuWolf
 */
class LayBoxGraphData 
{

	private static var instance:LayBoxGraphData;
	
	public function new() 
	{
		
	}
	
	
	public static function GetInstance():LayBoxGraphData
	{
		if (instance == null)
			instance = new LayBoxGraphData();
		return instance;
	}
	
	
	// 反序列化
	public function GraphFormJson(name:String, graphID:Int,ownerID:Int = -1):Graph
	{
		if (name == null)
			return null;
			
		var strJson:String = ReflectHelper.GetInstance().CreateLogicData("graphdata", name);
		
		if (strJson == null || strJson == "")
			return null;
		
		var jsonGraphData = Json.parse(strJson);
		
		var graph:Graph = new Graph(graphID,ownerID);
		
		var keyNameList:Array<String> = Reflect.fields(jsonGraphData);
		
		
		for (keyName in keyNameList)
		{
			if (keyName == "event" || keyName == "name")
				continue;
				
			if (keyName == "children_flow_graph_call")
				graph.SetStartNodeID(Std.parseInt(Reflect.getProperty(jsonGraphData, keyName)));
				
			if (keyName == "children_flow_graph_return")
				graph.SetEndNodeID(Std.parseInt(Reflect.getProperty(jsonGraphData,keyName)));
				
			InitNodeAndConnection(graph,Std.parseInt(keyName),Reflect.getProperty(jsonGraphData,keyName));
		}
		
		return graph;
	}
	
	
	// 初始化节点及关联信息
	private function InitNodeAndConnection(graph:Graph,nodeID:Int, jsonNodeData:Dynamic):Void
	{
		if (graph == null || jsonNodeData == null)
			return;
		
		var nodeName:String = Reflect.getProperty(jsonNodeData, "name");
		var className:String = Reflect.getProperty(jsonNodeData, "category");
		var subFlowGraph:String = Reflect.getProperty(jsonNodeData, "children_flow_graph_name");
		
		if (nodeName == null || className == null)
			return;
		
		var node:Any = null;
		var inputParam:Dynamic = Reflect.getProperty(jsonNodeData, "input");
		var nextParam:Dynamic = Reflect.getProperty(jsonNodeData, "next");
		
		// 配合服务器消息数据结构
		if (subFlowGraph != null)
		{
			node = CreateFlowGraphNode(graph, nodeID, subFlowGraph);
		}
		else
		{
			if(className == "Logic")
			{
				node = CreateLogicNode(graph,nodeID,nodeName,inputParam);
			}
			else if(className == "Graph" && nodeName == "GraphStartNode")
			{
				node = CreateGraphStartNode(graph,nodeID);
			}
			else
			{
				node = CreateReflectNode(graph,nodeID,className,nodeName,inputParam);
			}
		}
		
		
		if (node == null)
			return;
		
		graph.AddNode(node);
		
		if (inputParam != null)
		{
			// 添加节点插槽之间关系
			var valueNameList:Array<String> = Reflect.fields(inputParam);
				
			for (valueName in valueNameList)
			{
				var valueInfo:Dynamic = Reflect.getProperty(inputParam, valueName);
					
				if (Reflect.hasField(valueInfo, "node_id"))
				{
					graph.AddConnection(Reflect.getProperty(valueInfo, "node_id"), Reflect.getProperty(valueInfo, "pin"), nodeID, valueName);
				}
			}	
		}
		
		if (nextParam == null)
			return;
			
		var outputNameList:Array<String> = Reflect.fields(nextParam);
		
		for (outputName in outputNameList)
		{
			var outputInfo:Array<String> = Reflect.getProperty(nextParam, outputName);
			if (outputInfo == null)
				continue;
			
			for (outputID in outputInfo)
			{
				if (outputID != null)
				{
					graph.AddConnection(nodeID,outputName, Std.parseInt(outputID),"In");
				}
			}
		}
		
	}
	
	// 创建流图节点类型节点
	private function CreateFlowGraphNode(graph:Graph, nodeID:Int, subFlowGrapName:String):Node
	{
		var graphNode:GraphNode = new GraphNode(graph);
		graphNode.Initialize(nodeID, NodeType.GRAPHNODE, subFlowGrapName, "GraphNode");
		
		var subGraph:Graph = GraphFormJson(subFlowGrapName,-1,graph.GetOwnerID());
		graphNode.SetGraph(subGraph);
		
		return graphNode;
	}
	
	// 根据节点类型名称创建节点
	private function CreateLogicNode(graph:Graph, nodeID:Int, nodeName:String, inputParam:Dynamic):LogicBaseNode
	{
		var logicNode:LogicBaseNode = null;
		
		switch(nodeName)
		{
			case "If":
				{
					logicNode = new IfNode(graph);
					
					SetDefaultValue(logicNode.GetSlotData("Branch"), inputParam);
		
				}
			case "And":
				{
					logicNode = new AndNode(graph);
					
					SetDefaultValue(logicNode.GetSlotData("Param1"), inputParam);
					SetDefaultValue(logicNode.GetSlotData("Param2"), inputParam);
				}
			case "Or":
				{
					logicNode = new OrNode(graph);
					
					SetDefaultValue(logicNode.GetSlotData("Param1"), inputParam);
					SetDefaultValue(logicNode.GetSlotData("Param2"), inputParam);
				}
			case "Not":
				{
					logicNode = new NotNode(graph);
					
					SetDefaultValue(logicNode.GetSlotData("Condition"), inputParam);
				}
			case "FloatCompare":
				{
					logicNode = new FloatCompareNode(graph);
					
					SetDefaultValue(logicNode.GetSlotData("Param1"), inputParam);
					SetDefaultValue(logicNode.GetSlotData("Param2"), inputParam);
					SetDefaultValue(logicNode.GetSlotData("Op"), inputParam);
				}
			case "StringCompare":
				{
					logicNode = new StringCompareNode(graph);
					
					SetDefaultValue(logicNode.GetSlotData("Param1"), inputParam);
					SetDefaultValue(logicNode.GetSlotData("Param2"), inputParam);
				}
		}
		
		if (logicNode != null)
			logicNode.Initialize(nodeID, NodeType.LOGIC, nodeName, "Logic");
		
		return logicNode;
		
	}
	
	
	// 设置默认参数
	private function SetDefaultValue(data:Datum, inputParam:Dynamic)
	{
		if (data == null)
			return;
		
		var valueName:String = data.GetName();
		var type:DatumType = data.GetDatumType();
		var valueInfo:Dynamic = Reflect.getProperty(inputParam, valueName);
		
		if (valueInfo == null)
			return;
			
		if (Reflect.hasField(valueInfo, "defaultValue"))
		{
			var value:Any = Reflect.getProperty(valueInfo, "defaultValue");
			var runTimeValue:Any = LayBoxParamData.GetInstance().StrToAny(value,type);
						
			if (type == DatumType.USERID)
			{
				if(runTimeValue != null)
					data.SetValue(runTimeValue);
			}
			else
			{
				data.SetValue(runTimeValue);
			}
		}
	}
	
	
	// 根据类名函数名创建反射节点
	private function CreateReflectNode(graph:Graph, nodeID:Int, className:String, nodeName:String, inputParam:Dynamic):Node
	{
		var classInfo:ClassInfo = ReflectHelper.GetInstance().GetClassInfo(className);
					
		if (classInfo == null)
			return null;
					
		var methodInfo:MethodInfo = classInfo.GetMethod(nodeName);
			
		if (methodInfo != null)
		{
			var methodNode:MethodNode = new MethodNode(graph);
			methodNode.Initialize(nodeID, NodeType.METHOD, nodeName, className);
			var runtimeInfo:MethodInfo = methodInfo.Clone();
			
			runtimeInfo.SetDefaultEntityID(graph.GetOwnerID());
			if(inputParam != null)
			{
				var valueNameList:Array<String> = Reflect.fields(inputParam);
				
				for (valueName in valueNameList)
				{
					var valueInfo:Dynamic = Reflect.getProperty(inputParam, valueName);
					
					if (Reflect.hasField(valueInfo, "defaultValue"))
					{
						var value:Any = Reflect.getProperty(valueInfo, "defaultValue");
						var runTimeValue:Any = LayBoxParamData.GetInstance().StrToAny(value,runtimeInfo.GetParamType(valueName));
						
						if (runtimeInfo.GetParamType(valueName) == DatumType.USERID)
						{
							if(runTimeValue != null)
								runtimeInfo.SetParam(valueName, runTimeValue);
						}
						else
						{
							runtimeInfo.SetParam(valueName, runTimeValue);
						}
					}
				}
			}
			methodNode.Initialization(runtimeInfo);
			
			return methodNode;
		}
		else
		{
			// 创建触发节点
			var triggerInfo:TriggerInfo = classInfo.GetCallBack(nodeName);
							
			if (triggerInfo != null)
			{
				var triggerNode:ReflectTriggerNode = new ReflectTriggerNode(graph);
				triggerNode.Initialize(nodeID, NodeType.TRIGGER, nodeName, className);
				var triggerInfo:TriggerInfo = ReflectHelper.GetInstance().GetClassInfo(className).GetCallBack(nodeName);
				
				triggerInfo.SetDefaultEntityID(graph.GetOwnerID());
				
				if(inputParam != null)
				{
					var valueNameList:Array<String> = Reflect.fields(inputParam);
				
					for (valueName in valueNameList)
					{
						var valueInfo:Dynamic = Reflect.getProperty(inputParam, valueName);
					
						if (Reflect.hasField(valueInfo, "defaultValue"))
						{
							var value:Any = Reflect.getProperty(valueInfo, "defaultValue");
							var runTimeValue:Any = LayBoxParamData.GetInstance().StrToAny(value,triggerInfo.GetParamType(valueName));
						
							if (triggerInfo.GetParamType(valueName) == DatumType.USERID)
							{
								if(runTimeValue != null)
									triggerInfo.SetParam(valueName, runTimeValue);
							}
							else
							{
								triggerInfo.SetParam(valueName, runTimeValue);
							}
						}
					}
				}
			
				triggerNode.Initialization(triggerInfo);
			
				return triggerNode;
			}
							
		}
		
		return null;
	}

	
	// 创建流图开始节点回调
	private function CreateGraphStartNode(graph:Graph, nodeID:Int):Node
	{
		var triggerNode:GraphStartNode = new GraphStartNode(graph);
		triggerNode.Initialize(nodeID, NodeType.TRIGGER, "GraphStartNode", "Graph");
			
		return triggerNode;
	}
}