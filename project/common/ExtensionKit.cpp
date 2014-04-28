
#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include <stdio.h>
#include <stdarg.h>
#include "ExtensionKit.h"


namespace extensionkit
{
    extern AutoGCRoot* g_haxeCallbackForDispatchingEvents;


    extern "C" void DispatchEventToHaxe(const char* eventClassSpec, ...)
    {
        bool foundAllArgs = false;
        value ar = alloc_array(0);

        va_list params;
        va_start(params, eventClassSpec);

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
                    printf("extensionkit::DispatchEventToHaxe() received invalid type %d, aborting.", type);
                    va_end(params);
                    return;
            }
        }

        va_end(params);

        if (g_haxeCallbackForDispatchingEvents != 0)
        {
            val_call2(g_haxeCallbackForDispatchingEvents->get(), alloc_string(eventClassSpec), ar);
        }
    }
}