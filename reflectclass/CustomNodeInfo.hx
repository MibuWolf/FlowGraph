package reflectclass;
import core.datum.Datum;
import core.serialization.laybox.LayBoxParamData;

/**
 * ...
 * @author ...
 */
class CustomNodeInfo 
{
	//执行输出
	private var next:Array<String>;
	//数据输出
	private var outputList:Array<Datum>;
	//数据输入
	private var inputList:Array<Datum>;
	//模块名
	private var groupName:String;
	//节点名
	private var name:String;
	//节点类型
	private var type:String;
	//节点子类型
	private var subType:String;
	
	public function new(group:String, nodename:String, nodeType:String, sub:String) 
	{
		groupName = group;
		name = nodename;
		type = nodeType;
		subType = sub;
		inputList = new Array<Datum>();
		outputList = new Array<Datum>();
		next = new Array<String>();
	}
	
	public function Initialize(data:Dynamic):Void
	{
		
		if (data == null) 
		{
			return;
		}
		var nextArr:Array<String> = Reflect.getProperty(data, "next");
		if (nextArr != null) 
		{
			for (nItem in nextArr) 
			{
				next.push(nItem);
			}
		}
		var outputArr:Array<Dynamic> = Reflect.getProperty(data, "output");
		if (outputArr != null) 
		{
			for (oItem in outputArr) 
			{
				var odata:Datum = new Datum();
				var oNameList:Array<String> = Reflect.fields(oItem);
				var nodename:String = oNameList[0];
				var typeObj:Dynamic = Reflect.getProperty(oItem,nodename);
				var memList:Array<String> = Reflect.fields(typeObj);
				var memItem:String = memList[0];
				var dv:Dynamic = Reflect.field(typeObj, memItem);
				var type:Any = LayBoxParamData.GetTypeByName(memItem);
				odata.Initialize(type, dv, nodename);
				outputList.push(odata);
			}
		}
		var inputArr:Array<Dynamic> = Reflect.getProperty(data, "input");
		if (inputArr != null) 
		{
			for (iItem in inputArr) 
			{
				var idata:Datum = new Datum();
				var oNameList:Array<String> = Reflect.fields(iItem);
				var nodename:String = oNameList[0];
				var typeObj:Dynamic = Reflect.getProperty(iItem,nodename);
				var memList:Array<String> = Reflect.fields(typeObj);
				var memItem:String = memList[0];
				var dv:Dynamic = Reflect.field(typeObj, memItem);
				var type:Any = LayBoxParamData.GetTypeByName(memItem);
				idata.Initialize(type, dv, nodename);
				inputList.push(idata);
			}
		}
	}
	
	// 根据名称获取默认数据
	public function GetDefaultData(name:String, datumArr:Array<Datum>):Datum
	{
		for (param in datumArr)
		{
			if (param.GetName() == name) 
			{
				return param;
			}
		}
		
		return null;
	}
	
	public function GetGroupName():String
	{
		return groupName;
	}
	
	public function GetNodeName():String
	{
		return name;
	}
	
	public function GetCustomType():String
	{
		return type;
	}
	
	public function GetCustomSubType():String
	{
		return subType;
	}
	
	public function GetInputList():Array<Datum>
	{
		return inputList;
	}
	
	public function GetOutputList():Array<Datum>
	{
		return outputList;
	}
	
	public function GetNext():Array<String>
	{
		return next;
	}
	
}