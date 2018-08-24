package core.serialization.laybox;
import core.node.logic.LogicBaseNode;
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
	
	public function new() 
	{
		
	}
	
	
	// 成员方法序列化
	public static function MethodInfoToJson(info:MethodInfo):String
	{
		if (info == null)
			return Json.stringify({});
		
		var nodeData:LayBoxNodeData = new LayBoxNodeData();
		nodeData.type = "ctrl";
		nodeData.nodeTips = info.GetClassName() + "." + info.GetMethodName();
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
	public static function MethodInfoToNodeData(info:MethodInfo):LayBoxNodeData
	{
		if (info == null)
			return null;
		
		var nodeData:LayBoxNodeData = new LayBoxNodeData();
		nodeData.type = "ctrl";
		nodeData.nodeTips = info.GetClassName() + "." + info.GetMethodName();
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
		nodeData.type = "event";
		nodeData.nodeTips = info.GetClassName() + "." + info.GetMethodName();
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
	
	public static function TriggerInfoToNodeData(info:TriggerInfo):LayBoxNodeData
	{
		if (info == null)
			return null;
			
		var nodeData:LayBoxNodeData = new LayBoxNodeData();
		nodeData.type = "event";
		nodeData.nodeTips = info.GetClassName() + "." + info.GetMethodName();
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
		nodeData.type = node.GetGroupName();
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
		
		return nodeData;
	}


	// 获取所有节点描述信息
	public static function GetAllNodeJson():String
	{
		var allLayBoxNodeDatas = new Array<LayBoxNodeData>();

		InitCommonNodes(allLayBoxNodeDatas);
		
		InitReflectNodes(allLayBoxNodeDatas);
		
		return Json.stringify(allLayBoxNodeDatas);
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
		
		var graphStart:TriggerInfo = new TriggerInfo("Graph", "GraphStartNode");
		allLayBoxNodeDatas.push(TriggerInfoToNodeData(graphStart));
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
					var data:LayBoxNodeData = LayBoxNodeData.MethodInfoToNodeData(methodItem);
					allLayBoxNodeDatas.push(data);
				}
			}
			
			var allTriggers:Map<String, TriggerInfo> = classItem.GetAllTriggers();
			if (allTriggers != null) 
			{
				for (triggerItem in allTriggers) 
				{
					var data:LayBoxNodeData = LayBoxNodeData.TriggerInfoToNodeData(triggerItem);
					allLayBoxNodeDatas.push(data);
				}
			}
		}
	}
	
}