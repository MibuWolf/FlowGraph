package core.node;
import core.graph.Graph;
import core.slot.Slot;
/**
 * 执行节点基类 至少有一个执行入口插槽一个只从出口插槽
 * @author MibuWolf
 */
class ExecuteNode extends Node
{

	// 逻辑进入
	private var inSlotId:String = "In";
	
	// 逻辑退出
	private var outSlotId:String = "Out";
	
	private var tips:String;
	
	public function new(owner:Graph) 
	{
		super(owner);
		
		AddSlot(Slot.INITIALIZE_SLOT(inSlotId, SlotType.ExecutionIn));
		AddSlot(Slot.INITIALIZE_SLOT(outSlotId, SlotType.ExecutionOut));
	}
	
	public function GetTips():String
	{
		return tips;
	}
	
	public function SetTips(tip:String):Void
	{
		this.tips = tip;
	}
	
}