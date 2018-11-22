package core.node.graphnode;
import core.datum.Datum;
import core.graph.Graph;
import core.node.Node;
import core.slot.Slot;
import core.graph.EndPoint;
import core.serialization.laybox.LayBoxParamData;
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
	public function SetGraph(graph:Graph, inputParam:Dynamic):Void
	{
		curGraph = graph;
		
		if (curGraph == null)
			return;
			
		var startNode:Node = curGraph.GetNode(curGraph.GetStartNodeID());
		InitStartNode(startNode);
		if(inputParam != null)
		{
			var valueNameList:Array<String> = Reflect.fields(inputParam);
			for (valueName in valueNameList)
			{
				var valueInfo:Dynamic = Reflect.getProperty(inputParam, valueName);
				if (Reflect.hasField(valueInfo, "defaultValue"))
				{
					var value:Any = Reflect.getProperty(valueInfo, "defaultValue");
					var data:Datum = this.GetSlotData(valueName);
					if (data!=null) 
					{
						var runTimeValue:Any = LayBoxParamData.GetInstance().StrToAny(value, data.GetDatumType());
						data.SetValue(runTimeValue);
					}
				}
			}
		}
		
		
		var endNode:Node = curGraph.GetNode(curGraph.GetEndNodeID());
		InitEndNode(endNode);

		if (endNode != null)
		{
			endNode.AddOutPutCallBack(OnGraphEnd); 
		}
		
		curGraph.Activate(false);
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
		
		var allExecuteOut:Map<String, Slot> = GetAllSlotByType(allSlots, SlotType.ExecutionOut);
		
		if (allExecuteOut == null)
			return;
		
		for (slotName in allExecuteOut.keys())
		{
			var slot:Slot = allSlots.get(slotName);
			if (slot != null)
			{
				AddSlot(Slot.INITIALIZE_SLOT(slot.slotId, slot.slotType));
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
			
		curGraph.SetIsStop(false);
		var startNode:Node = curGraph.GetNode(curGraph.GetStartNodeID());
		
		if (startNode == null)
			return;
			
		curGraph.Activate(true);
		
		for (paramSlot in paramSlots)
		{
			var data:Datum = GetSlotData(paramSlot);
			startNode.SetSlotData(paramSlot,data);
		}
		
		// 子流图合并父流图的堆栈信息
		for (debugItem in this.graph.DebugStack()) 
		{
			curGraph.AddDebugStack(debugItem, true);
		}
		
		startNode.SignalInput(inSlotId);

	}
	
	
	// 当流图执行完成
	public function OnGraphEnd(slotId:String):Void
	{
		var endNode:Node = curGraph.GetNode(curGraph.GetEndNodeID());
		if (endNode == null)
			return;
		
		curGraph.SetIsStop(true);
		var allSlots:Map<String,Slot> = endNode.GetAllSlotMap();
		var allDataOut:Map<String,Slot> = GetAllSlotByType(allSlots, SlotType.DataOut);
		
		if (allDataOut == null) 
		{
			curGraph.Activate(false);
			this.SignalOutput(slotId);
			return;
		}
		
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
		
		curGraph.Activate(false);
		this.SignalOutput(slotId);
	}
	
	
	// 激活/暂停
	override public function Activate(bEnable:Bool):Void
	{
		super.Activate(bEnable);
		
		if (curGraph != null)
		{
			if (!bEnable) 
			{
				curGraph.Activate(bEnable);
			}
		}
	}
	
	
	// 清理
	override public function Release():Void
	{
		super.Release();
		
		if (curGraph != null)
			curGraph.Release();
			
		paramSlots = null;
		paramOutSlots = null;
	}
}