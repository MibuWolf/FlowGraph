package reflectclass;
import core.graphmanager.GraphManager;
/**
 * ...
 * @author MibuWolf
 */
class ReflectHelper 
{

	private static var instance:ReflectHelper;
	
	private var classSingles:Map<String,Any>;
	private var allClassInfos:Map<String,ClassInfo>;
	
	public var Call:Dynamic;
	
	public function new() 
	{
		classSingles = new Map<String, Any>();
		allClassInfos = new Map<String, ClassInfo>();
	}
	
	static public function GetInstance():ReflectHelper
	{
		if (instance == null)
		{
			instance = new ReflectHelper();
		
			instance.Call = Reflect.makeVarArgs(instance.OnTrigger);
		}
			
		return instance;
	}
	
	
	// 注册类信息
	public function RegisterClass(className:String):ClassInfo
	{
		if (className == null)
			return null;
			
		var classInfo:ClassInfo = GetClassInfo(className);
		
		if (classInfo != null)
			return classInfo; 
		
		classInfo = new ClassInfo(className);
		
		allClassInfos.set(className, classInfo);
		
		return classInfo;
	}
	
	// 根据类名获取类信息
	public function GetClassInfo(className:String):ClassInfo
	{
		if (allClassInfos.exists(className))
			return allClassInfos.get(className);
			
		return null;
	}
	
	
	// 设置单例类对象
	public function InitializationSingleClass(name:String, single:Any):Void
	{
		classSingles.set(name, single);
	}
	
	
	// 调用单例类接口
	public function CallSingleMethod(className:String, methodName:String, params:Array<Any>):Any
	{
		if (!classSingles.exists(className))
		{
			return null;
		}
		
		var classSingle:Any = classSingles.get(className);
		
		if (classSingle == null)
		{
			return null;
		}
		
		return Reflect.callMethod(classSingle, Reflect.field(classSingle, methodName), params);
	}
	
	
	
	// 事件调用
	private function OnTrigger(params:Array<Dynamic>):Void
	{
		if (params == null || params.length < 2)
			return;
		
		var className:String = params[0];
		var eventName:String = params[1];
		
		var classInfo:ClassInfo = GetClassInfo(className);
		
		if (classInfo == null)
			return;
		
		var triggerInfo:TriggerInfo = classInfo.GetCallBack(eventName);
		
		if (triggerInfo == null)
			return;
		
		var index:Int = 2;
		var count:Int = params.length;
		
		while(index < count)
		{
			triggerInfo.SetParamValue(index - 2, params[index]);
			index ++;
		}
		
		GraphManager.GetInstance().OnTrigger(className, eventName, triggerInfo);
	}
	
}