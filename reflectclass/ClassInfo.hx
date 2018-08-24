package reflectclass;
import core.datum.Datum;

/**
 * ...
 * @author MibuWolf
 */
class ClassInfo 
{
	// 类名
	private var className:String;

	// 所有成员函数
	private var methods:Map<String,MethodInfo>;
	
	// 回调函数
	private var callbacks:Map<String,TriggerInfo>;
	
	
	public function new(name:String) 
	{
		className = name;
		
		methods = new Map<String, MethodInfo>();
		
		callbacks = new Map<String, TriggerInfo>();
	}
	
	
	// 获取类名
	public function GetClassName():String
	{
		return className;
	}
	
	public function GetAllMethods():Map<String, MethodInfo>
	{
		return methods;
	}
	
	public function GetAllTriggers():Map<String, TriggerInfo>
	{
		return callbacks;
	}
	
	
	// 注册方法
	public function RegisterMethod(methodName:String, params:Array<Datum>, result:Datum = null):Void
	{
		var methodInfo:MethodInfo = GetMethod(methodName);
		
		if (methodInfo == null)
		{
			methodInfo = new MethodInfo(className, methodName);
			methods.set(methodName, methodInfo);
		}
		
		if (params != null)
		{
			for (param in params)
			{
				methodInfo.AddParam(param);
			}
		}
		
		methodInfo.SetResult(result);
		
	}
	
	
	// 注册回调函数
	public function RegisterCallBack(callbackName:String, params:Array<Datum>):Void
	{
		var callBackInfo:TriggerInfo = GetCallBack(callbackName);
		
		if (callBackInfo == null)
		{
			callBackInfo = new TriggerInfo(className, callbackName);
			callbacks.set(callbackName, callBackInfo);
		}
		
		if (params != null)
		{
			for (param in params)
			{
				callBackInfo.AddParam(param);
			}
		}
	}
	
	
	// 添加成员函数
	public function AddMethod(methodName:String, methodInfo:MethodInfo):Bool
	{
		if (methodInfo == null || GetMethod(methodName) != null)
			return false;
			
		methods.set(methodName, methodInfo);
		
		return true;
	}
	
	
	// 获取成员函数
	public function GetMethod(methodName:String):MethodInfo
	{
		if (methods.exists(methodName))
			return methods.get(methodName);
			
		return null;
	}
	
	
	// 添加回调函数
	public function AddCallBack(methodName:String, triggerInfo:TriggerInfo):Bool
	{
		if (triggerInfo == null || GetCallBack(methodName) != null)
			return false;
			
		callbacks.set(methodName, triggerInfo);
		
		return true;
	}
	
	
	// 获取回调函数
	public function GetCallBack(callbackName:String):TriggerInfo
	{
		if (callbacks.exists(callbackName))
			return callbacks.get(callbackName);
			
		return null;
	}
	
}