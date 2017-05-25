package extensionkit;

import extensionkit.event.ExtensionKitTestEvent;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.display.Sprite;
import flash.display.Stage;
import haxe.Json;
import lime.system.System;
import openfl.utils.Timer;
import openfl.events.TimerEvent;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

#if android
import lime.system.JNI;
#end


class ExtensionKit
{
    private static var s_initialized:Bool = false;
	private static var s_nextEventDispatcherId:Int = 1;
	private static var s_eventDispatcherMap:Map<Int, IEventDispatcher> = new Map<Int, IEventDispatcher>();

    #if cpp
    private static var extensionkit_set_haxe_callback_for_dispatching_events = null;
    private static var extensionkit_trigger_test_event = null;
    private static var extensionkit_create_temporary_file = null;
    private static var extensionkit_get_temp_directory = null;
    private static var extensionkit_get_private_app_files_directory = null;
    private static var extensionkit_get_public_documents_directory = null;
    #end

    #if android
    private static var extensionkit_set_haxe_callback_for_dispatching_events_jni = null;
    private static var extensionkit_trigger_test_event_jni = null;
    private static var extensionkit_create_temporary_file_jni = null;
    private static var extensionkit_get_temp_directory_jni = null;
    private static var extensionkit_get_private_app_files_directory_jni = null;
    private static var extensionkit_get_public_documents_directory_jni = null;
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
        extensionkit_create_temporary_file = Lib.load("extensionkit", "extensionkit_create_temporary_file", 0);
        extensionkit_get_temp_directory = Lib.load("extensionkit", "extensionkit_get_temp_directory", 0);
        extensionkit_get_private_app_files_directory = Lib.load("extensionkit", "extensionkit_get_private_app_files_directory", 0);
        extensionkit_get_public_documents_directory = Lib.load("extensionkit", "extensionkit_get_public_documents_directory", 0);
        #end

        #if android
        extensionkit_set_haxe_callback_for_dispatching_events_jni = JNI.createStaticMethod("org.haxe.extension.extensionkit._private.ExtensionKit", "SetHaxeCallbackForDispatchingEvents", "(Lorg/haxe/lime/HaxeObject;Ljava/lang/String;)V");
        extensionkit_trigger_test_event_jni = JNI.createStaticMethod("org.haxe.extension.extensionkit._private.ExtensionKit", "TriggerTestEvent", "()V");
        extensionkit_create_temporary_file_jni = JNI.createStaticMethod("org.haxe.extension.extensionkit._private.ExtensionKit", "CreateTemporaryFile", "()Ljava/lang/String;");
        extensionkit_get_temp_directory_jni = JNI.createStaticMethod("org.haxe.extension.extensionkit._private.ExtensionKit", "GetTempDirectory", "()Ljava/lang/String;");
        extensionkit_get_private_app_files_directory_jni = JNI.createStaticMethod("org.haxe.extension.extensionkit._private.ExtensionKit", "GetPrivateAppFilesDirectory", "()Ljava/lang/String;");
        extensionkit_get_public_documents_directory_jni = JNI.createStaticMethod("org.haxe.extension.extensionkit._private.ExtensionKit", "GetPublicDocumentsDirectory", "()Ljava/lang/String;");
        #end

        #if cpp
        extensionkit_set_haxe_callback_for_dispatching_events(CreateAndDispatchEvent);
        #end

        #if android
        extensionkit_set_haxe_callback_for_dispatching_events_jni(ExtensionKit, "CreateAndDispatchEventFromJNI");
        #end
    }
	
	public static function RegisterEventDispatcher(obj:IEventDispatcher) : Int
	{
		var id = s_nextEventDispatcherId++;
		s_eventDispatcherMap.set(id, obj);
		return id;
	}
	
	public static function UnregisterEventDispatcher(eventDispatcherId:Int) : Void
	{
		s_eventDispatcherMap.remove(eventDispatcherId);
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
        CreateAndDispatchEvent(0, "extensionkit.event.ExtensionKitTestEvent", [ExtensionKitTestEvent.TEST_NATIVE, "string parameter", 12345, 1234.5678]);
        #end
    }
    
    public static function CreateTemporaryFile() : String
    {
        #if android
        return extensionkit_create_temporary_file_jni();
        #elseif cpp
        return extensionkit_create_temporary_file();
        #else
        return null;
        #end
    }

    public static function GetTempDirectory() : String
    {
        #if android
        return extensionkit_get_temp_directory_jni();
        #elseif (cpp && mobile)
        return extensionkit_get_temp_directory();
        #elseif !flash
        return VerifyDirectoryExists(System.applicationStorageDirectory);
        #else
        return null;
        #end
    }
    
    public static function GetPrivateAppFilesDirectory() : String
    {
        #if android
        return extensionkit_get_private_app_files_directory_jni();
        #elseif (cpp && mobile)
        return extensionkit_get_private_app_files_directory();
        #elseif !flash
        return VerifyDirectoryExists(System.applicationStorageDirectory);
        #else
        return null;
        #end
    }
    
    public static function GetPublicDocumentsDirectory() : String
    {
        #if android
        return extensionkit_get_public_documents_directory_jni();
        #elseif (cpp && mobile)
        return extensionkit_get_public_documents_directory();
        #elseif !flash
        return VerifyDirectoryExists(System.documentsDirectory);
        #else
        return null;
        #end
    }
    
    //---------------------------------
    // Private Methods
    //---------------------------------
    
    private static function VerifyDirectoryExists(path:String) : String
    {
        #if !flash
        if (!sys.FileSystem.exists(path))
        {
            sys.FileSystem.createDirectory(path);
        }        
        #end
        
        return path;
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
    private static function CreateAndDispatchEvent(eventDispatcherId:Int, eventPackageAndClass:String, args:Array<Dynamic>) : Void
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

		var target:IEventDispatcher = stage;
		if (eventDispatcherId > 0)
		{
			var newtarget:IEventDispatcher = s_eventDispatcherMap.get(eventDispatcherId);
			if (newtarget != null)
			{
				target = newtarget;
			}
		}

		target.dispatchEvent(event);
    }

    private static function CreateAndDispatchEventFromJNI(eventDispatcherId:Int, eventPackageAndClass:String, args:String) : Void
    {
        function dispatcher(e:TimerEvent) {
            CreateAndDispatchEvent(eventDispatcherId, eventPackageAndClass, Json.parse(args));
        }

        var dispatchTimer:Timer = new Timer(50, 1);

        dispatchTimer.addEventListener(TimerEvent.TIMER, dispatcher);
        dispatchTimer.start();
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