package reflectclass;
import core.manager.GraphManager;


/**
 * ...
 * @author MibuWolf
 */
class ReflectHelper 
{

	private static var instance:ReflectHelper;
	
	private var classSingles:Map<String,Any>;
	private var logicDatas:Map<String,String>;
	private var allClassInfos:Map<String,ClassInfo>;
	
	private var LogicClassData:Any;
	
	public var CreateLogicData:Dynamic;
	
	public function new() 
	{
		classSingles = new Map<String, Any>();
		allClassInfos = new Map<String, ClassInfo>();
		logicDatas = new Map<String, String>();
	}
	
	static public function GetInstance():ReflectHelper
	{
		if (instance == null)
		{
			instance = new ReflectHelper();
			
			instance.CreateLogicData = Reflect.makeVarArgs(instance.GetLogicData);
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
	
	public function SetLogicClass(classType:Any):Void
	{
		LogicClassData = classType;
	}
	
	
	// 设置单例类对象
	public function InitializationSingleClass(name:String, single:Any):Void
	{
		classSingles.set(name, single);
	}
	
	
	// 设置生产逻辑数据类型
	public function ReflectLogicData(name:String, single:String):Void
	{
		logicDatas.set(name, single);
	}
	
	
	// 获取逻辑数据
	public function GetLogicData(data:Array<Dynamic>):Any
	{
		var name:String = data[0];
		if (!logicDatas.exists(name))
			return null;
			
		var logicDataSingle:String = logicDatas.get(name);
		
		if (logicDataSingle == null)
		{
			return null;
		}
		
		data.remove(name);
		if(data == null)
			return Reflect.callMethod(LogicClassData, Reflect.field(LogicClassData, logicDataSingle), data);
		else
			return Reflect.callMethod(LogicClassData, Reflect.field(LogicClassData, logicDataSingle), data);
			
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
	
	// 获取所有注册的类信息
	public function GetAllClassInfo():Map<String,ClassInfo>
	{
		return this.allClassInfos;
	}
}