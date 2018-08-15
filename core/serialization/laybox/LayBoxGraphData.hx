package core.serialization.laybox;
import core.graph.Graph;
import core.node.Node;
import core.node.logic.AndNode;
import core.node.logic.IfNode;
import core.node.logic.LogicBaseNode;
import core.node.logic.NotNode;
import core.node.logic.OrNode;
import core.node.reflect.MethodNode;
import core.node.reflect.TriggerNode;
import haxe.Json;
import reflectclass.ClassInfo;
import reflectclass.MethodInfo;
import reflectclass.ReflectHelper;
import reflectclass.TriggerInfo;
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
	public function GraphFormJson(strJson:String):Graph
	{
		if (strJson == null)
			return null;
		
		var jsonGraphData = Json.parse(strJson);
		
		var graph:Graph = new Graph();
		
		var keyNameList:Array<String> = Reflect.fields(jsonGraphData);
		
		for (keyName in keyNameList)
		{
			if (keyName == "event" || keyName == "name")
				continue;
				
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
		
		if (nodeName == null || className == null)
			return;
		
		var node:Any = null;
		var inputParam:Dynamic = Reflect.getProperty(jsonNodeData, "input");
		var nextParam:Dynamic = Reflect.getProperty(jsonNodeData, "next");
		
		switch(className)
		{
			case "Logic":
				{
					node = CreateLogicNode(graph,nodeID,nodeName);
				}
			default:
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
	
	// 根据节点类型名称创建节点
	private function CreateLogicNode(graph:Graph, nodeID:Int, nodeName:String):LogicBaseNode
	{
		var logicNode:LogicBaseNode = null;
		
		switch(nodeName)
		{
			case "If":
				{
					logicNode = new IfNode(graph);
				}
			case "And":
				{
					logicNode = new AndNode(graph);
				}
			case "Or":
				{
					logicNode = new OrNode(graph);
				}
			case "Not":
				{
					logicNode = new NotNode(graph);
				}
		}
		
		if (logicNode != null)
			logicNode.Initialize(nodeID, NodeType.LOGIC, nodeName, "Logic");
		
		return logicNode;
		
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
			
			if(inputParam != null)
			{
				var valueNameList:Array<String> = Reflect.fields(inputParam);
				
				for (valueName in valueNameList)
				{
					var valueInfo:Dynamic = Reflect.getProperty(inputParam, valueName);
					
					if (Reflect.hasField(valueInfo, "defaultValue"))
					{
						runtimeInfo.SetParam(valueName, Reflect.getProperty(valueInfo,"defaultValue"));
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
				var triggerNode:TriggerNode = new TriggerNode(graph);
				triggerNode.Initialize(nodeID, NodeType.TRIGGER, nodeName, className);
				var triggerInfo:TriggerInfo = ReflectHelper.GetInstance().GetClassInfo(className).GetCallBack(nodeName);
				triggerNode.Initialization(triggerInfo);
			
				return triggerNode;
			}
							
		}
		
		return null;
	}
	
}