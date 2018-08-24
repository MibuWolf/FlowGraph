package core.slot;


/**
 * ...
 * @author MibuWolf
 */

  
// 插槽类型
enum SlotType 
{
	ExecutionIn;	// 	执行入
	ExecutionOut;	//  执行处
	DataIn;			//  数据入
	DataOut;		//	数据出
}


class Slot
{
	static public var InvalidSlot:String = "";

	// 插槽类型
	public var slotType(default, null):SlotType;
	
	// 插槽名称
	public var slotId(default, null):String;
	
	
	public function new()
	{
		Initialize(Slot.InvalidSlot, SlotType.ExecutionIn);
	}
	
	public function Initialize(name:String, type:SlotType) 
	{
		slotType = type;
		slotId = name;
	}
	
	// 是否可连接
	public function CanConnect(type:SlotType):Bool
	{
		return (slotType == SlotType.DataOut && type == SlotType.DataIn) ||
		(slotType == SlotType.DataIn && type == SlotType.DataOut) ||
		(slotType == SlotType.ExecutionIn && type == SlotType.ExecutionOut) ||
		(slotType == SlotType.ExecutionOut && type == SlotType.ExecutionIn);
	}
	
	// 是否是数据
	public function IsData():Bool
	{
		return slotType == SlotType.DataIn || slotType == SlotType.DataOut;
	}
	
	// 判定插槽类型
	public function IsSlotType(type:SlotType):Bool
	{
		return slotType == type;
	}
	
	// 是否是In数据
	public function IsIn():Bool
	{
		return slotType == SlotType.DataIn || slotType == SlotType.ExecutionIn;
	}
	
	// 是否是Out数据
	public function IsOut():Bool
	{
		return slotType == SlotType.DataOut || slotType == SlotType.ExecutionOut;
	}
	
	
	public static function INITIALIZE_SLOT(id:String, type:SlotType)
	{

		var slot:Slot = new Slot();
		slot.Initialize(id, type);
        
		return slot;
	}
}
