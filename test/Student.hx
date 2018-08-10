package test;

/**
 * ...
 * @author ...
 */
import haxe.Serializer;
import haxe.Unserializer;

class Student 
{

	private var _name:String;
	private var _age:Int;
	
	//public function new() 
	//{
	//	this._name = "kkk";
	//}
	
	public function new(name:String, age:Int)
	{
		_name = name;
		_age = age;
	}
	
	public function GetName(a:String):String
	{
		return this._name;
	}
	
	public function GetAge():Int
	{
		return this._age;
	}
	
	public function SetAge(age:Int):Void
	{
		this._age = age;
	}
	
	@:keep
	 function hxSerialize(s:Serializer) 
	 {
		s.serialize(this._name);
		s.serialize(this._age);
	 }

	@:keep
	 function hxUnserialize(u:Unserializer) 
	 {
		this._name = u.unserialize();
		this._age = u.unserialize();
	 }
	
}