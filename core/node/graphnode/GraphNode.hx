package core.node.graphnode;
import core.datum.Datum;
import core.graph.Graph;
import core.node.Node;
import core.slot.Slot;
import core.graph.EndPoint;
/**
 * 流图节点（将正在流图作为一个节点编辑）
 * @author MibuWolf
 */
class GraphNode extends ExecuteNode
{
	// 当前节点所代表的流图
	private var curGraph:Graph;
	
	// 输入参数插槽
	private var paramSlots:Array<String>;
	// 输出参数插槽
	private var paramOutSlots:Array<String>;
	
	// 作为节点的流图拥有着
	public function new(owner:Graph) 
	{
		super(owner);
	
		this.name = "GraphNode";
		this.groupName = "Graph";
		
		paramSlots = new Array<String>();
		paramOutSlots = new Array<String>();
	}
	
	// 设置当前流图节点的流图信息
	public function SetGraph(graph:Graph):Void
	{
		curGraph = graph;
		
		if (curGraph == null)
			return;
			
		var startNode:Node = curGraph.GetNode(curGraph.GetStartNodeID());
		InitStartNode(startNode);
		
		var endNode:Node = curGraph.GetNode(curGraph.GetEndNodeID());
		InitEndNode(endNode);

		if (endNode != null)
		{
			endNode.AddOutPutCallBack(OnGraphEnd);
		}
	}
	
	
	// 初始化输入节点参数
	private function InitStartNode(startNode:Node):Void
	{
		if (startNode == null)
			return;
			
		var allSlots:Map<String,Slot> = startNode.GetAllSlotMap();		
		var allDataIn:Map<String,Slot> = GetAllSlotByType(allSlots, SlotType.DataIn);
		
		if (allDataIn == null)
			return;

		for (slotName in allDataIn.keys())
		{
			var slot:Slot = allSlots.get(slotName);
			if (slot != null)
			{
				var dataDatum:Datum = startNode.GetSlotData(slot.slotId);
				this.AddDatumSlot(Slot.INITIALIZE_SLOT(slot.slotId, slot.slotType), (dataDatum == null)?null:dataDatum.Clone());
				paramSlots.push(slot.slotId);
			}
		}
	}
	
	
	// 初始化输出节点参数
	private function InitEndNode(endNode:Node):Void
	{
		if (endNode == null)
			return;
		
		var allSlots:Map<String,Slot> = endNode.GetAllSlotMap();
		var allDataOut:Map<String,Slot> = GetAllSlotByType(allSlots, SlotType.DataOut);
		
		if (allDataOut == null)
			return;
		
		for (slotName in allDataOut.keys())
		{
			var slot:Slot = allSlots.get(slotName);
			if (slot != null)
			{
				var dataDatum:Datum = endNode.GetSlotData(slot.slotId);
				this.AddDatumSlot(Slot.INITIALIZE_SLOT(slot.slotId, slot.slotType), (dataDatum == null)?null:dataDatum.Clone());
				paramOutSlots.push(slot.slotId);
			}
		}
	}
	
	
	// 根据插槽类型获取所有插槽
	private function GetAllSlotByType(allSlots:Map<String,Slot>,type:SlotType):Map<String,Slot>
	{
		if (allSlots == null)
			return null;
			
		var getSlots:Map<String,Slot> = null;
		
		for (slotName in allSlots.keys())
		{
			var slot:Slot = allSlots.get(slotName);
			if (slot != null && slot.IsSlotType(type))
			{
				if (getSlots == null)
					getSlots = new Map<String, Slot>();
					
				getSlots.set(slotName, slot);
			}
		}
		
		return getSlots;
	}
	
	
	// 进入该节点进行逻辑评价
	override public function SignalInput(slotId:String):Void
	{
		if (curGraph == null)
			return;
		
		var startNode:Node = curGraph.GetNode(curGraph.GetStartNodeID());
		if (startNode == null)
			return;
		
		for (paramSlot in paramSlots)
		{
			var data:Datum = GetSlotData(paramSlot);
			startNode.SetSlotData(paramSlot,data);
		}
		
		startNode.SignalInput(inSlotId);

	}
	
	
	// 当流图执行完成
	public function OnGraphEnd():Void
	{
		var endNode:Node = curGraph.GetNode(curGraph.GetEndNodeID());
		if (endNode == null)
			return;
			
		var allSlots:Map<String,Slot> = endNode.GetAllSlotMap();
		var allDataOut:Map<String,Slot> = GetAllSlotByType(allSlots, SlotType.DataOut);
		
		for (slotName in allDataOut.keys())
		{
			var slot:Slot = allDataOut.get(slotName);
			if (slot != null)
			{
				var dataDatum:Datum = endNode.GetSlotData(slot.slotId);
				this.SetSlotData(slotName, (dataDatum == null) ? null : dataDatum.Clone());
				
				// 获取连线参数传递
				var allEndPoints:Array<EndPoint> = this.graph.GetAllEndPoints(this.GetNodeID(), slotName);
		
				if (allEndPoints != null)
				{
					for (nextParamPoint in allEndPoints)
					{
						var nextNode:Node = this.graph.GetNode(nextParamPoint.GetNodeID());
			
						if (nextNode != null)
							nextNode.SetSlotData(nextParamPoint.GetSlotID(), dataDatum);
					}
				}
				
			}
		}
		
		
		this.SignalOutput(outSlotId);
	}
}