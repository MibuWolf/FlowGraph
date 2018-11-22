package core.serialization.laybox;
import core.graph.Graph;
import core.node.ExecuteNode;
import core.node.Node;
import core.node.customs.SwitchExecuteNode;
import core.node.graphnode.GraphEndNode;
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
import core.node.varible.VariableGetNode;
import core.node.varible.VariableSetNode;
import haxe.Json;
import reflectclass.ClassInfo;
import reflectclass.MethodInfo;
import reflectclass.ReflectHelper;
import reflectclass.TriggerInfo;
import core.node.event.GraphStartNode;
import core.datum.Datum;
import core.manager.GraphManager;
import core.serialization.laybox.LayBoxParamData;
import reflectclass.CustomNodeInfo;
import core.node.customs.CustomExecuteNode;
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
		
		ParseCustomNodeTemplete(jsonGraphData, graph);
		
		var graphName:String = Reflect.getProperty(jsonGraphData, "name");
		graph.SetGraphName(graphName);
		
		var variables:Dynamic = Reflect.getProperty(jsonGraphData, "variables");
		if (variables != null) 
		{
			var varNaleList:Array<String> = Reflect.fields(variables);
			for (varItem in varNaleList)
			{
				var data:Datum = new Datum();
				var obj1:Dynamic = Reflect.field(variables, varItem);
				
				var memList:Array<String> = Reflect.fields(obj1);
				var memItem:String = memList[0];
				var dv:Dynamic = Reflect.field(obj1, memItem);
				
				var type:Any = LayBoxParamData.GetTypeByName(memItem);
				if (type == DatumType.USERID) 
				{
					data = Datum.INITIALIZE_USERID(varItem, dv);
				}
				else
				{
					data.Initialize(type, dv, varItem);
				}
				
				graph.AddVarible(data.GetName(), data.Clone());
			}
		}
		
		
		for (keyName in keyNameList)
		{
			if (keyName == "event" || keyName == "name" || keyName == "variables")
				continue;
				
			if (keyName == "children_flow_graph_call")
				graph.SetStartNodeID(Std.parseInt(Reflect.getProperty(jsonGraphData, keyName)));
				
			if (keyName == "children_flow_graph_return")
				graph.SetEndNodeID(Std.parseInt(Reflect.getProperty(jsonGraphData,keyName)));
				
			InitNodeAndConnection(graph,Std.parseInt(keyName),Reflect.getProperty(jsonGraphData,keyName));
		}
		
		return graph;
	}
	//解析流图自定义模块数据
	private function ParseCustomNodeTemplete(jsonGraphData:Dynamic, graph:Graph):Void
	{
		
		var customNodeTempletes:Array<Dynamic> = Reflect.getProperty(jsonGraphData, "custom_nodes");
		
		if (customNodeTempletes != null) 
		{
			for (templeteItem in customNodeTempletes)
			{
				var groupName:String = Reflect.getProperty(templeteItem, "category");
				var nodeName:String = Reflect.getProperty(templeteItem, "name");
				var type:String = Reflect.getProperty(templeteItem, "type");
				var subType:String = Reflect.getProperty(templeteItem, "subType");
				var dataInfo: CustomNodeInfo = new CustomNodeInfo(groupName, nodeName, type, subType);
				dataInfo.Initialize(templeteItem);
				var nodeIdentity:String = groupName+"_"+nodeName;
				graph.AddCustomNodeTemplete(nodeIdentity,dataInfo);
			}
		}
	}
	
	
	// 初始化节点及关联信息
	private function InitNodeAndConnection(graph:Graph,nodeID:Int, jsonNodeData:Dynamic):Void
	{
		if (graph == null || jsonNodeData == null)
			return;
		
		var nodeName:String = Reflect.getProperty(jsonNodeData, "name");
		var className:String = Reflect.getProperty(jsonNodeData, "category");
		var subFlowGraph:String = Reflect.getProperty(jsonNodeData, "children_flow_graph_name");
		
		if (nodeName == null && subFlowGraph == null && className == null)
			return;
		
		var node:Any = null;
		var inputParam:Dynamic = Reflect.getProperty(jsonNodeData, "input");
		var nextParam:Dynamic = Reflect.getProperty(jsonNodeData, "next");
		var type:String = Reflect.getProperty(jsonNodeData, "type");
		var varName:String = Reflect.getProperty(jsonNodeData, "varName");
		
		if (type == null) 
		{
			return;
		}
		// 配合服务器消息数据结构
		
		if (type == NodeType.graph.getName())
		{
			node = CreateFlowGraphNode(graph, nodeID, subFlowGraph, inputParam);
		}
		else if (type == NodeType.custom.getName())
		{
			var tempName:String = className +"_" + nodeName;
			var customTemp:CustomNodeInfo = graph.GetCustomNodeTemplete(tempName);
			if (customTemp != null) 
			{
				if (customTemp.GetCustomSubType() == NodeSubType.Bridge.getName()) 
				{
					node = CreateCustomGraphNode(graph, nodeID, className, nodeName); 
				}
				else if (customTemp.GetCustomSubType() == NodeSubType.Switch.getName()) 
				{
					node = CreateSwitchGraphNode(graph, nodeID, className, nodeName); 
				}
			}
		}
		else if (type == NodeType.logic.getName())
		{
			node = CreateLogicNode(graph,nodeID,nodeName,inputParam);
		}
		else if (type == NodeType.variable.getName())
		{
			node = CreateVariableGraphNode(graph,nodeID,nodeName, inputParam, varName);
		}
		else if (type == NodeType.start.getName())
		{
			node = CreateGraphStartNode(graph,nodeID);
		}
		else if (type == NodeType.end.getName()) 
		{
			node = CreateGraphEndNode(graph, nodeID);
		}
		else if (type == NodeType.ctrl.getName() || type == NodeType.event.getName())
		{
			node = CreateReflectNode(graph,nodeID,className,nodeName,inputParam);
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
	
	private function CreateCustomGraphNode(graph:Graph, nodeID:Int,className:String, nodeName:String):Node
	{
		var node:CustomExecuteNode = new CustomExecuteNode(graph);
		var identity:String = className +"_" + nodeName;
		var info:CustomNodeInfo = graph.GetCustomNodeTemplete(identity);
		if (info != null) 
		{
			node.Initialize(nodeID, NodeType.custom, nodeName, className);
			node.Initialization(info);
		}
		
		return node;
	}
	
	private function CreateSwitchGraphNode(graph:Graph, nodeID:Int,className:String, nodeName:String):Node
	{
		var node:SwitchExecuteNode = new SwitchExecuteNode(graph);
		var identity:String = className +"_" + nodeName;
		var info:CustomNodeInfo = graph.GetCustomNodeTemplete(identity);
		if (info != null) 
		{
			node.Initialize(nodeID, NodeType.custom, nodeName, className);
			node.Initialization(info);
		}
		
		return node;
	}
	
	private function CreateVariableGraphNode(graph:Graph, nodeID:Int, nodeName:String,input:Dynamic, varName:String):Node
	{
		var varNode: Dynamic = null;
		if (input != null) 
		{
			varNode = new VariableSetNode(graph);
			var nodeData:Datum = graph.GetVariableData(varName);
			SetDefaultValue(nodeData, input);
			varNode.Initialize(nodeID, NodeType.variable, nodeName, "VariableGraph");
			varNode.Initialization(nodeData.Clone());
		}
		else
		{
			varNode = new VariableGetNode(graph);
			var nodeData:Datum = graph.GetVariableData(varName);
			varNode.Initialize(nodeID, NodeType.variable, nodeName, "VariableGraph");
			varNode.Initialization(nodeData.Clone());
		}
		return varNode;
	}
	
	// 创建流图节点类型节点
	private function CreateFlowGraphNode(graph:Graph, nodeID:Int, subFlowGrapName:String,inputParam:Dynamic):Node
	{
		var graphNode:GraphNode = new GraphNode(graph);
		graphNode.Initialize(nodeID, NodeType.graph, subFlowGrapName, "GraphNode");
		
		var subGraphID:Int = GraphManager.GetInstance().AddGraph(subFlowGrapName, graph.GetOwnerID());
		var subGraph:Graph = GraphManager.GetInstance().GetGraph(subGraphID);
		graphNode.SetGraph(subGraph, inputParam);
		
		return graphNode;
	}
	
	// 根据节点类型名称创建节点
	private function CreateLogicNode(graph:Graph, nodeID:Int, nodeName:String, inputParam:Dynamic):LogicBaseNode
	{
		var logicNode:LogicBaseNode = null;
		
		switch(nodeName)
		{
			case "Branch":
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
			logicNode.Initialize(nodeID, NodeType.logic, nodeName, "Logic");
		
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
			methodNode.Initialize(nodeID, NodeType.ctrl, nodeName, className);
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
			var defaultInfo:TriggerInfo = ReflectHelper.GetInstance().GetClassInfo(className).GetCallBack(nodeName);
			
			if (defaultInfo == null)
				return null;
				
			// 创建触发节点
			var triggerNode:ReflectTriggerNode = new ReflectTriggerNode(graph);
			triggerNode.Initialize(nodeID, NodeType.event, nodeName, className);
				
			var triggerInfo:TriggerInfo = defaultInfo.Clone();
				
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
		
		return null;
	}
	
	
	// 创建流图开始节点回调
	private function CreateGraphEndNode(graph:Graph, nodeID:Int):Node
	{
		var endNode:GraphEndNode = new GraphEndNode(graph);
		endNode.Initialize(nodeID, NodeType.end, "EndGraph", "Graph"); 
			
		return endNode;
	}
	
	// 创建流图开始节点回调
	private function CreateGraphStartNode(graph:Graph, nodeID:Int):Node
	{
		var triggerNode:GraphStartNode = new GraphStartNode(graph);
		triggerNode.Initialize(nodeID, NodeType.start, "GraphStartNode", "Graph");
			
		return triggerNode;
	}
}