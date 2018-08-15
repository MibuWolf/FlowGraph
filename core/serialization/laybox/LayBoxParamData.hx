package core.serialization.laybox;
import core.datum.Datum;

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
	private static function GetTypeName(type:DatumType):String
	{
		if(type == DatumType.BOOL)
			return "bool";
		
		if(type == DatumType.INT)
			return "int";
				
		if(type == DatumType.FLOAT)
			return "float";
				
		if(type == DatumType.STRING)
			return "string";
		
		return "Invalid";
	}
	
	
	// 获取类型名称
	private static function GetTypeByName(type:String):DatumType
	{
		if(type == "bool")
			return DatumType.BOOL;
		
		if(type == "int")
			return DatumType.INT;
				
		if(type == "float")
			return DatumType.FLOAT;
				
		if(type == "string")
			return DatumType.STRING;
		
		return DatumType.INVALID;
	}
	
	
	public function GetMapData(datum:Datum):Map<String,Map<String,Any>>
	{
		if (datum == null)
			return null;
			
		var data:Map<String,Map<String,Any>> = new Map<String, Map<String, Any>>();
		var dataValue:Map<String,Any> = new Map<String, Any>();
		
		if (datum.GetValue() == null)
			dataValue.set(GetTypeName(datum.GetType()), "lock");
		else
			dataValue.set(GetTypeName(datum.GetType()), datum.GetValue());
			
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