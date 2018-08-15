package core.node.reflect;
import core.node.event.EventNode;
import core.graph.Graph;
import reflectclass.TriggerInfo;
import core.datum.Datum;
import core.slot.Slot;
import core.graph.EndPoint;
import core.graphmanager.GraphManager;
/**
 * 反射逻辑层事件
 * @author MibuWolf
 */
class TriggerNode extends EventNode
{
	public function new(graph:Graph) 
	{
		super(graph);
	}
	
	
	// 初始化节点
	public function Initialization(callbackInfo:TriggerInfo):Bool
	{
		if (callbackInfo == null)
			return false;
		
		paramSlots = new Array<String>();
		var params:Array<Datum> = callbackInfo.GetAllParam();
		
		if (params == null)
			return true;
		
		for (data in params)
		{
			if (data != null)
			{
				var paramSlot:Slot = Slot.INITIALIZE_SLOT(data.GetName(), SlotType.DataOut);
				this.AddDatumSlot(paramSlot, data);
				paramSlots.push(data.GetName());
			}
		}
		
		GraphManager.GetInstance().RegisterTrigger(this.graph.GetGraphID(), this.GetNodeID(), callbackInfo.GetClassName(), callbackInfo.GetMethodName());
			
		return true;
		
	}
	
	
	
	// 触发
	public function OnTrigger(callbackInfo:TriggerInfo):Void
	{
		if (callbackInfo != null)
		{
			var params:Array<Datum> = callbackInfo.GetAllParam();
			
			var index:Int = 0;
			for (data in params)
			{
				this.SetSlotData(paramSlots[index], data);
				
				// 获取连线参数传递
				var allEndPoints:Array<EndPoint> = this.graph.GetAllEndPoints(this.GetNodeID(), paramSlots[index]);
		
				if (allEndPoints != null)
				{
					for (nextParamPoint in allEndPoints)
					{
						var nextNode:Node = this.graph.GetNode(nextParamPoint.GetNodeID());
					
						if (nextNode != null)
							nextNode.SetSlotData(nextParamPoint.GetSlotID(), data);
					}
				}
				
				index++;
			}
			
		}
		
		this.SignalOutput(outSlotID);
	}
	
}