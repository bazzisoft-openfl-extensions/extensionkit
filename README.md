ExtensionKit
============

### A library of common functionality designed for use by other Native & Java OpenFL extensions. 

- ##### Dispatching events from C++ or Java code to the OpenFL stage, or an IEventDispatcher instance

    - Provides a unified interface for triggering an OpenFL event from C++ or Java code via a single function call, saving some boilerplate.

    - Overcomes a JNI limitation of 4 parameters of basic types in HaxeObject method calls. Achieved by internally JSON-encoding & decoding the parameters, so that passing nested Array & Mapping types as event parameters should work.


- ##### Temporarily disabling the Android BACK button from Java code

    - Say an extension launches a different view or external activity. The user then cancels that activity with the Android BACK button. Occasionally that button press propagates into the OpenFL app and closes it as well.

    - A workaround for this is to tempoarily disable the BACK button before launching the said view or activity. Then, reenable the BACK button when onResume() is called. See example below.


- ##### Misc common functionality for extensions

    - Temporary files, determining standard directories, encodings, image manipulation, etc.
 

Todo
----

- The above approach for calling back from Native/Java code to Haxe is limited to dispatching events only. It might be worth generalizing to arbitrary callbacks so that CFFI and JNI callbacks can be invoked in a consistent manner and without parameter limitations.

    - For CFFI, automatically wrap the callback with `AutoGCRoot` & automatically allocate CFFI values for parameters when callback is invoked. Provide support for pre-existing CFFI values and/or arrays & structs.

    - For JNI, wrap a Haxe function object in a temporary class with a Call() method and pass that along as the HaxeObject parameter through the JNI. Use internal JSON-encoding/decoding when invoking the callback to overcome parameter limitations.
 
    - Another alternative is to use the current RegisterEventDispatcher() mechanism to register arbitrary Haxe instances, and then specify the method to call on that instance from the native code's DispatchEventToHaxeInstance() instead of the event class to create and dispatch. 


Dependencies
------------
None.


Installation
------------

    git clone https://github.com/bazzisoft-openfl-extensions/extensionkit
    lime rebuild extensionkit [linux|windows|mac|android|ios]


Usage - Dispatching Stage Events + Calling Helper Functions
-----------------------------------------------------------

### Your Extension's `include.xml`

    <include path="/path/to/extensionkit" />


### Your Extension's Haxe Class
    
    class YourExtension
    {
        public static function Initialize() : Void
        {
            ExtensionKit.Initialize();
            ...
        }

        ...
    }


### Your Application's Main Class

    class Main extends Sprite
    {
    	public function new()
        {
    		super();
    
            YourExtension.Initialize();

            ...
        }
    }


### Your Extension's Native C++/Objective-C Code

    // In project/Build.xml, add:
    // <compilerflag value="-I../../extensionkit/project/include"/>

    #include "ExtensionKit.h"

    void YourNativeFunction()
    {
        // Dispatch event to OpenFL stage
        extensionkit::DispatchEventToHaxe(
            "extensionkit.event.ExtensionKitTestEvent",          // event package & class 
            extensionkit::CSTRING,  "extensionkit_test_native",  // 1st param: event type (string)
            extensionkit::CSTRING,  "string parameter",          // 2nd param: C string
            extensionkit::CINT,     12345,                       // 3nd param: C int
            extensionkit::CDOUBLE,  1234.5678,                   // 4th param: C double
            extensionkit::CEND);                                 // End of params

        ...        

        // Image manipulation - iOS only, include "ExtensionKitIPhone.h"
        UIImage* rotated = extensionkit::iphone::RotateUIImageToOrientationUp(srcImage);
    }


### Your Extension's Java Code

    // In dependencies/android/project.properties, add:
    // android.library.reference.2=../extensionkit

    import org.haxe.extension.extensionkit.HaxeCallback;
    import org.haxe.extension.extensionkit.ImageUtils;

    public class YourJavaExtension
    {
        public static void TriggerTestEvent()
        {
            // Dispatch event to OpenFL stage
            HaxeCallback.DispatchEventToHaxe(
                "extensionkit.event.ExtensionKitTestEvent",     // event package & class 
                new Object[] {
                    "extensionkit_test_jni",                    // 1st param: event type (string)
                    "string parameter from JNI",                // 2nd param: any JSON-serializable type
                    54321,                                      // ...
                    5678.1234});

            ...

            // Image manpulation
            File imageFile = new File("/path/to/image");
            Bitmap bitmap = ImageUtils.LoadBitmap(imageFile);
            bitmap = ImageUtils.ResizeBitmap(bitmap, 250, 200);
            ImageUtils.SaveBitmapAsJPEG(bitmap, imageFile, 0.9f);          
        }

        public static void LaunchChildActivity()
        {
            MobileDevice.DisableBackButton();

            // launch activity
            ...
        }

        @Override
        public void onResume()
        {
            MobileDevice.EnableBackButton();
        }     
    }



Usage - Dispatching Events to Arbitrary IEventDispatcher Instances
------------------------------------------------------------------

### Your Extension's IEventDispatcher Class
_Do this after initialization of your extension as per above!_
    
    class YourEventDispatcher extends EventDispatcher
    {
		public var eventDispatcherId(default, null):Int = 0;

		public function new()
		{
			super();
			
			this.eventDispatcherId = ExtensionKit.RegisterEventDispatcher(this);
			
			// Notify Native/Java code of the eventDispatcherId for this instance 
			...
		}

		public function Destroy()
		{
			if (0 == this.eventDispatcherId)
			{
				return;
			}

			// Notify Native/Java code to release any data
			...

			ExtensionKit.UnregisterEventDispatcher(this.eventDispatcherId);
			this.eventDispatcherId = 0;
		}	

		...
    }


### Your Extension's Native C++/Objective-C Code

    void YourNativeFunction(int eventDispatcherId)
    {
        // Dispatch event to IEventDispatcher instance
        extensionkit::DispatchEventToHaxeInstance(
            eventDispatcherId,
            "extensionkit.event.ExtensionKitTestEvent",          // event package & class 
            extensionkit::CSTRING,  "extensionkit_test_native",  // 1st param: event type (string)
            extensionkit::CSTRING,  "string parameter",          // 2nd param: C string
            extensionkit::CINT,     12345,                       // 3nd param: C int
            extensionkit::CDOUBLE,  1234.5678,                   // 4th param: C double
            extensionkit::CEND);                                 // End of params
    }


### Your Extension's Java Code

    public class YourJavaExtension
    {
        public static void TriggerTestEvent(int eventDispatcherId)
        {
            // Dispatch event to IEventDispatcher instance
            HaxeCallback.DispatchEventToHaxeInstance(
				eventDispatcherId,
                "extensionkit.event.ExtensionKitTestEvent",     // event package & class 
                new Object[] {
                    "extensionkit_test_jni",                    // 1st param: event type (string)
                    "string parameter from JNI",                // 2nd param: any JSON-serializable type
                    54321,                                      // ...
                    5678.1234});
        }
    }
 