package core.serialization;
import haxe.io.Bytes;

/**
 * @author confiner 
 * 序列化接口
 */
interface ISerializable 
{
	// 序列化为bytes字节数组
	public function SeriralizeToBytes(bytes:Bytes):Void;
	// 从bytes字节数组反序列化
	public function DeserializeFromBytes(bytes:Bytes):Void;
}