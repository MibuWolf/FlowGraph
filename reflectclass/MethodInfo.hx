package reflectclass;
import core.datum.Datum;
/**
 * ...
 * @author MibuWolf
 */

 

 
class MethodInfo
{

	// 所属类类名
	private var className:String;
	// 方法名
	private var methodName:String;
	// 输入参数类型及默认值
	private var params:Array<Datum>;
	// 返回参数类型
	private var result:Datum;
	
	public function new(cName:String, mName:String) 
	{
		className = cName;
		methodName = mName;
		
		params = new Array<Datum>();
		result = null;
	}
	
	
	// 获取类名
	public function GetClassName():String
	{
		return className;
	}
	
	
	// 获取方法名
	public function GetMethodName():String
	{
		return methodName;
	}
	
	// 添加输入参数
	public function AddParam(param:Datum):Void
	{
		if(param != null)
			params.push(param);
	}
	
	
	// 设置参数值
	public function SetParam(name:String, value:Any):Void
	{
		for (param in params)
		{
			if (param != null && param.GetName() == name)
			{
				param.SetValue(value);
			}
		}
	}
	
	
	// 设置函数返回值
	public function SetResult(resultType:Datum = null):Void
	{
		result = resultType;
	}
	
	
	// 获取所有参数
	public function GetAllParam():Array<Datum>
	{
		return params;
	}
	
	// 获取返回值
	public function GetResult():Datum
	{
		return result;
	}
	
	
	// 克隆数据
	public function Clone():MethodInfo
	{
		var info:MethodInfo = new MethodInfo(className, methodName);
		
		for (param in params)
		{
			info.AddParam(param.Clone());
		}
		
		if(this.result != null)
			info.SetResult(this.result.Clone());
		
		return info;
	}
	
}