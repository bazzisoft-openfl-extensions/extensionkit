package extensionkit.event;
import flash.events.Event;


class ExtensionKitTestEvent extends Event
{
    public static inline var TEST_NATIVE = "extensionkit_test_native";
    public static inline var TEST_JNI = "extensionkit_test_jni";

    public var param1String(default, null) : String;
    public var param2Int(default, null) : Int;
    public var param3Float(default, null) : Float;

    public function new(type:String, p1:String, p2:Int, p3:Float)
    {
        super(type, true, true);

        this.param1String = p1;
        this.param2Int = p2;
        this.param3Float = p3;
    }

	public override function clone() : Event
    {
		return new ExtensionKitTestEvent(type, param1String, param2Int, param3Float);
	}

	public override function toString() : String
    {
		return "[ExtensionKitTestEvent type=" + type + " param1String=\"" + param1String + "\" param2Int=" + param2Int + " param3Float=" + param3Float + "]";
	}
}