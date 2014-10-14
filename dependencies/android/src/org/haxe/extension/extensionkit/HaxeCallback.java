package org.haxe.extension.extensionkit;

import org.haxe.extension.extensionkit._private.ExtensionKit;


public class HaxeCallback
{        
    /**
     * Call this from your native code to trigger an OpenFL event
     * on the stage object.
     * 
     * @param eventClassSpec The haxe package & name of the event class to instantiate, eg
     *      "com.foo.MyEvent". Note the event class must be imported somewhere in Haxe code
     *      else it won't work.
     * @param args Arguments to the constructor of the event class, must be JSON serializable.
     */
    public static void DispatchEventToHaxe(final String eventClassSpec, final Object[] args)
    {
        ExtensionKit.InvokeHaxeCallbackFunctionForDispatchingEvents(0, eventClassSpec, args);
    }
    
    /**
     * Call this from your native code to trigger an OpenFL event
     * on an object registered in Haxe with ExtensionKit.RegisterEventDispatcher().
     *
     * @param eventDispatcherId The ID returned by ExtensionKit.RegisterEventDispatcher()
     *      when you registered your class instance.
     * @param eventClassSpec The haxe package & name of the event class to instantiate, eg
     *      "com.foo.MyEvent". Note the event class must be imported somewhere in Haxe code
     *      else it won't work.
     * @param args Arguments to the constructor of the event class, must be JSON serializable.
     */
    public static void DispatchEventToHaxeInstance(final int eventDispatcherId, final String eventClassSpec, final Object[] args)
    {
        ExtensionKit.InvokeHaxeCallbackFunctionForDispatchingEvents(eventDispatcherId, eventClassSpec, args);
    }        
}
