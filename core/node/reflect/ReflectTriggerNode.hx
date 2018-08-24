package core.node.reflect;
import core.node.event.TriggerNode;
import core.graph.Graph;
import reflectclass.TriggerInfo;
import core.datum.Datum;
import core.slot.Slot;
import core.graph.EndPoint;
import core.manager.GraphTriggerManager;
/**
 * 反射逻辑层事件
 * @author MibuWolf
 */
class ReflectTriggerNode extends TriggerNode
{
	private var triggerInfo:TriggerInfo;
	
	public function new(graph:Graph) 
	{
		super(graph);
	}
	
	
	// 初始化节点
	public function Initialization(callbackInfo:TriggerInfo):Bool
	{
		if (callbackInfo == null)
			return false;
		
		var params:Array<Datum> = callbackInfo.GetAllParam();
		
		if (params == null)
			return true;
		
		triggerInfo = callbackInfo;
		var allInDatum:Array<Datum> = new Array<Datum>();
	
		for (data in params)
		{
			if (data != null)
			{
				if (data.GetValue() == null)
				{
					var paramSlot:Slot = Slot.INITIALIZE_SLOT(data.GetName(), SlotType.DataOut);
					this.AddDatumSlot(paramSlot, data);
					paramOutSlots.push(data.GetName());
				}
				else
				{
					var paramSlot:Slot = Slot.INITIALIZE_SLOT(data.GetName(), SlotType.DataOut);
					this.AddDatumSlot(paramSlot, data);
					paramInSlots.push(data.GetName());
					
					allInDatum.push(data);
				}
				
			}
		}
		
		GraphTriggerManager.GetInstance().RegisterTrigger(this.graph.GetGraphID(), this.GetNodeID(), callbackInfo.GetClassName(), callbackInfo.GetMethodName(),allInDatum);
			
		return true;
		
	}
	
	
	
	// 触发
	override public function OnTrigger(params:Array<Any>):Void
	{
		if (triggerInfo == null || CheckDeActivate(params))
			return;
		
		var index:Int = 0;
		var inParam:Int = paramInSlots.length;
		for (data in params)
		{
			if (index >= inParam)
			{
					var outSlotData:Datum = this.GetSlotData(paramOutSlots[index-inParam]);
				
				if (outSlotData != null)
					outSlotData.SetValue(data);
			
			// 获取连线参数传递
				var allEndPoints:Array<EndPoint> = this.graph.GetAllEndPoints(this.GetNodeID(), paramOutSlots[index-inParam]);
				if (allEndPoints != null)
				{
					for (nextParamPoint in allEndPoints)
					{
						var nextNode:Node = this.graph.GetNode(nextParamPoint.GetNodeID());
				
						if (nextNode != null)
							nextNode.SetSlotData(nextParamPoint.GetSlotID(), data);
					}
				}
			}
				
				
				index++;
			}
			
		this.SignalOutput(outSlotID);
	}
	
}