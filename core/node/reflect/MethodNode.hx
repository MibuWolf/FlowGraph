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
		
		type = NodeType.METHOD;
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

		if (methodInfo == null)
			return;
		
		var params:Array<Any> = new Array<Any>();
		

		for (paramSlotItem in paramSlots)
		{
			var data:Datum = GetSlotData(paramSlotItem);
			if (data != null) 
			{
				data = GetSlotData(paramSlotItem);
				params.push(data.GetValue());
			}
	
			else
			{
				params.push(null);
			}
		}

		var result:Any = ReflectHelper.GetInstance().CallSingleMethod(methodInfo.GetClassName(), methodInfo.GetMethodName(), params);
		
		if (resultSlotID != Slot.InvalidSlot && result != null)
		{
			var resultDefalut:Datum = methodInfo.GetResult();
			var resultDatum:Datum = resultDefalut.Clone();
			
			resultDatum.SetValue(result);

			graph.SetNodeResultData(nodeId, resultSlotID, resultDatum);	
		}

		SignalOutput( outSlotId);
	}
}