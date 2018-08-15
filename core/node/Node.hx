package core.node;
import core.datum.Datum;
import core.graph.Graph;
import core.slot.Slot;
import core.graph.EndPoint;

/**
 * 节点基类
 * @author MibuWolf
 */

 
// 节点类型
enum NodeType 
{
	INVALID;		// 无效的
	NORMAL;			// 普通
	LOGIC;
	METHOD;			// 功能方法
	DATA;			// 数据
	TRIGGER;		// 触发
}

class Node
{
	static public var InvalidNode:Int = -1;
	// 节点类型
	private var type(default, null):NodeType;
	
	// 节点名称
	private var name(default, null):String;
	
	// 节点所属组名
	private var groupName(default, null):String;
	
	// 节点id
	private var nodeId(default, null):Int; 
	
	// 插槽列表
	private var slots:Map<String, Slot>;
	
	// 节点数据列表[与插槽id对应]
	private var datumMap:Map<String, Datum>;
	
	// 所属流图
	private var graph(default, null):Graph;
	
	public function new(owner:Graph) 
	{
		graph = owner;
		type = NodeType.NORMAL;
	
		slots = new Map<String, Slot>();
		datumMap = new Map<String, Datum>();
	}
	
	public function Initialize(_nodeId:Int, _type:NodeType, _name:String = "", _groupName:String = ""):Void
	{
		this.nodeId = _nodeId;
		this.name = _name;
		this.groupName = _groupName;
		this.type = _type;
	}
	
	
	// 获取节点ID
	public function GetNodeID():Int
	{
		return nodeId;
	}
	
	
	// 添加插槽
	public function AddSlot(slot:Slot):Void
	{
		if(slot != null)
			slots.set(slot.slotId, slot);
	}

	
	// 添加带默认数据的插槽
	public function AddDatumSlot(slot:Slot, data:Datum):Void
	{
		if (slot == null)
			return;
		
		slots.set(slot.slotId, slot);
		this.datumMap.set(slot.slotId, data);
	}
	
	
	// 获取插槽
	public function GetSlot(slotID:String):Slot
	{
		if (this.slots.exists(slotID))
			return this.slots[slotID];
			
		return null;
	}
	
	
	// 设置插槽数据
	public function SetSlotData(slotId:String, data:Datum):Void
	{
		datumMap.set(slotId, data);
	}

	
	// 获取对应插槽id的插槽数据
	public function GetSlotData(slotId:String):Datum
	{
		if(datumMap.exists(slotId))
		{
			return this.datumMap.get(slotId);
		}
		
		return null;
	}
	
	// 获取对应插槽id的插槽数据类型
	public function GetSlotDataType(slotId:String):DatumType
	{
		var data:Datum = this.GetSlotData(slotId);
		
		if(data == null)
			return DatumType.INVALID;
			
		return data.GetType();
	}

	
	// 逻辑输入插槽执行
	public function SignalInput(slotId:String):Void
	{
		
	}
	
	
	// 退出节点对应的插槽
	public function SignalOutput(slotId:String):Void
	{
		if (graph == null)
			return;
		
		var executionCheckRequired = false;
		
		if (slotId != Slot.InvalidSlot)
		{
			// 查找插槽
			var slot:Slot = this.slots.get(slotId);
			if (slot != null)
			{
				// 查找关系
				var endpoints:Array<EndPoint> = graph.GetAllEndPoints(nodeId, slotId);
				for (endpoint in endpoints)
				{
					// 能否查找出下个节点
					var nextNode:Node = graph.GetNode(endpoint.GetNodeID());
					if (nextNode != null)
					{
						graph.AddToExecutionStack(endpoint);
						executionCheckRequired = true;
					}
				}
			}
			else
			{
				// Node does not have the output slot that was signaled
			}
		}
	
		// 执行下一步
		if (executionCheckRequired)
		{
			graph.Execute();	
		}	
		
	}

}