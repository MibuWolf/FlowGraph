package test;
import reflectclass.ReflectHelper;
import core.datum.Datum;
/**
 * ...
 * @author MibuWolf
 */
class TestOutPut 
{

	private static var instance:TestOutPut;
		
	public function new() 
	{
		
	}
	
	
	public static function GetInstance():TestOutPut
	{
		if (instance == null)
			instance = new TestOutPut();
			
		return instance;
	}
	
	public function Output(b:Bool):Void
	{
		if (b)
		{
			trace("testOut  ============= TRUE");
		}
		else
		{
			trace("testOut  ============= FALSE");
		}
	}
	
	
	public function Log(str:String):Void
	{
		trace(str);
	}
	
	public function LogInt(iValue:Int):Void
	{
		trace(iValue);
	}
	
	
	public  function ReflectToGraph():Void
	{
		ReflectHelper.GetInstance().RegisterClass("TestOutPut")
			.RegisterMethod("Output", [Datum.INITIALIZE_BOOL("bValue")]);
			
			
		ReflectHelper.GetInstance().RegisterClass("TestOutPut")
			.RegisterMethod("Log", [Datum.INITIALIZE_STRING("Value")]);	
			
			
		ReflectHelper.GetInstance().RegisterClass("TestOutPut")
			.RegisterMethod("LogInt", [Datum.INITIALIZE_INT("iValue")]);	
			
		ReflectHelper.GetInstance().InitializationSingleClass("TestOutPut", this);
	}
	
}