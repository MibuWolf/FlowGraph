package core.serialization.laybox;
import reflectclass.MethodInfo;
import haxe.Json;
import core.datum.Datum;
import reflectclass.TriggerInfo;
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
			nodeData.output = new Array<Map<String,Map<String,Any>>>();
			
			for (param in params)
			{
				var data:Map<String,Map<String,Any>> = LayBoxParamData.GetInstance().GetMapData(param);
				
				if(data != null)
					nodeData.output.push(data);
			}
		}
		
		nodeData.next = new Array<String>();
		
		nodeData.next.push("Out");
		
		return Json.stringify(nodeData);
	}
	
	
	// 触发器(事件)反序列化
	public static function TriggerInfoFormJson(info:TriggerInfo):String
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
			nodeData.output = new Array<Map<String,Map<String,Any>>>();
			
			for (param in params)
			{
				var data:Map<String,Map<String,Any>> = LayBoxParamData.GetInstance().GetMapData(param);
				
				if(data != null)
					nodeData.output.push(data);
			}
		}
		
		nodeData.next = new Array<String>();
		
		nodeData.next.push("Out");
		
		return Json.stringify(nodeData);
	}
	
}