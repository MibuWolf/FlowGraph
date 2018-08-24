package test;
import reflectclass.ReflectHelper;
import core.datum.Datum;
/**
 * ...
 * @author MibuWolf
 */
class MathUtils 
{
	private static var instance:MathUtils;
	
	public function new() 
	{
		
	}
	
	
	public static function GetInstance():MathUtils
	{
		if (instance == null)
			instance = new MathUtils();
			
		return instance;
	}
	
	
	public function Add(v:Int):Int
	{
		var result:Int = v + 1;
		return result;
	}
	
	
	public function Double(v:Int):Int
	{
		var result:Int = v * 2;
		return result;
	}
	
	public function DAdd(v:Int):Int
	{
		var result:Int = v - 1;
		return result;
	}
	
	
	public  function ReflectToGraph():Void
	{
		ReflectHelper.GetInstance().RegisterClass("MathUtils")
			.RegisterMethod("Add", [Datum.INITIALIZE_INT("vv")], Datum.INITIALIZE_UNDEFAULT(DatumType.INT));
		
		ReflectHelper.GetInstance().RegisterClass("MathUtils")
			.RegisterMethod("Double", [Datum.INITIALIZE_INT("vv")], Datum.INITIALIZE_UNDEFAULT(DatumType.INT));
			
		ReflectHelper.GetInstance().RegisterClass("MathUtils")
			.RegisterMethod("DAdd", [Datum.INITIALIZE_INT("vv")], Datum.INITIALIZE_UNDEFAULT(DatumType.INT));
			
		ReflectHelper.GetInstance().InitializationSingleClass("MathUtils", this);
	}
}