package core.graph;
/**
 * ...
 * @author MibuWolf
 */
class EndPointPools 
{

	private static var instance:EndPointPools;
	
	private var pools:List<EndPoint>;
	
	public function new() 
	{
		
	}
	
	public static function GetInstance():EndPointPools
	{
		if (instance == null)
		{
			instance = new EndPointPools();
			instance.pools = new List<EndPoint>();
		}
		return instance;
	}
	
	
	
	// 获取EndPoint
	public function GetEndPoint(nodeID:Int = -1, slotID:String = ""):EndPoint
	{
		if (pools.isEmpty())
			return new EndPoint(nodeID, slotID);
			
		var endPoint:EndPoint = pools.pop();
		
		endPoint.SetNodeID(nodeID);
		endPoint.SetSlotID(slotID);
		
		return endPoint;
	}
	
	
	
	// 释放EndPoint
	public function ReleaseEndPoint(endPoint:EndPoint):Void
	{
		if (endPoint == null)
			return;
			
		pools.push(endPoint);
	}
}