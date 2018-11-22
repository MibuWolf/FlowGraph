package core.node.customs;
import core.datum.Datum;
import core.graph.Graph;
import core.graph.EndPoint;
import core.slot.Slot;
import core.slot.Slot.SlotType;

/**
 * ...
 * @author ...
 */
class SwitchExecuteNode extends CustomExecuteNode 
{

	public function new(owner:Graph) 
	{
		super(owner);
		
	}
	
	// 进入该节点进行逻辑评价
	override public function SignalInput(slotId:String):Void
	{ 
		if (customInfo == null || CheckDeActivate(slotId))
			return;
		
			
		if (inputSlotList.length <= 0) 
		{
			return;
		}
		var switchValue:Datum = GetSlotData(inputSlotList[0]);
	
		var valueStr:String = Std.string(switchValue.GetValue());
		
		var outSlot:String = valueStr;
		
		var slots:Array<Slot> = GetSlotsBySlotType(SlotType.ExecutionOut);
		for (nextItem in slots)
		{
			if (nextItem.slotId == valueStr) 
			{
				outSlot = valueStr;
				break;
			}
		}
		
		SignalOutput(outSlot);
	}
	
}