package core.node.customs;

import core.graph.Graph;
import core.datum.Datum;
import core.slot.Slot;
import reflectclass.CustomNodeInfo;
import core.graph.EndPoint;
/**
 * ...
 * @author ...
 */
class CustomExecuteNode extends ExecuteNode 
{
	// 输入参数插槽
	private var inputSlotList:Array<String>;
	
	private var outputSlotList:Array<String>;
	
	private var customInfo:CustomNodeInfo;
	
	public function new(owner:Graph) 
	{
		super(owner);
		
		inputSlotList = new Array<String>();
		outputSlotList = new Array<String>();
		
	}
	
	public function Initialization(method:CustomNodeInfo):Bool
	{
		customInfo = method;
		
		if (customInfo == null)
			return false;
		
		for (inputItemData in customInfo.GetInputList()) 
		{
			var paramSlot:Slot = Slot.INITIALIZE_SLOT(inputItemData.GetName(), SlotType.DataIn);
			this.AddDatumSlot(paramSlot, inputItemData);
			inputSlotList.push(inputItemData.GetName());
		}
		
		for (outputItem in customInfo.GetOutputList()) 
		{
			var paramSlot:Slot = Slot.INITIALIZE_SLOT(outputItem.GetName(), SlotType.DataOut);
			this.AddDatumSlot(paramSlot, outputItem);
			outputSlotList.push(outputItem.GetName());
		}
		
		for (nextItem in customInfo.GetNext()) 
		{
			if (nextItem != "Out") 
			{
				AddSlot(Slot.INITIALIZE_SLOT(nextItem, SlotType.ExecutionOut));
				outSlotId = nextItem;
			}
		}
			
		return true;
		
	}
	
	// 进入该节点进行逻辑评价
	override public function SignalInput(slotId:String):Void
	{
		
		if (customInfo == null || CheckDeActivate(slotId))
			return;
			
			
		var params:Array<Any> = new Array<Any>();
		
		for (paramSlot in inputSlotList)
		{
			var data:Datum = GetSlotData(paramSlot);
			
			if(data != null)
			{
				params.push(data.GetValue());
			}
			else
			{
				data = customInfo.GetDefaultData(paramSlot, customInfo.GetInputList());
				
				if (data != null)
				{
					params.push(data.GetValue());
				}
				else
				{
					params.push(null);
				}
			}
		}
		var index:Int = 0;
		for (outparamSlot in outputSlotList)
		{
			var allEndPoints:Array<EndPoint> = this.graph.GetAllEndPoints(this.GetNodeID(), outparamSlot);
			var resultDatum:Datum = customInfo.GetOutputList()[index];
			resultDatum.SetValue(params[index]);
			if (allEndPoints != null)
			{
				for (nextParamPoint in allEndPoints)
				{
					var nextNode:Node = this.graph.GetNode(nextParamPoint.GetNodeID());
			
					if (nextNode != null)
						nextNode.SetSlotData(nextParamPoint.GetSlotID(), resultDatum);
				}
			}
			index++;
		}
		SignalOutput( outSlotId);
	}

	
	// 清理
	override public function Release()
	{
		super.Release();
		
		inputSlotList = null;
		outputSlotList = null;
		customInfo = null;
	}
	
}