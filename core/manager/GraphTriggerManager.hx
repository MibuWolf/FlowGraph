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
	private var runtimeTriggers:Array<GraphTriggerInfo>;
	private var currTriggerName = "";
	
	public function new() 
	{
		allTriggers = new Map<String, Array<GraphTriggerInfo>>();
		runtimeTriggers = new Array<GraphTriggerInfo>();
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
	
	
	
	// 流图内注销注册触发器(某一流图的某一节点侦听消息事件)
	public function UnRegisterTrigger(graphID:Int, nodeID:Int,triggerClass:String, eventName:String):Void
	{
		var triggerName:String = triggerClass + "." + eventName;

		var allCurTriggers:Array<GraphTriggerInfo> = null;
		
		if (!allTriggers.exists(triggerName))
			return;
			
		allCurTriggers = allTriggers.get(triggerName);
		
		var graphTrigger:GraphTriggerInfo = this.GetGraphTriggerInfoByID(graphID,allCurTriggers);
			
		if (graphTrigger == null)
			return;
			
		graphTrigger.RemoveTriggerNode(nodeID);
		if (this.runtimeTriggers != null && this.currTriggerName == triggerName) 
		{
			while (this.runtimeTriggers.length > 0)
			{
				var len:Int = this.runtimeTriggers.length;
				this.runtimeTriggers.pop();
			}
		}
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
		
		this.runtimeTriggers = null;
		this.currTriggerName = triggerName;
		if (allTriggers.exists(triggerName))
		{
			this.runtimeTriggers = new Array<GraphTriggerInfo>();
			var allTriggersArr:Array<GraphTriggerInfo> = allTriggers.get(triggerName);
			
			for (info in allTriggersArr)
			{
				this.runtimeTriggers.push(info.Clone());
			}
			
			if (this.runtimeTriggers != null) 
			{
				for (info in this.runtimeTriggers)
				{
					info.OnTrigger(params.slice(2));
				}
			}
		}
		this.currTriggerName = "";
	}
	
	
	// 移除流图
	public function RemoveGraph(graphID:Int):Void
	{
		if (this.runtimeTriggers != null) 
		{
			this.runtimeTriggers = null;
		}
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