package test;
import reflectclass.ReflectHelper;
import core.datum.Datum;
import core.manager.GraphTriggerManager;
/**
 * ...
 * @author MibuWolf
 */
class StudentMgr 
{

	private var allStudents:Map<Int,Student>;
	
	private var curIndex:Int = 0;
	
	private static var instance:StudentMgr;
	
	public function new() 
	{
		allStudents = new Map<Int, Student>();
	}
	
	
	public static function GetInstance():StudentMgr
	{
		if (instance == null)
			instance = new StudentMgr();
			
		return instance;
	}
	
	
	
	public function AddStudent(name:String, age:Int):Int
	{
		var std:Student = new Student(name, age);
		var id:Int = curIndex ++;
		
		allStudents.set(id, std);
		
		return id;
	}
	
	public function GetStudent1Age():Int
	{
		return 10;
	}
	
	public function GetStudent2Age():Int
	{
		return 11;
	}
	
	public function GetStudent3Age():Int
	{
		return 5;
	}
	
	public function Compare(id1:Int, id2:Int):Bool
	{
		if (!allStudents.exists(id1) || !allStudents.exists(id2))
			return false;
			
		else
		{
			var std1:Student = allStudents.get(id1);
			var std2:Student = allStudents.get(id2);
			trace(std1.GetAge(), std2.GetAge());
			return std1.GetAge() == std2.GetAge();
		}
	}
	
	
	public function GetTest():String
	{
		var str:String = "This is Test Log";
		return str;
	}
	
	public function GetVoid():Void
	{
		
	}
	
	
	public function OnTrigger(param:Int):Void
	{
		GraphTriggerManager.GetInstance().OnTrigger(["StudentMgr", "OnTrigger", param]);
	}
	
	
	public  function ReflectToGraph():Void
	{
		ReflectHelper.GetInstance().RegisterClass("StudentMgr")
			.RegisterMethod("AddStudent", [Datum.INITIALIZE_STRING("name"), Datum.INITIALIZE_INT("age")], Datum.INITIALIZE_UNDEFAULT(DatumType.INT));
		ReflectHelper.GetInstance().RegisterClass("StudentMgr")
			.RegisterMethod("GetStudent1Age", null, Datum.INITIALIZE_UNDEFAULT(DatumType.INT));
		ReflectHelper.GetInstance().RegisterClass("StudentMgr")
			.RegisterMethod("GetStudent2Age", null, Datum.INITIALIZE_UNDEFAULT(DatumType.INT));
		ReflectHelper.GetInstance().RegisterClass("StudentMgr")
			.RegisterMethod("GetStudent3Age", null, Datum.INITIALIZE_UNDEFAULT(DatumType.INT));
		ReflectHelper.GetInstance().RegisterClass("StudentMgr")
			.RegisterMethod("GetVoid", null, null);
		ReflectHelper.GetInstance().RegisterClass("StudentMgr")
			.RegisterMethod("Compare", [Datum.INITIALIZE_INT("ida"), Datum.INITIALIZE_INT("idb")], Datum.INITIALIZE_UNDEFAULT(DatumType.BOOL));
		ReflectHelper.GetInstance().RegisterClass("StudentMgr")
			.RegisterMethod("GetTest", [], Datum.INITIALIZE_UNDEFAULT(DatumType.STRING));
			
		ReflectHelper.GetInstance().RegisterClass("StudentMgr")
			.RegisterCallBack("OnTrigger", [Datum.INITIALIZE_INT("param")]);
			
		ReflectHelper.GetInstance().InitializationSingleClass("StudentMgr", this);
	}
	
}