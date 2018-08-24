package core.graph;
import List;

/**
 * ...
 * @author MibuWolf
 */
class ExecutionStack 
{
	private var stack:List<EndPoint>;	// 执行栈
	

	public function new() 
	{
		stack = new List<EndPoint>();
	}
	
	
	// 添加执行堆栈
	public function Add(endPoint:EndPoint):Void
	{
		if (endPoint != null)
			stack.push(endPoint);
	}
	
	
	// 获取执行数据
	public function Get():EndPoint
	{
		if (stack.isEmpty())
			return null;
			
		var point:EndPoint = stack.pop();
		
		if (point == null)
			point = Get();
		
		return point;
	}
	
	
	// 获取当前堆栈中数据个数
	public function GetCount():Int
	{
		return stack.length;
	}
	
	// 清理所有堆栈数据
	public function Release():Void
	{
		stack.clear();
	}
	
}