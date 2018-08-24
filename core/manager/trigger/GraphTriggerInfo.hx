package core.manager.trigger;
import core.datum.Datum;
import core.manager.trigger.TriggerCondition;

/**
 * 运行时每个节点触发回调信息
 * @author MibuWolf
 */
class GraphTriggerInfo 
{
	// 所属流图ID
	private var graphID:Int;

	// 流图节点事件触发
	private var eventNodeList:Map<Int,TriggerCondition>;
	 
	public function new(id:Int) 
	{
		graphID = id;
		
		eventNodeList = new Map<Int,TriggerCondition>();
	}
	
	// 获取所属流图ID
	public function GetGraphID():Int
	{
		return graphID;
	}
	
	
	// 注册流图节点事件
	public function AddTriggerNode(nodeID:Int, condition:Array<Datum>):Void
	{
		var trigger:TriggerCondition = null;
		
		if (!eventNodeList.exists(nodeID))
		{
			trigger = new TriggerCondition(graphID, nodeID,condition);
			eventNodeList.set(nodeID,trigger);
		}
	}
	
	
	// 触发事件
	public function OnTrigger(params:Array<Any>):Void
	{
		for (trigger in eventNodeList)
		{
			if (trigger != null)
				trigger.Evaluate(params);
		}
	}
	
	
	// 清理
	public function Release():Void
	{
		graphID = -1;
		
		for (trigger in eventNodeList)
		{
			if (trigger != null)
				trigger.Release();
		}
		
		eventNodeList = null;
	}
}