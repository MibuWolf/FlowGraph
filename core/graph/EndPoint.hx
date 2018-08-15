package core.graph;

 
/**
 * 节点插槽关系
 * @author MibuWolf
 */
class EndPoint
{
	private var nodeId(default, null):Int;	//端点id
	private var slotId(default, null):String; //插槽id
	
	public function new(nodeId:Int = -1, slotId:String = "")
	{
		this.nodeId = nodeId;
		this.slotId = slotId;
	}
	
	
	
	// 获取节点ID
	public function GetNodeID():Int
	{
		return nodeId;
	}
	
	
	// 获取插槽ID
	public function GetSlotID():String
	{
		return slotId;
	}
	
	
	// 设置节点ID
	public function SetNodeID(id:Int):Void
	{
		nodeId = id;
	}
	
	
	// 设置插槽ID
	public function SetSlotID(id:String):Void
	{
		slotId = id;
	}
	
}
