package core.node.reflect;
import core.datum.Datum;
import core.graph.Graph;
import core.slot.Slot;
import reflectclass.MethodInfo;
import core.node.Node;
import reflectclass.ReflectHelper;
import core.graph.EndPoint;

/**
 * ...
 * @author MibuWolf
 */
class MethodNode extends Node
{
	// 逻辑进入
	private var inSlotId:String = "In";
	
	// 逻辑退出
	private var outSlotId:String = "Out";
	
	// 输入参数插槽
	private var paramSlots:Array<String>;
	
	// 输出参数插槽
	private var resultSlotID:String;
	
	// 方法信息
	private var methodInfo:MethodInfo;
	
	
	public function new(owner:Graph) 
	{
		super(owner);
		
		type = NodeType.METHOD;
		paramSlots = new Array<String>();
		resultSlotID = Slot.InvalidSlot;
	}
	
	
	public function Initialization(method:MethodInfo):Bool
	{
		methodInfo = method;
		
		if (methodInfo == null)
			return false;
		
		paramSlots = new Array<String>();
		var params:Array<Datum> = methodInfo.GetAllParam();
		
		if (params == null)
			return true;
		
		for (data in params)
		{
			if (data != null)
			{
				var paramSlot:Slot = Slot.INITIALIZE_SLOT(data.GetName(), SlotType.DataIn);
				this.AddDatumSlot(paramSlot, data);
				paramSlots.push(data.GetName());
			}
		}
			
		var result:Datum = methodInfo.GetResult();
		
		if (result == null)
			resultSlotID = Slot.InvalidSlot;
		else
		{
			var resultSlot:Slot = Slot.INITIALIZE_SLOT(result.GetName(), SlotType.DataOut);
			this.AddDatumSlot(resultSlot, result);
			resultSlotID = result.GetName();
		}
			
		return true;
		
	}
	
	
	
	// 进入该节点进行逻辑评价
	override public function SignalInput(slotId:String):Void
	{
		if (inSlotId != slotId)
			return;
			
		
		if (methodInfo == null)
			return;
		
		var params:Array<Any> = new Array<Any>();
		
		for (paramSlots in paramSlots)
		{
			var data:Datum = GetSlotData(paramSlots);
			
			params.push(data.GetType());
		}
		
		var result:Any = ReflectHelper.GetInstance().CallSingleMethod(methodInfo.GetClassName(), methodInfo.GetMethodName(), params);
		
		if (resultSlotID != Slot.INITIALIZE_SLOT && result != null)
		{
			var resultDatum:Datum = this.GetSlotData(resultSlotID);
			resultDatum.SetValue(result);
			this.SetSlotData(resultSlotID, resultDatum);
			
			// 获取连线参数传递
			var allEndPoints:Array<EndPoint> = this.graph.GetAllEndPoints(this.GetNodeID(), resultSlotID);
			
			if (allEndPoints != null)
			{
				for (nextParamPoint in allEndPoints)
				{
					var nextNode:Node = this.graph.GetNode(nextParamPoint.GetNodeID());
					
					if (nextNode != null)
						nextNode.SetSlotData(nextParamPoint.GetSlotID(), resultDatum);
				}
			}
			
			SignalOutput();
		}
	}
}