package core.serialization.laybox;
import core.datum.Datum;
import reflectclass.ReflectHelper;
/**
 * ...
 * @author MibuWolf
 */
class LayBoxParamData 
{

	private static var instance;
	
	
	public function new() 
	{
		
	}
	
	
	public static function GetInstance():LayBoxParamData
	{
		if (instance == null)
			instance = new LayBoxParamData();
			
		return instance;
	}
	
	
	// 获取类型名称
	public static function GetTypeName(type:DatumType):String
	{
		if(type == DatumType.BOOL)
			return "boolean";
		
		if(type == DatumType.INT)
			return "int";
				
		if(type == DatumType.FLOAT)
			return "number";
				
		if(type == DatumType.STRING)
			return "string";
			
		if (type == DatumType.USERID)
			return "userid";
			
		if (type == DatumType.VECTOR3) 
		{
			return "vector3";
		}
		
		return "Invalid";
	}
	
	
	// 获取类型名称
	public static function GetTypeByName(type:String):DatumType
	{
		if(type == "boolean")
			return DatumType.BOOL;
		
		if(type == "int")
			return DatumType.INT;
				
		if(type == "number")
			return DatumType.FLOAT;
				
		if(type == "string")
			return DatumType.STRING;
			
		if(type == "userid")
			return DatumType.USERID;
			
		if(type == "vector3")
			return DatumType.VECTOR3;
		
		return DatumType.INVALID;
	}
	
	public function StrToAny(data:Any, type:DatumType):Any
	{
		if (data == null)
			return null;
			
		if (type == DatumType.BOOL)
		{
			if (data == "0" || data == "" || data == "false" || data == "False" || data == "FALSE")
				return false;
			return true;
		}
		
		if (type == DatumType.INT)
		{
			if (data == "")
				return 0;
				
			return Std.parseInt(data);
		}
		
		if (type == DatumType.FLOAT)
		{
			if (data == "")
				return 0.0;
				
			return Std.parseFloat(data);
		}
		
		if (type == DatumType.STRING)
		{
			var strData:String = data;
				
			return strData;
		}
		
		if (type == DatumType.VECTOR3)
		{
			var vecValue:Array<Any> = data;
			
			if(vecValue == null)
				return ReflectHelper.GetInstance().CreateLogicData("vector3", 0.0, 0.0, 0.0);
				
			return ReflectHelper.GetInstance().CreateLogicData("vector3",Std.parseFloat(vecValue[0]),Std.parseFloat(vecValue[1]),Std.parseFloat(vecValue[2]));
		}
		
		if (type == DatumType.USERID)
		{
			if(data != "" && data != "0")
				return ReflectHelper.GetInstance().CreateLogicData("userid", Std.parseInt(data));
			else
				return null;
		}
		
		return data;
	}

	
	
	public function GetMapData(datum:Datum):Map<String,Map<String,Any>>
	{
		if (datum == null)
			return null;
			
		var data:Map<String,Map<String,Any>> = new Map<String, Map<String, Any>>();
		var dataValue:Map<String,Any> = new Map<String, Any>();
		
		if (datum.GetValue() == null)
			dataValue.set(GetTypeName(datum.GetDatumType()), "lock");
		else
		{
			if (datum.GetDatumType() == DatumType.VECTOR3) 
			{
				var xV: Any = Reflect.field(datum.GetValue(), "x");
				var yV: Any = Reflect.field(datum.GetValue(), "y");
				var zV: Any = Reflect.field(datum.GetValue(), "z");
				var param:Array<Float> = new Array<Float>();
				param.push(xV);
				param.push(yV);
				param.push(zV);
				dataValue.set(GetTypeName(datum.GetDatumType()), param);
			}
			else
			{
				dataValue.set(GetTypeName(datum.GetDatumType()), datum.GetValue());
			}
			
		}
			
		data.set(datum.GetName(), dataValue);
		
		return data;
	}
	
	
	public function GetDatum(mapData:Map<String,Map<String,Any>>):Datum
	{
		if (mapData == null)
			return null;
		
		var nameList:Array<String> = Reflect.fields(mapData);
		
		var name:String = nameList[0];
		
		var valueData:Map<String,Any> = Reflect.getProperty(mapData,name);
		
		var valueList:Array<String> = Reflect.fields(valueData);
		
		var typeName:String = valueList[0];
		var valueType:DatumType = GetTypeByName(typeName);
		var value = Reflect.getProperty(valueData,typeName);
		
		if (valueType != DatumType.INVALID)
		{
			return Datum.INITIALIZE_DATUM(valueType, value == "lock" ? null : value, name);
		}
			
		return null;
	}
	
}