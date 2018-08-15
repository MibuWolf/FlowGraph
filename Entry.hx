package;

/**
 * ...
 * @author confiner
 * @see 程序入口
 */
 import core.node.Node;
 import core.node.event.GraphStartNode;
 import core.node.logic.IfNode;
 import core.node.reflect.MethodNode;
 import core.node.reflect.TriggerNode;
 import core.serialization.laybox.LayBoxGraphData;
 import core.serialization.laybox.LayBoxNodeData;
 import core.slot.Slot;
 import core.graph.EndPoint;
 import haxe.Json;
 import reflectclass.MethodInfo;
 import reflectclass.ReflectHelper;
 import test.Student;
 import test.StudentMgr;
 import test.TestOutPut;
 import core.graph.Graph;
 import core.slot.Slot.SlotType;
 import core.graphmanager.GraphManager;
class Entry 
{
	public static function main() :Void
	{
		// 测试Graph
		
		StudentMgr.GetInstance().ReflectToGraph();
		TestOutPut.GetInstance().ReflectToGraph();
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		var graph:Graph = new Graph(1);
		GraphManager.GetInstance().AddGraph(graph);
		var add1:MethodNode = new MethodNode(graph);
		add1.Initialize(1, NodeType.METHOD, "AddStudent", "StudentMgr");
		add1.Initialization(ReflectHelper.GetInstance().GetClassInfo("StudentMgr").GetMethod("AddStudent"));
		graph.AddNode(add1);
		
		var add2:MethodNode = new MethodNode(graph);
		add2.Initialize(2, NodeType.METHOD, "AddStudent", "StudentMgr");
		add2.Initialization(ReflectHelper.GetInstance().GetClassInfo("StudentMgr").GetMethod("AddStudent"));
		graph.AddNode(add2);
		
		var add7:MethodNode = new MethodNode(graph);
		add7.Initialize(7, NodeType.METHOD, "GetStudent1Age", "StudentMgr");
		add7.Initialization(ReflectHelper.GetInstance().GetClassInfo("StudentMgr").GetMethod("GetStudent1Age"));
		graph.AddNode(add7);
		
		var add8:MethodNode = new MethodNode(graph);
		add8.Initialize(8, NodeType.METHOD, "GetStudent2Age", "StudentMgr");
		add8.Initialization(ReflectHelper.GetInstance().GetClassInfo("StudentMgr").GetMethod("GetStudent2Age"));
		graph.AddNode(add8);
		
		var com:MethodNode = new MethodNode(graph);
		com.Initialize(3, NodeType.METHOD, "Compare", "StudentMgr");
		com.Initialization(ReflectHelper.GetInstance().GetClassInfo("StudentMgr").GetMethod("Compare"));
		graph.AddNode(com);
		
		var ifNode:IfNode = new IfNode(graph);
		ifNode.Initialize(4, NodeType.LOGIC, "IF", "Logic");
		graph.AddNode(ifNode);
		
		var output:MethodNode = new MethodNode(graph);
		output.Initialization(ReflectHelper.GetInstance().GetClassInfo("TestOutPut").GetMethod("Output"));
		output.Initialize(5, NodeType.METHOD, "Output", "TestOutPut");
		graph.AddNode(output);
		
		var triggerNode:TriggerNode = new TriggerNode(graph);
		triggerNode.Initialize(6, NodeType.METHOD, "OnTrigger", "StudentMgr");
		triggerNode.Initialization(ReflectHelper.GetInstance().GetClassInfo("StudentMgr").GetCallBack("OnTrigger"));
		graph.AddNode(triggerNode);
		
		var star:GraphStartNode = new GraphStartNode(graph);
		star.Initialize(0, NodeType.LOGIC, "start", "start");
		graph.AddNode(star);
		
		
		graph.AddConnection(0, "Out", 1, "In");
		graph.AddConnection(1, "Out", 2, "In");
		graph.AddConnection(7, "Result", 1, "age");
		graph.AddConnection(8, "Result", 2, "age");
		graph.AddConnection(1, "Result", 3, "ida");
		graph.AddConnection(2, "Result", 3, "idb");
		graph.AddConnection(2, "Out", 3, "In");
		graph.AddConnection(3, "Out", 4, "In");
		graph.AddConnection(3, "Result", 4, "Condition");
		graph.AddConnection(4, "False", 5, "In");
		graph.AddConnection(6,"Out",5,"In");

		star.OnTrigger();
		
		/*StudentMgr.GetInstance().OnTrigger(1);
		
		var layboxNode:LayBoxNodeData = new LayBoxNodeData();
		var str:String = LayBoxNodeData.MethodInfoToJson(ReflectHelper.GetInstance().GetClassInfo("StudentMgr").GetMethod("Compare"));
		
		var newMethod:MethodInfo = LayBoxNodeData.MethodInfoFromJson(str);
		var strnew:String = LayBoxNodeData.MethodInfoToJson(newMethod);
		

		//trace(strnew);
		
		
		
		
		
		**/
	
		var testGraphData = { name:"testName", "0":{name:"GetTest",category:"StudentMgr",next:{Out:[1]} },"1":{name:"Log",category:"TestOutPut",input:{Value:{node_id:0,pin:"Value"}} }
		};
		
		//var testGraphData = {name:"string"};
		var strJosn:String = Json.stringify(testGraphData);
	
		var graph1:Graph = LayBoxGraphData.GetInstance().GraphFormJson(strJosn);
		//trace(graph1);
		
		var star:GraphStartNode = new GraphStartNode(graph1);
		star.Initialize(10, NodeType.LOGIC, "start", "start");
		graph1.AddNode(star);
		
		graph1.AddConnection(10, "Out", 0, "In");
		
		//trace(graph1);
		star.OnTrigger();
		return;
		// 测试生成项目
		//trace("Hello World Hlll");
		
		// 测试反射
		//var func = Reflect.callMethod(Student, Reflect.field(Student, "GetAge"), []);
		//var age:Int = func;
		//trace(age);
		
	//	var test:Student = new Student("asd",1);
	//	test.SetAge(1000);
		
	//	ReflectHelper.GetInstance().InitializationSingleClass("Student", test);
	//	var age:Int = 1;
	//	age = ReflectHelper.GetInstance().CallSingleMethod("Student", "GetAge", [] );
		
	//	if (!Reflect.hasField(test, "GetAge"))
	//		{
	//			trace("==============44444444444");
	//		}
			
		
		//var func = Reflect.callMethod(test, Reflect.field(test, "GetAge"), []);
		//var age:Int = func;
	//	trace(age);
		
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