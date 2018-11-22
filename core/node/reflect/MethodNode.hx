package core.node.reflect;
import core.datum.Datum;
import core.graph.Graph;
import core.slot.Slot;
import reflectclass.MethodInfo;
import core.node.Node;
import reflectclass.ReflectHelper;
import core.graph.EndPoint;

/**
 * 反射逻辑层成员方法
 * @author MibuWolf
 */
class MethodNode extends ExecuteNode
{	
	// 输入参数插槽
	private var paramSlots:Array<String>;
	
	// 输出参数插槽

	private var resultSlotID:String = "Value";
	
	// 方法信息
	private var methodInfo:MethodInfo;
	
	
	public function new(owner:Graph) 
	{
		super(owner);
		
		type = NodeType.ctrl;
		paramSlots = new Array<String>();

		resultSlotID = "Value";
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
		
		if (result != null)
		{
			var resultSlot:Slot = Slot.INITIALIZE_SLOT(resultSlotID, SlotType.DataOut);
			this.AddDatumSlot(resultSlot, result);
		}
			
		return true;
		
	}
	
	
	// 进入该节点进行逻辑评价
	override public function SignalInput(slotId:String):Void
	{
		if (methodInfo == null || CheckDeActivate(slotId))
			return;
		
			
		var params:Array<Any> = new Array<Any>();
		
		for (paramSlot in paramSlots)
		{
			var data:Datum = GetSlotData(paramSlot);
			
			if(data != null)
			{
				if (data.GetDatumType() == DatumType.USERID) 
				{
					var pid:Int = Std.parseInt(data.GetValue());
					var eid:Dynamic = ReflectHelper.GetInstance().CreateLogicData("userid", pid);
					params.push(eid);
				}
				else
				{
					params.push(data.GetValue());
				}
			}
			else
			{
				data = methodInfo.GetDefaultData(paramSlot);
				
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
		
		var result:Any = ReflectHelper.GetInstance().CallSingleMethod(methodInfo.GetClassName(), methodInfo.GetMethodName(), params);

		if (resultSlotID != Slot.InvalidSlot && result != null)
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

		}

		SignalOutput( outSlotId);
	}

	
	// 清理
	override public function Release()
	{
		super.Release();
		
		paramSlots = null;
	}
	
}