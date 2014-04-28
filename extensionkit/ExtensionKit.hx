package extensionkit;
import extensionkit.event.ExtensionKitTestEvent;
import flash.events.Event;
import flash.display.Sprite;
import flash.display.Stage;
import haxe.Json;


#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

#if (android && openfl)
import openfl.utils.JNI;
#end


class ExtensionKit
{
    private static var s_initialized:Bool = false;

    #if cpp
    private static var extensionkit_set_haxe_callback_for_dispatching_events = null;
    private static var extensionkit_trigger_test_event = null;
    #end

    #if android
    private static var extensionkit_set_haxe_callback_for_dispatching_events_jni = null;
    private static var extensionkit_trigger_test_event_jni = null;
    #end

    public static var stage(get, never) : Stage;

    public static function Initialize() : Void
    {
        if (s_initialized)
        {
            return;
        }

        s_initialized = true;

        #if cpp
        extensionkit_set_haxe_callback_for_dispatching_events = Lib.load("extensionkit", "extensionkit_set_haxe_callback_for_dispatching_events", 1);
        extensionkit_trigger_test_event = Lib.load("extensionkit", "extensionkit_trigger_test_event", 0);
        #end

        #if android
        extensionkit_set_haxe_callback_for_dispatching_events_jni = JNI.createStaticMethod("org.haxe.extension.extensionkit._private.ExtensionKit", "SetHaxeCallbackForDispatchingEvents", "(Lorg/haxe/lime/HaxeObject;Ljava/lang/String;)V");
        extensionkit_trigger_test_event_jni = JNI.createStaticMethod("org.haxe.extension.extensionkit._private.ExtensionKit", "TriggerTestEvent", "()V");
        #end

        #if cpp
        extensionkit_set_haxe_callback_for_dispatching_events(CreateAndDispatchEvent);
        #end

        #if android
        extensionkit_set_haxe_callback_for_dispatching_events_jni(ExtensionKit, "CreateAndDispatchEventFromJNI");
        #end
    }

    public static function TriggerTestEvent() : Void
    {
        #if android
        // Add second listener as android will send event via both JNI and native code
        stage.addEventListener(ExtensionKitTestEvent.TEST_JNI, TraceReceivedTestEvent);
        extensionkit_trigger_test_event_jni();
        #end

        stage.addEventListener(ExtensionKitTestEvent.TEST_NATIVE, TraceReceivedTestEvent);
        #if cpp
        extensionkit_trigger_test_event();
        #else
        // Just fake it for flash
        CreateAndDispatchEvent("extensionkit.event.ExtensionKitTestEvent", [ExtensionKitTestEvent.TEST_NATIVE, "string parameter", 12345, 1234.5678]);
        #end
    }

    private static function TraceReceivedTestEvent(e:ExtensionKitTestEvent) : Void
    {
        trace(e);
        stage.removeEventListener(e.type, TraceReceivedTestEvent);
    }

    /**
     * Creates an event object from the specific package & class spec, and constructor
     * arguments. Then, dispatches the event on the stage.
     */
    private static function CreateAndDispatchEvent(eventPackageAndClass:String, args:Array<Dynamic>) : Void
    {
        //TraceEvent(eventPackageAndClass, args);

        var eventClass = Type.resolveClass(eventPackageAndClass);
        if (eventClass == null)
        {
            trace("[ERROR] Unable to find event class '" + eventPackageAndClass + "'");
            return;
        }

        var event = Type.createInstance(eventClass, args);
        if (event == null)
        {
            trace("[ERROR] Unable to instantiate event class '" + eventPackageAndClass + "'");
            return;
        }

        stage.dispatchEvent(event);
    }

    private static function CreateAndDispatchEventFromJNI(eventPackageAndClass:String, args:String) : Void
    {
        CreateAndDispatchEvent(eventPackageAndClass, Json.parse(args));
    }

    private static function TraceEvent(eventPackageAndClass:String, args:Array<Dynamic>) : Void
    {
        var sb:StringBuf = new StringBuf();
        var a = [];
        sb.add("Dispatching event ");
        sb.add(eventPackageAndClass);
        sb.add("(");
        for (p in args)
        {
            if (Std.is(p, String))
            {
                a.push("\"" + p + "\"");
            }
            else
            {
                a.push(p);
            }
        }
        sb.add(a.join(", "));
        sb.add(")");
        trace(sb.toString());
    }

    private static function get_stage() : Stage
    {
        return flash.Lib.current.stage;
    }
}