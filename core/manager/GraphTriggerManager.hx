package core.manager;
import core.datum.Datum;
import core.manager.trigger.GraphTriggerInfo;

/**
 * ...
 * @author MibuWolf
 */
class GraphTriggerManager 
{
	private static var instance:GraphTriggerManager;
	
	// 所有流图侦听的触发事件
	private var allTriggers:Map<String, Array<GraphTriggerInfo>>;
	
	public function new() 
	{
		allTriggers = new Map<String, Array<GraphTriggerInfo>>();
	}
	
	
	public static function GetInstance():GraphTriggerManager
	{
		if (instance == null)
		{
			instance = new GraphTriggerManager();
		}
			
		return instance;
	}
	
	// 流图内注册触发器(某一流图的某一节点侦听消息事件)
	public function RegisterTrigger(graphID:Int, nodeID:Int,triggerClass:String, eventName:String, condition:Array<Datum>):Void
	{
		var triggerName:String = triggerClass + "." + eventName;

		var allCurTriggers:Array<GraphTriggerInfo> = null;
		
		if (allTriggers.exists(triggerName))
		{
			allCurTriggers = allTriggers.get(triggerName);
		}
		else
		{
			allCurTriggers = new Array<GraphTriggerInfo>();
			allTriggers.set(triggerName,allCurTriggers);
		}
		
		var graphTrigger:GraphTriggerInfo = this.GetGraphTriggerInfoByID(graphID,allCurTriggers);
			
		if (graphTrigger == null)
		{
			graphTrigger = new GraphTriggerInfo(graphID);
			allCurTriggers.push(graphTrigger);
		}
			
		graphTrigger.AddTriggerNode(nodeID,condition);
	}
	
	
	
	// 根据流图ID查找触发节点信息
	private function GetGraphTriggerInfoByID(graphID:Int, graphList:Array<GraphTriggerInfo>):GraphTriggerInfo
	{
		for (info in graphList)
		{
			if (info != null && info.GetGraphID() == graphID)
				return info;
		}
		
		return null;
	}
	
	
	// 事件触发流图节点
	public function OnTrigger(params:Array<Any>):Void
	{
		if (params == null || params.length < 2)
			return;
		
		var triggerClass:String = params[0];
		var eventName:String = params[1];
		
		var triggerName:String = triggerClass + "." + eventName;
		
		if (allTriggers.exists(triggerName))
		{
			var allTriggers:Array<GraphTriggerInfo> = allTriggers.get(triggerName);
			
			for (info in allTriggers)
			{
				info.OnTrigger(params.slice(2));
			}
			
		}
	}
	
	
	// 移除流图
	public function RemoveGraph(graphID:Int):Void
	{
		for (triggerArray in allTriggers)
		{
			if (triggerArray == null)
				continue;
	
			
			for (triggerInfo in triggerArray)
			{
				if (triggerInfo == null)
					continue;
					
				if (triggerInfo.GetGraphID() == graphID)
				{
					triggerInfo.Release();
					triggerArray.remove(triggerInfo);
					triggerInfo = null;
				}
					
			}
		}
	}
	
}