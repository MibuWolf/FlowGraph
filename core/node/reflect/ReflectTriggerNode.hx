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
	private var paramIndex:Int;
	
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
	
		var index:Int = 0;
		var inputCount:Int = triggerInfo.GetInputParamCount();
		for (data in params)
		{
			if (data != null)
			{
				if (index >= inputCount)
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
			
			index++;
		}
		
		GraphTriggerManager.GetInstance().RegisterTrigger(this.graph.GetGraphID(), this.GetNodeID(), triggerInfo.GetClassName(), triggerInfo.GetMethodName(),allInDatum);
			
		return true;
		
	}
	
	
	
	// 触发
	override public function OnTrigger(params:Array<Any>):Void
	{
		super.OnTrigger(params);
		if (triggerInfo == null || CheckDeActivate(params))
			return;
		
		var index:Int = 0;
		var inParam:Int = triggerInfo.GetInputParamCount();
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
							nextNode.SetSlotData(nextParamPoint.GetSlotID(), outSlotData.Clone());
					}
				}
			}
				
				
				index++;
			}
			
		this.SignalOutput(outSlotID);
	}
	
	
	override public function Activate(bEnable:Bool):Void
	{
		if (triggerInfo == null)
			return;
			
		if (bEnable)
		{
			var allInDatum:Array<Datum> = new Array<Datum>();
	
			var params:Array<Datum> = triggerInfo.GetAllParam();
			
			var index:Int = 0;
			var inputCount:Int = triggerInfo.GetInputParamCount();
			for (data in params)
			{
				if (data != null)
				{
					if (index >= inputCount)
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
				
				index++;
			}
		
			GraphTriggerManager.GetInstance().RegisterTrigger(this.graph.GetGraphID(), this.GetNodeID(), triggerInfo.GetClassName(), triggerInfo.GetMethodName(),allInDatum);
		}
		else
		{
			GraphTriggerManager.GetInstance().UnRegisterTrigger(this.graph.GetGraphID(), this.GetNodeID(), triggerInfo.GetClassName(), triggerInfo.GetMethodName());
		}
	}
	
	
		// 清理
	override public function Release()
	{
		super.Release();
		
		if (triggerInfo == null)
			return;
			
		GraphTriggerManager.GetInstance().UnRegisterTrigger(this.graph.GetGraphID(), this.GetNodeID(), triggerInfo.GetClassName(), triggerInfo.GetMethodName());
		
		triggerInfo = null;
	}
	
}