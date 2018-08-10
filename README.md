# HaxeFlowGraph

基于Haxe的流图库

可编译成C#  C++  JAVA等库，配合编辑器可视化编辑流程逻辑，需要功能模块实现具体功能节点具体实现


BuildCS.hxml 编译成C#工程 

-cp Core/        (设定文件夹路径)

core.NodeBase		(设置代码类（包含包名）)
core.SlotBase
core.SlotId
core.SlotType
core.TaskBase
core.AddNode

-cs CS/FlowGraph	(设定生成为CS工程 工程名FlowGraph)

-js JS/FlowGraph.js	(设定生成为JS文件)


haxe -main Entry --interp 从主入口执行工程
