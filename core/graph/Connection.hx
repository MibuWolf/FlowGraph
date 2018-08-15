package core.graph;
import core.node.Node;
import core.slot.Slot;
import haxe.io.Bytes;
/**
 * ...
 * @author MibuWolf
 */
class Connection
{
	// 源
	private var sourcePoint:EndPoint;
	// 目标
	private var targetPoint:EndPoint;
	
	public function new(sNode:Int = -1, sSlot:String = "", tNode:Int = -1, tSlot:String = "") 
	{
		sourcePoint = new EndPoint(sNode, sSlot);
		targetPoint = new EndPoint(tNode,tSlot);
	}
	
	
	// 设置源节点ID
	public function SetSourceNodeID(sNodeID:Int):Void
	{
		if (sourcePoint == null)
			sourcePoint = new EndPoint(sNodeID);
		else
			sourcePoint.SetNodeID(sNodeID);
	}
	
	
	// 获取源节点ID
	public function GetSourceNodeID():Int
	{
		if (sourcePoint == null)
			return Node.InvalidNode;

		return sourcePoint.GetNodeID();
	}
	
	
	// 设置源插槽ID
	public function SetSourceSlotID(sSlotID:String):Void
	{
		if (sourcePoint == null)
			sourcePoint = new EndPoint(Node.InvalidNode,sSlotID);
		else
			sourcePoint.SetSlotID(sSlotID);
	}
	
	
	// 获取目标节点ID
	public function GetSourceSlotID():String
	{
		if (sourcePoint == null)
			return Slot.InvalidSlot;

		return sourcePoint.GetSlotID();
	}
	
	
	// 设置目标节点ID
	public function SetTargetNodeID(tNodeID:Int):Void
	{
		if (targetPoint == null)
			targetPoint = new EndPoint(tNodeID);
		else
			targetPoint.SetNodeID(tNodeID);
	}
	
	
	// 获取目标节点ID
	public function GetTargetNodeID():Int
	{
		if (targetPoint == null)
			return Node.InvalidNode;

		return targetPoint.GetNodeID();
	}
	
	
	// 设置目标插槽ID
	public function SetTargetSlotID(tSlotID:String):Void
	{
		if (targetPoint == null)
			targetPoint = new EndPoint(Node.InvalidNode,tSlotID);
		else
			targetPoint.SetSlotID(tSlotID);
	}
	
	
	// 获取目标节点ID
	public function GetTargetSlotID():String
	{
		if (targetPoint == null)
			return Slot.InvalidSlot;

		return targetPoint.GetSlotID();
	}
	
	
	// 获取源Node Slot点
	public function GetSourceEndPoint():EndPoint
	{
		return this.sourcePoint;
	}
	
	
	// 获取目标Node Slot点
	public function GetTargetEndPoint():EndPoint
	{
		return this.targetPoint;
	}
	
	
	// 判定关联是否一致
	public function IsEqual(sNID:Int,sSID:String,tNID:Int,tSID:String):Bool
	{
		if (this.sourcePoint == null || this.targetPoint == null)
			return false;
			
		return ( (sNID == this.sourcePoint.GetNodeID()) && (tNID == this.targetPoint.GetNodeID()) 
		&& (sSID == this.sourcePoint.GetSlotID()) && (tSID == this.sourcePoint.GetSlotID() ) );
	}
	
	
	// 根据输入EndPoint查找所有输出点
	public function IsSourceEndPoint(sNID:Int, sSID:String):Bool
	{
		if (this.sourcePoint == null)
			return false;
			
		return (sNID == this.sourcePoint.GetNodeID()) && (sSID == this.sourcePoint.GetSlotID() );
	}
	
	
}