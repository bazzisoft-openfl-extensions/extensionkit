package org.haxe.extension.extensionkit._private;

import java.io.IOException;
import java.util.LinkedList;
import java.util.Queue;

import org.haxe.extension.extensionkit.FileUtils;
import org.haxe.extension.extensionkit.Trace;
import org.haxe.lime.HaxeObject;

import android.content.Intent;
import android.os.Bundle;

import com.google.gson.Gson;


/*
    You can use the Android Extension class in order to hook
    into the Android activity lifecycle. This is not required
    for standard Java code, this is designed for when you need
    deeper integration.

    You can access additional references from the Extension class,
    depending on your needs:

    - Extension.assetManager (android.content.res.AssetManager)
    - Extension.callbackHandler (android.os.Handler)
    - Extension.mainActivity (android.app.Activity)
    - Extension.mainContext (android.content.Context)
    - Extension.mainView (android.view.View)

    You can also make references to static or instance methods
    and properties on Java classes. These classes can be included
    as single files using <java path="to/File.java" /> within your
    project, or use the full Android Library Project format (such
    as this example) in order to include your own AndroidManifest
    data, additional dependencies, etc.

    These are also optional, though this example shows a static
    function for performing a single task, like returning a value
    back to Haxe from Java.
*/
public class ExtensionKit extends org.haxe.extension.Extension
{
    private static class HaxeEventSpec
    {
        public HaxeEventSpec(final int eventDispatcherId, final String eventClassSpec, final Object[] args)
        {
            this.eventDispatcherId = eventDispatcherId;
            this.eventClassSpec = eventClassSpec;
            this.args = args;
                    
        }
        
        public final int eventDispatcherId;
        public final String eventClassSpec;
        public final Object[] args;
    }
    
    private static Queue<HaxeEventSpec> s_queuedEvents = new LinkedList<HaxeEventSpec>(); 
    private static HaxeObject s_haxeCallbackObjectForDispatchingEvents = null;
    private static String s_haxeCallbackFunctionNameForDispatchingEvents = null;

    /**
     * Sets the haxe object/function to be called when a callback event is to be dispatched.
     */
    public static void SetHaxeCallbackForDispatchingEvents(final HaxeObject haxeObject, final String functionNameOnObject)
    {
        s_haxeCallbackObjectForDispatchingEvents = haxeObject;
        s_haxeCallbackFunctionNameForDispatchingEvents = functionNameOnObject;
        
        // See if we have any queued events from before we set our callback
        while (!s_queuedEvents.isEmpty())
        {
            HaxeEventSpec e = s_queuedEvents.remove();
            InvokeHaxeCallbackFunctionForDispatchingEvents(e.eventDispatcherId, e.eventClassSpec, e.args);
        }
    }

    /**
     * Invokes the haxe callback to dispatch the event. Don't use this, use
     * HaxeCallback.DispatchEventToHaxe().
     */
    public static void InvokeHaxeCallbackFunctionForDispatchingEvents(final int eventDispatcherId, final String eventClassSpec, final Object[] args)
    {
        if (s_haxeCallbackObjectForDispatchingEvents == null)
        {
            // ExtensionKit has not yet been initialized from Haxe to provide us a callback,
            // but an extension is already sending us events. Queue them up for resending
            // once we have a callback.
            Trace.Info("ExtensionKit not yet initialized from Haxe; Queuing up event " + eventClassSpec);
            s_queuedEvents.add(new HaxeEventSpec(eventDispatcherId, eventClassSpec, args));
            return;
        }
        
        final String argsJSON = new Gson().toJson(args);

        org.haxe.extension.Extension.callbackHandler.post(new Runnable() {
            @Override
            public void run() {
                s_haxeCallbackObjectForDispatchingEvents.call3(s_haxeCallbackFunctionNameForDispatchingEvents, eventDispatcherId, eventClassSpec, argsJSON);
            }
        });
    }
    
    /**
     * Simulates a event dispatch callback from an extension.
     */
    public static void TriggerTestEvent()
    {
        org.haxe.extension.extensionkit.HaxeCallback.DispatchEventToHaxe("extensionkit.event.ExtensionKitTestEvent", new Object[] {
                                                                             "extensionkit_test_jni",
                                                                             "string parameter from JNI",
                                                                             54321,
                                                                             5678.1234});
    }

    /**
     * Return a directory for temporary files.
     */
    public static String GetTempDirectory()
    {   
        return FileUtils.GetTempDirectory().getAbsolutePath();
    }
    
    /**
     * Return a directory for saving private, persistent app files.
     */
    public static String GetPrivateAppFilesDirectory()
    {
        return FileUtils.GetPrivateAppFilesDirectory().getAbsolutePath();
    }
    
    /**
     * Return a directory for saving shared documents.
     */
    public static String GetPublicDocumentsDirectory()
    {
        return FileUtils.GetPublicDocumentsDirectory().getAbsolutePath();
    }
    
    /**
     * Create an empty temporary file and returns its path.
     */
    
    public static String CreateTemporaryFile()
    {
        try
        {
            return FileUtils.CreateTemporaryFile().getAbsolutePath();
        }
        catch (IOException e)
        {
            return null;
        }        
    }
    
    /**
     * Called when an activity you launched exits, giving you the requestCode
     * you started it with, the resultCode it returned, and any additional data
     * from it.
     */
    public boolean onActivityResult (int requestCode, int resultCode, Intent data)
    {
        return true;
    }

    /**
     * Called when the activity is starting.
     */
    public void onCreate (Bundle savedInstanceState)
    {
    }

    /**
     * Perform any final cleanup before an activity is destroyed.
     */
    public void onDestroy ()
    {
    }

    /**
     * Called as part of the activity lifecycle when an activity is going into
     * the background, but has not (yet) been killed.
     */
    public void onPause ()
    {
    }

    /**
     * Called after {@link #onStop} when the current activity is being
     * re-displayed to the user (the user has navigated back to it).
     */
    public void onRestart ()
    {
    }

    /**
     * Called after {@link #onRestart}, or {@link #onPause}, for your activity
     * to start interacting with the user.
     */
    public void onResume ()
    {
    }

    /**
     * Called after {@link #onCreate} &mdash; or after {@link #onRestart} when
     * the activity had been stopped, but is now again being displayed to the
     * user.
     */
    public void onStart ()
    {
    }

    /**
     * Called when the activity is no longer visible to the user, because
     * another activity has been resumed and is covering this one.
     */
    public void onStop ()
    {
    }
}


