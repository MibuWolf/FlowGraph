package core.debug;
import core.datum.Datum;
/**
 * ...
 * @author ...
 */


class DebugRuntimeGraphInfo 
{
	
	private var Graph:String;
	
	private var GraphId:Int;
	
	private var currNode:Int;
	
	private var nodes:Map<String,Map<String, Any>>;
	
	private var vars:Map<String, Any>;
	
	public function GetGraphName():String
	{
		return this.Graph;
	}
	
	public function GetCurrNode():Int
	{
		return this.currNode;
	}
	
	public function new(graph:String, graphId:Int, node:Int) 
	{
		this.GraphId = graphId;
		this.Graph = graph;
		this.currNode = node;
		nodes = new Map<String, Map<String, Any>>();
		vars = new Map<String, Any>();
	}
	
	public function GetGraphId():Int
	{
		return this.GraphId;
	}
	
	public function AddNodeInfo(nodeid:Int, info:Map<String, Any>):Void
	{
		nodes.set(Std.string(nodeid), info);
	}
	
	public function AddGraphVariable(key:String, data:Datum):Void
	{
		if (!vars.exists(key)) 
		{
			vars.set(key, data.GetValue());
		}
	}
	
}