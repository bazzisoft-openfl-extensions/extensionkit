ExtensionKit
============

This extension provides functionality for other extensions to use for achieving common functionality. Currently this includes:

- Dispatching an event from Native or Java code to the OpenFL stage.
- Temporarily disabling the BACK button. Useful for preventing our app
  from closing when returning from a launched child activity in Android 
  (sometimes a BACK press is propagated to our app). 


Dependencies
------------
None.

Installation
------------

    git clone https://github.com/bazzisoft-openfl-extensions/extensionkit
    lime rebuild extensionkit [linux|windows|mac|android|ios]


Usage
-----

### project.xml

    <include path="/path/to/extensionkit-0.1" />


### Haxe
    
    class Main extends Sprite
    {
    	public function new()
        {
    		super();
    
            ExtensionKit.Initialize();

            ...
        }
    }


### Native C++/Objective-C

    // In project/Build.xml, add:
    // <compilerflag value="-I../../extensionkit-0.1/project/include"/>

    #include "ExtensionKit.h"

    void MyNativeFunction()
    {
        extensionkit::DispatchEventToHaxe(
            "extensionkit.event.ExtensionKitTestEvent",          // event package & class 
            extensionkit::CSTRING,  "extensionkit_test_native",  // 1st param: event type (string)
            extensionkit::CSTRING,  "string parameter",          // 2nd param: string
            extensionkit::CINT,     12345,                       // 3nd param: C int
            extensionkit::CDOUBLE,  1234.5678,                   // 4th param: C double
            extensionkit::CEND);                                 // End of params
    }


### Java

    // In dependencies/android/project.properties, add:
    // android.library.reference.2=../extensionkit

    import org.haxe.extension.extensionkit.HaxeCallback;

    public class MyClass
    {
        public static void TriggerTestEvent()
        {
            HaxeCallback.DispatchEventToHaxe(
                "extensionkit.event.ExtensionKitTestEvent",     // event package & class 
                new Object[] {
                    "extensionkit_test_jni",                    // 1st param: event type (string)
                    "string parameter from JNI",                // 2nd param: any JSON-serializable type
                    54321,                                      // ...
                    5678.1234});            
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