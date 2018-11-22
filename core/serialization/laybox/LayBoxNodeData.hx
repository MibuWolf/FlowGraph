package core.serialization.laybox;
import core.node.ExecuteNode;
import core.node.logic.LogicBaseNode;
import core.node.varible.VariableGetNode;
import core.node.varible.VariableSetNode;
import reflectclass.MethodInfo;
import haxe.Json;
import core.node.logic.AndNode;
import core.node.logic.IfNode;
import core.node.logic.NotNode;
import core.node.logic.OrNode;
import core.node.logic.FloatCompareNode;
import core.node.logic.StringCompareNode;
import core.datum.Datum;
import reflectclass.ReflectHelper;
import reflectclass.TriggerInfo;
import core.slot.Slot;
import reflectclass.ClassInfo;
import core.node.Node.NodeType;
import core.datum.DefaultVar;
import core.serialization.laybox.LayBoxParamData;
/**
 * 为laybox编辑器构造节点数据结构
 * @author MibuWolf
 */
class LayBoxNodeData 
{
	// 节点数据类型
	public var nodeTips:String;
	
	// 节点类型
	public var type:String;
	
	// 节点名
	public var name:String;
	
	// 类名
	public var category:String;
	
	// 输入参数
	public var input:Array<Map<String,Map<String,Any>>>;
	
	// 输出参数
	public var output:Array<Map<String,Map<String,Any>>>;
	
	// 下一个逻辑节点
	public var next:Array<String>;
	
	public var before:Array<String>;
	
	public function new() 
	{
		
	}
	
	
	// 成员方法序列化
	public static function MethodInfoToJson(info:MethodInfo):String
	{
		if (info == null)
			return Json.stringify({});
		
		var nodeData:LayBoxNodeData = new LayBoxNodeData();
		nodeData.type = NodeType.ctrl.getName();
		nodeData.nodeTips = info.GetTips();
		nodeData.category = info.GetClassName();
		nodeData.name = info.GetMethodName();
		
		var params:Array<Datum> = info.GetAllParam();
	
		if (params != null && params.length > 0)
		{
			nodeData.input = new Array<Map<String,Map<String,Any>>>();
			
			for (param in params)
			{
				var data:Map<String,Map<String,Any>> = LayBoxParamData.GetInstance().GetMapData(param);
				
				if(data != null)
					nodeData.input.push(data);
			}
		}
		
		var result:Datum = info.GetResult();
		
		if (result != null)
		{
			nodeData.output = new Array<Map<String,Map<String,Any>>>();
			
			var resultData:Map<String,Map<String,Any>> = LayBoxParamData.GetInstance().GetMapData(result);
				
			if(resultData != null)
				nodeData.output.push(resultData);
		}
		
		nodeData.next = new Array<String>();
		
		nodeData.next.push("Out");
		
		return Json.stringify(nodeData);
	}
	
	// 成员方法序列化
	public static function MethodInfoToNodeData(info:MethodInfo, type:String):LayBoxNodeData
	{
		if (info == null)
			return null;
		
		var nodeData:LayBoxNodeData = new LayBoxNodeData();
		//nodeData.type = NodeType.ctrl.getName();
		nodeData.type = type;
		nodeData.nodeTips = info.GetTips();
		nodeData.category = info.GetClassName();
		nodeData.name = info.GetMethodName();
		
		var params:Array<Datum> = info.GetAllParam();
	
		if (params != null && params.length > 0)
		{
			nodeData.input = new Array<Map<String,Map<String,Any>>>();
			
			for (param in params)
			{
				var data:Map<String,Map<String,Any>> = LayBoxParamData.GetInstance().GetMapData(param);
				
				if(data != null)
					nodeData.input.push(data);
			}
		}
		
		var result:Datum = info.GetResult();
		
		if (result != null)
		{
			nodeData.output = new Array<Map<String,Map<String,Any>>>();
			
			var resultData:Map<String,Map<String,Any>> = LayBoxParamData.GetInstance().GetMapData(result);
				
			if(resultData != null)
				nodeData.output.push(resultData);
		}
		
		nodeData.next = new Array<String>();
		
		nodeData.next.push("Out");
		
		nodeData.before = new Array<String>();
		nodeData.before.push("In");
		
		return nodeData;
	}
	
	
	// 成员方法反序列化
	public static function MethodInfoFromJson(strJson:String):MethodInfo
	{
		var nodeData:LayBoxNodeData = Json.parse(strJson);
		
		if (nodeData == null)
			return null;

		var className:String = nodeData.category;
		var methodName:String = nodeData.name;
		
		var info:MethodInfo = new MethodInfo(className, methodName);
		
		if (nodeData.input != null)
		{
			var arrayFields:Array<String> = Reflect.fields(nodeData.input);

			var arrayDynimic:Array<Map<String,Map<String,Any>>> = Reflect.field(nodeData.input, arrayFields[0]);
			var index:Int = 0;
			var count:Int = Reflect.field(nodeData.input, arrayFields[1]);
			
			while (index < count) 
			{
				var param:Map<String,Map<String,Any>> = arrayDynimic[index++];
				if (param != null)
					info.AddParam(LayBoxParamData.GetInstance().GetDatum(param));
			}
		}
		
		if(nodeData.output != null)
		{
			for (result in nodeData.output) 
			{
				info.SetResult(LayBoxParamData.GetInstance().GetDatum(result));
			}
		}
		
		return info;
	}
	
	
	
	// 触发器(事件)序列化
	public static function TriggerInfoToJson(info:TriggerInfo):String
	{
		if (info == null)
			return Json.stringify({});
			
		var nodeData:LayBoxNodeData = new LayBoxNodeData();
		nodeData.type = NodeType.event.getName();
		nodeData.nodeTips = info.GetTips();
		nodeData.category = info.GetClassName();
		nodeData.name = info.GetMethodName();
		
		var params:Array<Datum> = info.GetAllParam();
	
		if (params != null && params.length > 0)
		{
			nodeData.input = new Array<Map<String,Map<String,Any>>>();
			nodeData.output = new Array<Map<String,Map<String,Any>>>();
			
			for (param in params)
			{
				var data:Map<String,Map<String,Any>> = LayBoxParamData.GetInstance().GetMapData(param);
				
				if(data != null)
				{
					if(param.GetValue() == null)
						nodeData.output.push(data);
					else
						nodeData.input.push(data);
				}
			}
		}
		
		if (nodeData.input.length == 0)
			nodeData.input = null;
			
		if (nodeData.output.length == 0)
			nodeData.output = null;
		
		nodeData.next = new Array<String>();
		
		nodeData.next.push("Out");
		
		return Json.stringify(nodeData);
	}
	
	public static function TriggerInfoToNodeData(info:TriggerInfo, type:String):LayBoxNodeData
	{
		if (info == null)
			return null;
			
		var nodeData:LayBoxNodeData = new LayBoxNodeData();
		//nodeData.type = NodeType.event.getName();
		nodeData.type = type;
		nodeData.nodeTips = info.GetTips();
		nodeData.category = info.GetClassName();
		nodeData.name = info.GetMethodName();
		
		var params:Array<Datum> = info.GetAllParam();
	
		if (params != null && params.length > 0)
		{
			nodeData.input = new Array<Map<String,Map<String,Any>>>();
			nodeData.output = new Array<Map<String,Map<String,Any>>>();
			
			for (param in params)
			{
				var data:Map<String,Map<String,Any>> = LayBoxParamData.GetInstance().GetMapData(param);
				
				if(data != null)
				{
					if(param.GetValue() == null)
						nodeData.output.push(data);
					else
						nodeData.input.push(data);
				}
			}
		
			
					
			if (nodeData.input.length == 0)
				nodeData.input = null;
			
			if (nodeData.output.length == 0)
				nodeData.output = null;
		}
		
		nodeData.next = new Array<String>();
		
		nodeData.next.push("Out");
		
		return nodeData;
	}
	
	// 触发器(事件)反序列化
	public static function TriggerInfoFormJson(strJson:String):TriggerInfo
	{
		if (strJson == null)
			return null;
			
		var nodeData:LayBoxNodeData = Json.parse(strJson);
		
		var className:String = nodeData.category;
		var methodName:String = nodeData.name;
		
		var info:TriggerInfo = new TriggerInfo(className, methodName);
		
		if (nodeData.input != null)
		{
			var arrayFields:Array<String> = Reflect.fields(nodeData.input);

			var arrayDynimic:Array<Map<String,Map<String,Any>>> = Reflect.field(nodeData.input, arrayFields[0]);
			var index:Int = 0;
			var count:Int = Reflect.field(nodeData.input, arrayFields[1]);
			
			while (index < count) 
			{
				var param:Map<String,Map<String,Any>> = arrayDynimic[index++];
				if (param != null)
					info.AddParam(LayBoxParamData.GetInstance().GetDatum(param));
			}
		}
		
		if(nodeData.output != null)
		{
			for (result in nodeData.output) 
			{
				info.AddParam(LayBoxParamData.GetInstance().GetDatum(result));
			}
		}
		
		return info;
	}
	
	// 成员方法序列化
	public static function LogicNodeToNodeData(node:LogicBaseNode):LayBoxNodeData
	{
		if (node == null)
			return null;
		
		var nodeData:LayBoxNodeData = new LayBoxNodeData(); 
		nodeData.type = NodeType.logic.getName();
		nodeData.nodeTips = node.GetGroupName()+"." + node.GetName();
		nodeData.category = node.GetGroupName();
		nodeData.name = node.GetName();
		
		var params:Map<String, Datum> = node.GetAllDatumMap();
	
		if (params != null)
		{
			nodeData.input = new Array<Map<String,Map<String,Any>>>();
			
			for (param in params)
			{
				var data:Map<String,Map<String,Any>> = LayBoxParamData.GetInstance().GetMapData(param);
				
				if(data != null)
					nodeData.input.push(data);
			}
		}
		
		var result:Map<String, Slot> = node.GetAllSlotMap();
		
		if (result != null)
		{
			/*nodeData.output = new Array<Map<String,Map<String,Any>>>();
			
			var resultData:Map<String,Map<String,Any>> = LayBoxParamData.GetInstance().GetMapData(result);
				
			if(resultData != null)
				nodeData.output.push(resultData);*/
			nodeData.next = new Array<String>();
			for (res in result) 
			{
				if (res.slotType == SlotType.ExecutionOut) 
				{
					nodeData.next.push(res.slotId);
				}
			}
		}
		
		nodeData.before = new Array<String>();
		nodeData.before.push("In");
		
		return nodeData;
	}
	
	// 成员方法序列化
	public static function VariableNodeToNodeData(node:ExecuteNode, isSet:Bool):LayBoxNodeData
	{
		if (node == null)
			return null;
		
		var nodeData:LayBoxNodeData = new LayBoxNodeData(); 
		nodeData.type = NodeType.variable.getName();
		nodeData.nodeTips = node.GetGroupName()+"." + node.GetName();
		nodeData.category = node.GetGroupName();
		nodeData.name = node.GetName();
		//var params:Map<String, Datum> = node.GetAllDatumMap(); 
		
		nodeData.next = new Array<String>();
		nodeData.next.push("Out");
		
		nodeData.before = new Array<String>();
		nodeData.before.push("In");
		
		
				
		if (isSet)
		{
			nodeData.input = new Array<Map<String,Map<String,Any>>>();
			var inputData:Map<String,Map<String,Any>> = new Map<String, Map<String, Any>>();
			var inputlock:Map<String,Any> = new Map<String, Any>();
			inputlock.set("lock", "lock");
			inputData.set("lock", inputlock);
			if(inputData != null)
				nodeData.input.push(inputData);
		}
		else{
			nodeData.output = new Array<Map<String,Map<String,Any>>>();
			var outputData:Map<String,Map<String,Any>> = new Map<String, Map<String, Any>>();
			var outputlock:Map<String,Any> = new Map<String, Any>();
			outputlock.set("lock", "lock");
			outputData.set("lock", outputlock);
			if(outputData != null)
				nodeData.output.push(outputData);
		}
		
		return nodeData;
	}


	// 获取所有节点描述信息
	public static function GetAllNodeJson():String
	{
		// 注册节点给流图编辑器
		var allLayBoxNodeDatas = new Array<LayBoxNodeData>();
		InitCommonNodes(allLayBoxNodeDatas);
		InitReflectNodes(allLayBoxNodeDatas);
		var data:Map<String, Any> = new Map<String, Any>();
		data.set("nodes", allLayBoxNodeDatas);
		
		// 注册默认变量给流图编辑器
		var defaultVars:Array<DefaultVar> = new Array<DefaultVar>();
		var dVar1:DefaultVar = new DefaultVar("attackId", LayBoxParamData.GetTypeName(DatumType.USERID), 0);
		var dVar2:DefaultVar = new DefaultVar("beAttackId", LayBoxParamData.GetTypeName(DatumType.USERID), 0);
		var dVar3:DefaultVar = new DefaultVar("attackMoveToPos", LayBoxParamData.GetTypeName(DatumType.VECTOR3), [0,0,0]);
		var dVar4:DefaultVar = new DefaultVar("beAttackMoveToPos", LayBoxParamData.GetTypeName(DatumType.VECTOR3), [0,0,0]);
		var dVar5:DefaultVar = new DefaultVar("conditionName", LayBoxParamData.GetTypeName(DatumType.STRING), "");
		var dVar6:DefaultVar = new DefaultVar("skillIsOver", LayBoxParamData.GetTypeName(DatumType.BOOL), false);
		var dVar7:DefaultVar = new DefaultVar("isCanMove", LayBoxParamData.GetTypeName(DatumType.BOOL), false);
		var dVar8:DefaultVar = new DefaultVar("skillId", LayBoxParamData.GetTypeName(DatumType.INT), 0);
		var dVar9:DefaultVar = new DefaultVar("graphId", LayBoxParamData.GetTypeName(DatumType.INT), 0);
		defaultVars.push(dVar1);
		defaultVars.push(dVar2);
		defaultVars.push(dVar3);
		defaultVars.push(dVar4);
		defaultVars.push(dVar5);
		defaultVars.push(dVar6);
		defaultVars.push(dVar7);
		defaultVars.push(dVar8);
		defaultVars.push(dVar9);
		data.set("vars", defaultVars);
		
		return Json.stringify(data);
	}
	
	
	// 获取通用节点描述信息
	private static function InitCommonNodes(allLayBoxNodeDatas:Array<LayBoxNodeData>):Void
	{
		if (allLayBoxNodeDatas == null)
			return;
			
		allLayBoxNodeDatas.push(LayBoxNodeData.LogicNodeToNodeData(new AndNode(null)));
		allLayBoxNodeDatas.push(LayBoxNodeData.LogicNodeToNodeData(new IfNode(null)));
		allLayBoxNodeDatas.push(LayBoxNodeData.LogicNodeToNodeData(new NotNode(null)));
		allLayBoxNodeDatas.push(LayBoxNodeData.LogicNodeToNodeData(new OrNode(null)));
		allLayBoxNodeDatas.push(LayBoxNodeData.LogicNodeToNodeData(new FloatCompareNode(null)));
		allLayBoxNodeDatas.push(LayBoxNodeData.LogicNodeToNodeData(new StringCompareNode(null)));
		
		var varD:Datum = new Datum();
		varD.Initialize(DatumType.STRING, "", "var1");
		var getNode:VariableGetNode = new VariableGetNode(null);
		var setNode:VariableSetNode = new VariableSetNode(null);
		setNode.Initialization(varD);
		getNode.Initialization(varD);
		allLayBoxNodeDatas.push(LayBoxNodeData.VariableNodeToNodeData(getNode, false));
		allLayBoxNodeDatas.push(LayBoxNodeData.VariableNodeToNodeData(setNode, true));
		
		var graphStart:TriggerInfo = new TriggerInfo("Graph", "GraphStartNode");
		allLayBoxNodeDatas.push(TriggerInfoToNodeData(graphStart, NodeType.start.getName()));
		
		var endGraph:TriggerInfo = new TriggerInfo("Graph", "EndGraph");
		allLayBoxNodeDatas.push(TriggerInfoToNodeData(endGraph, NodeType.end.getName()));
	}
	
	
	// 获取所有注册函数节点描述信息
	private static function InitReflectNodes(allLayBoxNodeDatas:Array<LayBoxNodeData>):Void
	{
		var allClassInfos:Map<String,ClassInfo> = ReflectHelper.GetInstance().GetAllClassInfo();
		if (allLayBoxNodeDatas == null || allClassInfos == null)
			return;
	
		for (classItem in allClassInfos)
		{
			var allMethods:Map<String, MethodInfo> = classItem.GetAllMethods();
			if (allMethods != null) 
			{
				for (methodItem in allMethods) 
				{
					var data:LayBoxNodeData = LayBoxNodeData.MethodInfoToNodeData(methodItem, NodeType.ctrl.getName());
					allLayBoxNodeDatas.push(data);
				}
			}
			
			var allTriggers:Map<String, TriggerInfo> = classItem.GetAllTriggers();
			if (allTriggers != null) 
			{
				for (triggerItem in allTriggers) 
				{
					var data:LayBoxNodeData = LayBoxNodeData.TriggerInfoToNodeData(triggerItem, NodeType.event.getName());
					allLayBoxNodeDatas.push(data);
				}
			}
		}
	}
	
}