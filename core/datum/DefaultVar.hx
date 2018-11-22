package core.datum;

/**
 * ...
 * @author ...
 */
class DefaultVar 
{
	public var name:String;
	
	public var type:String;
	
	public var defaultValue:Any;
	
	public function new(name:String, type:String, dvalue:Any) 
	{
		this.name = name;
		this.type = type;
		this.defaultValue = dvalue;
	}
	
}