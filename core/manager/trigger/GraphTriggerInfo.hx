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
	
	
	// 移除流图节点
	public function RemoveTriggerNode(nodeID:Int):Void
	{
		if (!eventNodeList.exists(nodeID))
			return;
		
		eventNodeList.remove(nodeID);
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
	
	public function Clone():GraphTriggerInfo
	{
		var data:GraphTriggerInfo = new GraphTriggerInfo(this.graphID);
		for (key in this.eventNodeList.keys())
		{
			data.eventNodeList.set(key, this.eventNodeList.get(key).Clone());
		}
		
		return data;
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