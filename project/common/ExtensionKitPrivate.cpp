
#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include "ExtensionKitPrivate.h"
#include "ExtensionKit.h"


//
// Functions internal to ExtensionKit.hx
//

static AutoGCRoot* g_haxeCallbackForDispatchingEvents = NULL;


namespace extensionkit
{
    namespace _private
    {
        AutoGCRoot* GetHaxeCallbackForDispatchingEvents()
        {
            return g_haxeCallbackForDispatchingEvents;
        }
        
        
        void SetHaxeCallbackForDispatchingEvents(AutoGCRoot* haxeCallback)
        {
            if (g_haxeCallbackForDispatchingEvents)
            {
                delete g_haxeCallbackForDispatchingEvents;
            }

            g_haxeCallbackForDispatchingEvents = haxeCallback;
        }


        void TriggerTestEvent()
        {
            DispatchEventToHaxe("extensionkit.event.ExtensionKitTestEvent",
                                CSTRING, "extensionkit_test_native",
                                CSTRING, "string parameter",
                                CINT, 12345,
                                CDOUBLE, 1234.5678,
                                CEND);
        }
    }
}