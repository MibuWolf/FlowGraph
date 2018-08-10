package core.graph;
import haxe.io.Bytes;
import core.serialization.ISerializable;



 
/**
 * 节点插槽关系
 * @author MibuWolf
 */
class EndPoint implements ISerializable
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
	
	
	// 序列化为bytes字节数组
	public function SeriralizeToBytes(bytes:Bytes):Void
	{
		
	}
	
	// 从bytes字节数组反序列化
	public function DeserializeFromBytes(bytes:Bytes):Void
	{
		
	}
}
