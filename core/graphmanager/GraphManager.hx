package core.graphmanager;
import core.graph.Graph;
import reflectclass.TriggerInfo;
/**
 * 运行时流图管理器
 * @author MibuWolf
 */
class GraphManager 
{
	// 当前运行的所有流图
	private var allGraph:Map<Int,Graph>;
	
	// 所有流图侦听的触发事件
	private var allTriggers:Map<String, Array<GraphTriggerInfo>>;
	// 流图配置信息
	//private var allGraphData:Map<String,Json>
	
	private static var instance:GraphManager;
	
	public function new() 
	{
		allGraph = new Map<Int, Graph>();
		allTriggers = new Map<String, Array<GraphTriggerInfo>>();
	}
	
	
	public static function GetInstance():GraphManager
	{
		if (instance == null)
			instance = new GraphManager();
			
		return instance;
	}
	
	
	// 添加一张流图
	public function AddGraph(graph:Graph):Void
	{
		if (graph != null)
		{
			allGraph.set(graph.GetGraphID(), graph);
		}
	}
	
	// 获取流图
	public function GetGraph(id:Int):Graph
	{
		if (allGraph.exists(id))
			return allGraph.get(id);
			
		return null;
	}
	
	
	// 流图内注册触发器(某一流图的某一节点侦听消息事件)
	public function RegisterTrigger(graphID:Int, nodeID:Int,triggerClass:String, eventName:String):Void
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
			
		graphTrigger.AddTriggerNode(triggerName, nodeID);
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
	public function OnTrigger(triggerClass:String, eventName:String, triggerInfo:TriggerInfo):Void
	{
		var triggerName:String = triggerClass + "." + eventName;
		
		if (allTriggers.exists(triggerName))
		{
			var allTriggers:Array<GraphTriggerInfo> = allTriggers.get(triggerName);
			
			for (info in allTriggers)
			{
				info.OnTrigger(triggerName, triggerInfo);
			}
			
		}
	}
	
}