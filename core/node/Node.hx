package core.node;
import core.datum.Datum;
import core.graph.Graph;
import core.slot.Slot;
import core.graph.EndPoint;
import core.debug.DebugRuntimeGraphInfo;
import core.manager.GraphManager;
import reflectclass.ReflectHelper;

/**
 * 节点基类
 * @author MibuWolf
 */

 
// 节点类型
enum NodeType 
{
	INVALID;		// 无效的
	data;			// 数据节点
	ctrl;			// 方法节点
	event;			// 触发节点
	variable;			// 数据节点
	custom;		// 自定义节点
	graph;		// 流图节点
	logic;		// 逻辑节点
	start;	// 流图事件节点
	end;
}

enum NodeSubType
{
	INVALID;		// 无效的
	Bridge;
	Switch;
}

enum NodeState
{
	INVALID;		// 无效的
	Bridge;
	Switch;
}

/*Data = "data",	// 数据类型没有In插槽Out插槽
		Ctrl = "ctrl",	// 功能类型具有In和Out插槽
		Event = "event",	// 事件类型无In插槽
		Variable = "variable",	// 变量类型
		Custom = "custom"	// 自定义节点类型*/


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
	
	// 执行完成回调
	private var outPutCallBack:String->Void;
	
	public var IsBreakpointing:Bool = false;
	
	// 当前节点是否被激活
	private var bActivate:Bool;
	// 被断后等待执行的流图输入节点
	public var bWaitExcute:Bool = false;
	private var waitData:Any = null;	
	
	public var logs:Array<String>;
	
	public function new(owner:Graph) 
	{
		graph = owner;
		type = NodeType.ctrl;
		slots = new Map<String, Slot>();
		datumMap = new Map<String, Datum>();
		IsBreakpointing = false;
		bActivate = true;
		bWaitExcute = false;
		waitData = null;
		logs = new Array<String>();
	}
	
	// 激活/暂停
	public function Activate(bEnable:Bool):Void
	{
		bActivate = bEnable;
		
		if (bActivate)
		{
			OnActivate();
		}
	}
	
	public function GetNodeType():NodeType
	{
		return this.type;
	}
	
	// 被激活
	private function OnActivate():Void
	{
		if (bWaitExcute)
		{
			SignalInput(waitData);
		}
		
		bWaitExcute = false;
		waitData = null;
	}
	
	public function ClearLogs():Void
	{
		while (logs.length > 0)
		{
			logs.pop();
		}
	}
	
	// 检查当前激活状态
	private function CheckDeActivate(data:Any):Bool
	{
		if (!bActivate)
		{
			if (!bWaitExcute)
			{
				this.bWaitExcute = true;
				var slotId:String = data;
				this.waitData = slotId;	
			}
			return true;
		}
		
		return false;
	}
	
	public function GetAllDatumMap():Map<String, Datum>
	{
		return datumMap;
	}
	
	public function GetAllSlotMap():Map<String, Slot>
	{
		return slots;
	}
	
	public function GetName():String
	{
		return name;
	}
	
	public function GetGroupName():String
	{
		return groupName;
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
		if(slot != null && !slots.exists(slot.slotId))
			slots.set(slot.slotId, slot);
	}
	
	
	// 移除插槽
	public function RemoveSlot(slotId:String):Void
	{
		if (slots.exists(slotId))
			slots.remove(slotId);
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
			
		return data.GetDatumType();
	}

	
	// 逻辑输入插槽执行
	public function SignalInput(slotId:String):Void
	{
		
	}
	
	public function AddLogs(msg:String):Void
	{
		logs.push(msg);
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
		
		if (outPutCallBack != null)
		{
			outPutCallBack(slotId);
		}
		
	}
	
	public function GetSlotsBySlotType(type:SlotType):Array<Slot>
	{
		var outSlotArr:Array<Slot> = new Array<Slot>();
		
		for (slotitem in slots) 
		{
			if (slotitem.IsSlotType(type)) 
			{
				outSlotArr.push(slotitem);
			}
		}
		
		return outSlotArr;
	}
	
	
	// 添加执行完成回调
	public function AddOutPutCallBack(callbback:String->Void):Void
	{
		outPutCallBack = callbback;
	}

	
	// 清理
	public function Release()
	{
		for (slot in slots)
		{
			if (slot != null)
				slot.Release();
		}
		
		slots = null;
		
		for (datum in datumMap)
		{
			if (datum != null)
				datum.Release();
		}
		
		datumMap = null;
		
		outPutCallBack = null;
		waitData = null;
		graph = null;
		type = NodeType.INVALID;
		name = "";
		groupName = "";
		nodeId = -1;
	}
}