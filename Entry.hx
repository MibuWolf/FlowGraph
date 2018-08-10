package;

/**
 * ...
 * @author confiner
 * @see 程序入口
 */
 import core.node.Node;
 import core.slot.Slot;
 import core.graph.EndPoint;
 import haxe.Json;
 import reflectclass.ReflectHelper;
 import test.Student;
 import core.graph.Graph;
 import core.slot.Slot.SlotType;
 
class Entry 
{
	public static function main() :Void
	{
		// 测试生成项目
		//trace("Hello World Hlll");
		
		// 测试反射
		//var func = Reflect.callMethod(Student, Reflect.field(Student, "GetAge"), []);
		//var age:Int = func;
		//trace(age);
		
		var test:Student = new Student("asd",1);
		test.SetAge(1000);
		
		ReflectHelper.GetInstance().InitializationSingleClass("Student", test);
		var age:Int = 1;
		age = ReflectHelper.GetInstance().CallSingleMethod("Student", "GetAge", [] );
		
		if (!Reflect.hasField(test, "GetAge"))
			{
				trace("==============44444444444");
			}
			
		
		//var func = Reflect.callMethod(test, Reflect.field(test, "GetAge"), []);
		//var age:Int = func;
		trace(age);
		
		//var st:Student = new Student();
		//var fc = Reflect.callMethod(st, Reflect.field(st, "GetName"), []);
		//var name = fc;
		//trace(name);
		
		
		// 测试二进制
		//var bytes:Bytes = Bytes.alloc(8);
		//bytes.setInt32(0, 23);
		//bytes.setFloat(4, 12.03);
		//var testInt:Int = bytes.getInt32(0);
		//var testFloat = bytes.getFloat(4);
		//trace("testInt : " + testInt + "  testFloat: " + testFloat);
		
		// 测试序列化
		//var stud:Student = new Student("zhangsan", 21);
		//var ser:String = Serializer.run(stud);
		//var st:Student = Unserializer.run(ser);
		//trace("string: " + ser +  "   name: " + st.GetName() +  " age:" + st.GetAge());
		
		// 测试json序列化
		//changeString(stud);
		//var s:String = Json.stringify(stud);
		//trace("object to json: " + s);
		//var student:Student = haxe.Json.parse(s);
		//trace(student.GetName());
		
		// 测试引用
		//var str:String = "hello";
		//changeString(${str});
		//trace(str);
		
		//var slot:Slot = new Slot(10, SlotType.DataIn, "Out");
		//var slotStr:String = Json.stringify(slot);
		//trace("object to json: " + slotStr);
		//var sl:Slot = Json.parse(slotStr);
		//trace("slotId: " + sl.GetSlotId() + "  slotName: " + sl.GetSlotName());
	
		// 测试get/set方法
		//var node:Node = new Node();
		//node.type = "21";
		//var nStr:String = Json.stringify(node);
		//trace("node to json: " + node.type);
		
		// 测试字符串
		//var t1:String = "Hello";
		//var t2:String = "Hello";
		//var b:Bool = t1 == t2;
		//trace(b);
		
		//var slot:Slot = new Slot(21, SlotType.ExecutionIn);
		//var json:String = slot.SerializeToJson();
		//trace("seriralze json: " + json);
		
		//var st:Slot = new Slot(0, SlotType.None);
		//st.DeserializeFromJson(json);
		//trace("slotId ->" + st.slotId + " slotType-> " + st.slotType);
		
		// 测试map
		var map:Map<String, String> = new Map<String, String>();
		map["1"] = "Hello";
		map["2"] = "World";
		for (key in map.keys())
		{
			trace("key: " + key);
			trace("value: " + map[key]);
			//trace("--->" + Json.stringify({key : map[key]}));
		}
		trace(Json.stringify(map));
		
		var graph:Graph = new Graph(1);
		var dataSlotIn:Slot = new Slot();
		dataSlotIn.Initialize("test1", SlotType.DataIn);
		
		var actionSlotIn:Slot = new Slot();
		actionSlotIn.Initialize("test2", SlotType.ExecutionIn);
		
		var dataSlotOut:Slot = new Slot();
		dataSlotOut.Initialize("test3", SlotType.DataOut);
		
		var actionSlotOut:Slot = new Slot();
		actionSlotOut.Initialize("test4", SlotType.ExecutionOut);
		
		var actionNode:Node = new Node(graph);
		actionNode.Initialize(1, NodeType.NORMAL,"First Node", "Action Node");
		actionNode.AddSlot(actionSlotOut);
		actionNode.AddSlot(dataSlotIn);
		actionNode.AddSlot(actionSlotIn);
		
		var dataNode:Node = new Node(graph);
		dataNode.Initialize(2, NodeType.NORMAL, "Second Node", "Data Node");
		dataNode.AddSlot(dataSlotOut);
		
		var node3:Node = new Node(graph);
		node3.Initialize(3, NodeType.NORMAL, "Third Node", "Action Node");
		node3.AddSlot(dataSlotIn);
		node3.AddSlot(actionSlotOut);
		node3.AddSlot(actionSlotIn);
		
		var node4:Node = new Node(graph);
		node4.Initialize(4, NodeType.NORMAL, "Forth Node", "Action Node");
		node4.AddSlot(actionSlotIn);
		

		graph.AddNode(actionNode);
		graph.AddNode(dataNode);
		graph.AddNode(node3);
		graph.AddNode(node4);
		
		var ep1:EndPoint = new EndPoint(actionNode.GetNodeID(), actionSlotOut.slotId);
		var ep2:EndPoint = new EndPoint(dataNode.GetNodeID(), dataSlotOut.slotId);
		var ep3:EndPoint = new EndPoint(node3.GetNodeID(), actionSlotIn.slotId);
		var ep4:EndPoint = new EndPoint(node3.GetNodeID(), dataSlotIn.slotId);
		var ep5:EndPoint = new EndPoint(node3.GetNodeID(), actionSlotOut.slotId);
		var ep6:EndPoint = new EndPoint(node4.GetNodeID(), actionSlotIn.slotId);
		
	
		graph.AddConnection(ep1.GetNodeID(), ep1.GetSlotID(), ep3.GetNodeID(), ep3.GetSlotID());
		
		var aaa:Any = false;

		if(aaa)
			trace(aaa);

	}
	
	public static function changeString(stu:Student):Void
	{
		stu.SetAge(1000);
	}
}