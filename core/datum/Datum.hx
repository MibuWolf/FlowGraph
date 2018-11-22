package core.datum;
import haxe.io.Bytes;
import reflectclass.ReflectHelper;

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
	USERID;
	VECTOR3;
}

// 插槽数据
 class Datum
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
	public function GetDatumType():DatumType
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
		if (type == DatumType.INT)
		{
			var iValue:Int = valueAny;
			this.value = iValue;
			return;
		}
		
		if (type == DatumType.FLOAT)
		{
			var fValue:Float = valueAny;
			this.value = fValue;
			return;
		}
		
		if (type == DatumType.STRING)
		{
			var sValue:String = valueAny;
			this.value = sValue;
			return;
		}
		
		if (type == DatumType.BOOL)
		{
			var bValue:Bool = valueAny;
			this.value = bValue;
			return;
		}
		
		this.value = valueAny;
	}
	
	
	// 释放
	public function Release()
	{
		type = DatumType.INVALID;
		name = "";
		value = null;
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
	
	public static function INITIALIZE_USERID(vName:String = "", defaultValue:Int = 0)
	{
		var data:Datum = new Datum();
		data.Initialize(DatumType.USERID, ReflectHelper.GetInstance().CreateLogicData("userid", defaultValue), vName);
        
		return data;
	}
	
	public static function INITIALIZE_VECTOR3(vName:String = "", defaultValue:Any = null)
	{
		if (defaultValue == null) 
		{
			defaultValue = ReflectHelper.GetInstance().CreateLogicData("vector3",0,0,0);
		}
		var data:Datum = new Datum();
		data.Initialize(DatumType.VECTOR3, defaultValue,vName);
        
		return data;
	}
	
	
	public static function INITIALIZE_UNDEFAULT(vType:DatumType, defaultName:String = "Value")
	{
		if (vType == DatumType.INVALID) 
		{
			return null;
		}
		var data:Datum = new Datum();
		data.Initialize(vType, null, defaultName);
        
		return data;
	}
	
	
	public static function INITIALIZE_DATUM(vType:DatumType, value:Any, defaultName:String = "Value")
	{

		var data:Datum = new Datum();
		data.Initialize(vType, value, defaultName);
        
		return data;
	}
	
 }

 

 
