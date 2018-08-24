package core.manager;
import core.graph.Graph;
import core.serialization.laybox.LayBoxGraphData;
/**
 * 运行时流图管理器
 * @author MibuWolf
 */
class GraphManager 
{
	// 当前运行的所有流图
	private var allGraph:Map<Int,Graph>;
	
	// 等待复用的节点ID;
	private var waitIDs:Array<Int>;
	
	// 当前分配的节点ID
	private var index:Int = 1;
	private static var instance:GraphManager;
	
	public function new() 
	{
		allGraph = new Map<Int, Graph>();
		waitIDs = new Array<Int>();
	}
	
	
	public static function GetInstance():GraphManager
	{
		if (instance == null)
			instance = new GraphManager();
			
		return instance;
	}
	
	
	// 添加一张流图
	public function AddGraph(graphName:String, owner:Int = -1):Int
	{
		var graph:Graph = LayBoxGraphData.GetInstance().GraphFormJson(graphName, GetIndex(), owner);
		if (graph == null)
			return -1;
		
		allGraph.set(graph.GetGraphID(), graph);
		
		return graph.GetGraphID();
	}
	
	
	// 添加一张流图
	public function AddByGraph(graph:Graph):Int
	{
		if (graph == null)
			return -1;
			
		allGraph.set(graph.GetGraphID(), graph);
		
		return graph.GetGraphID();
	}
	
	
	// 删除一张流图
	public  function RemoveGraph(graphID:Int):Void
	{
		if (allGraph.exists(graphID))
		{
			var graph:Graph = allGraph.get(graphID);
			
			if (graph != null)
			{
				graph.Stop();
				waitIDs.push(graphID);
			}
			
			allGraph.remove(graphID);
		}
	}
	
	
	// 获取流图索引
	private function GetIndex():Int
	{
		if (waitIDs.length <= 0)
			return index++;
		return waitIDs.pop();
	}
	
	
	// 获取流图
	public function GetGraph(id:Int):Graph
	{
		if (allGraph.exists(id))
			return allGraph.get(id);
			
		return null;
	}
	
	
	
}