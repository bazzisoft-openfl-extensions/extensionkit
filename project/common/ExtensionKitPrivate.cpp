
#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include <stdio.h>
#include <stdarg.h>
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

		void InvokeHaxeCallbackFunctionForDispatchingEvents(int eventDispatcherId, const char* eventClassSpec, va_list params)
		{
			bool foundAllArgs = false;
			value ar = alloc_array(0);

			while (!foundAllArgs)
			{
				int type = va_arg(params, int);
				switch (type)
				{
					case CEND:
						foundAllArgs = true;
						break;

					case CSTRING:
						val_array_push(ar, alloc_string(va_arg(params, char*)));
						break;

					case CINT:
						val_array_push(ar, alloc_int(va_arg(params, int)));
						break;

					case CDOUBLE:
						val_array_push(ar, alloc_float(va_arg(params, double)));
						break;

					default:
						printf("extensionkit::InvokeHaxeCallbackFunctionForDispatchingEvents() received invalid type %d, aborting.\n", type);
						return;
				}
			}

			AutoGCRoot* haxeCallback = _private::GetHaxeCallbackForDispatchingEvents();
			if (haxeCallback != NULL)
			{
				val_call3(haxeCallback->get(), alloc_int(eventDispatcherId), alloc_string(eventClassSpec), ar);
			}
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