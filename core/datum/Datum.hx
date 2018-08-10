package core.datum;
import core.serialization.ISerializable;
import haxe.io.Bytes;


/**
 * ...
 * @author MibuWolf
 */ 

 
// 数据类型
enum DatumType 
{
	INVALID;		// 无效的
	BOOL;			
	INT;
	FLOAT;
	STRING;
}

// 插槽数据
 class Datum implements ISerializable
 {
	public static var  INVALID:String = "";
	private var type(default, default):DatumType;		// 数据类型
	private var name(default, default):String;		// 数据名称
	private var value(default, default):Any;		// 数据值
	
	public function new(){}
	 
	public function Initialize(dType:DatumType, dValue:Any,dName:String="")
	{
		this.type = dType;
		this.name = dName;
		this.value = dValue;
	}
	
	public function Is(other:Datum):Bool
	{
		if (this.type == other.type)
			return true;
		
		return false;
	}
	
	
	// 设置数据
	public function SetData(data:Datum):Bool
	{
		if (data == null)
			return false;
			
		if (!this.Is(data))
			return false;
		
		this.value = data.value;
		
		return true;
		
	}
	
	
	// 获取类型 
	public function GetType():DatumType
	{
		return type;
	}
	
	
	// 获取数据
	public function GetValue():Any
	{
		return value;
	}
	
	
	// 获取数据名称
	public function GetName():String
	{
		return name;
	}
	
	
	// 复制数据
	public function Clone():Datum
	{
		var data:Datum = new Datum();
		data.Initialize(type, value, name);
		
		return data;
	}
	
	
	// 设置数据
	public function SetValue(valueAny:Any):Void
	{
			this.value = valueAny;
	}
	
	
	// 序列化为bytes字节数组
	public function SeriralizeToBytes(bytes:Bytes):Void
	{
		
		
	}
	
	// 从bytes字节数组反序列化
	public function DeserializeFromBytes(bytes:Bytes):Void
	{
		
		
	}
	
	
	public static function INITIALIZE_BOOL(vName:String = "", defaultValue:Bool = false)
	{

		var data:Datum = new Datum();
		data.Initialize(DatumType.BOOL, defaultValue, vName);
        
		return data;
	}
	
	public static function INITIALIZE_INT(vName:String = "", defaultValue:Int = 0)
	{

		var data:Datum = new Datum();
		data.Initialize(DatumType.INT, defaultValue, vName);
        
		return data;
	}
	
	public static function INITIALIZE_FLOAT(vName:String = "", defaultValue:Float = 0.0)
	{

		var data:Datum = new Datum();
		data.Initialize(DatumType.FLOAT, defaultValue, vName);
        
		return data;
	}
	
	public static function INITIALIZE_STRING(vName:String = "", defaultValue:String = "")
	{

		var data:Datum = new Datum();
		data.Initialize(DatumType.STRING, defaultValue, vName);
        
		return data;
	}
	
	
	public static function INITIALIZE_UNDEFAULT(vType:DatumType, defaultValue:String = "")
	{

		var data:Datum = new Datum();
		data.Initialize(vType, null, defaultValue);
        
		return data;
	}
	
 }

 

 
