package core.node.event;
import core.graph.Graph;
import core.node.Node;
import core.slot.Slot;
/**
 * 事件触发节点基类
 * @author MibuWolf
 */
class TriggerNode extends Node
{
	// 输入参数插槽
	private var paramInSlots:Array<String>;
	
	// 输出参数插槽
	private var paramOutSlots:Array<String>;
	
	// 输出插槽
	private var outSlotID:String = "Out";
	
	public function new(graph:Graph) 
	{
		super(graph);
	
		AddSlot(Slot.INITIALIZE_SLOT(outSlotID, SlotType.ExecutionOut));
		
		paramInSlots = new Array<String>();
		paramOutSlots = new Array<String>();
	}
	
	// 检查当前激活状态
	override private function CheckDeActivate(data:Any):Bool
	{
		if (!bActivate)
		{
			if (!bWaitExcute)
			{
				this.bWaitExcute = true;
				var param:Array<Any> = data;
				this.waitData = param;	
			}
			return true;
		}
		
		return false;
	}
	
	
	// 被激活
	override private function OnActivate():Void
	{
		if (bWaitExcute)
		{
			var param:Array<Any> = waitData;    
			OnTrigger(param);
		}
		
		bWaitExcute = false;
		waitData = null;
	}
	
	public function OnTrigger(param:Array<Any>):Void
	{
		this.graph.AddRuntimeDebugToStack(this.GetNodeID());
	}
	
	// 释放
	override public function Release()
	{
		super.Release();
		
		paramInSlots = null;
		paramOutSlots = null;
	}
}