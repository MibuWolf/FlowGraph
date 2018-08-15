package reflectclass;
import core.datum.Datum;
/**
 * ...
 * @author MibuWolf
 */
class TriggerInfo 
{

	// 所属类类名
	private var className:String;
	// 方法名
	private var methodName:String;
	// 输入参数类型及默认值
	private var params:Array<Datum>;
	// 参数个数
	private var paramCount:Int;
	
	
	public function new(cName:String, mName:String) 
	{
		className = cName;
		methodName = mName;
		
		params = new Array<Datum>();
		paramCount = 0;
		
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
			
		paramCount = params.length;
	}
	
	// 设置参数值
	public function SetParamValue(index:Int, value:Any):Void
	{
		if (index < 0 || index >= paramCount)
			return;
			
		var datum:Datum = params[index];
		
		if (datum != null)
		{
			datum.SetValue(value);
		}
	}
	
	
	// 获取参数值
	public function GetParamValue(index:Int):Any
	{
		if (index < 0 || index >= paramCount)
			return null;	
			
		var datum:Datum = params[index];
		
		if (datum == null)
			return null;
			
		return datum.GetValue();
	}
	
	
	// 获取所有参数
	public function GetAllParam():Array<Datum>
	{
		return params;
	}
	
}