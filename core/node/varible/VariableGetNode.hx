package core.node.varible;
import core.graph.Graph;
import core.node.ExecuteNode;
import core.datum.Datum;
import core.slot.Slot;
import core.graph.EndPoint;
/**
 * ...
 * @author ...
 */
class VariableGetNode extends ExecuteNode
{
	private var paramSlots:String;
	
	public function new(owner: Graph) 
	{
		super(owner);
		
		this.name = "Get";
		this.groupName = "VariableGraph";
	}
	
	
	public function Initialization(data:Datum):Bool
	{
		if (data == null) 
		{
			return false;
		} 
		this.paramSlots = data.GetName();
		
		var paramSlot:Slot = Slot.INITIALIZE_SLOT(data.GetName(), SlotType.DataOut);
		this.AddDatumSlot(paramSlot, data.Clone());
		
		return true;
	}
	
	
	// 进入该节点进行逻辑评价
	override public function SignalInput(varName:String):Void
	{
		if (CheckDeActivate(varName))
			return;
		var value:Any = graph.GetVaribleValue(this.paramSlots);
		
		var paramSlotData:Datum = this.GetSlotData(this.paramSlots);
		if (paramSlotData == null) 
		{
			return;
		}
		
		paramSlotData.SetValue(value);
		
		// 获取连线参数传递
		var allEndPoints:Array<EndPoint> = this.graph.GetAllEndPoints(this.GetNodeID(), this.paramSlots);
	
		if (allEndPoints != null)
		{
			for (nextParamPoint in allEndPoints)
			{
				var nextNode:Node = this.graph.GetNode(nextParamPoint.GetNodeID());
		
				if (nextNode != null)
					nextNode.SetSlotData(nextParamPoint.GetSlotID(), paramSlotData);
			}
		}
		
		SignalOutput(outSlotId);
		
	}
	
	override public function Release()
	{
		super.Release();
	}
	
}