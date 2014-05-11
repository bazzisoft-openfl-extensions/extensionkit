
#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include <stdio.h>
#include <stdarg.h>
#include "ExtensionKit.h"
#include "base64/base64.h"
#include "ExtensionKitPrivate.h"
#include "../iphone/ExtensionKitIPhonePrivate.h"


//
// Common functions called from your C/C++ extension code
//

namespace extensionkit
{
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

        AutoGCRoot* haxeCallback = _private::GetHaxeCallbackForDispatchingEvents();
        if (haxeCallback != NULL)
        {
            val_call2(haxeCallback->get(), alloc_string(eventClassSpec), ar);
        }
    }
    
    extern "C" int Base64EncodedLength(int byteDataSrcLength)
    {
        return Base64encode_len(byteDataSrcLength);
    }    
    
    extern "C" int Base64Encode(char* base64Dest, const void* byteDataSrc, int byteDataSrcLength)
    {
        return Base64encode(base64Dest, (const char*) byteDataSrc, byteDataSrcLength);
    }
    
    extern "C" int Base64DecodedLength(const char* base64Src)
    {
        return Base64decode_len(base64Src);
    }
    
    extern "C" int Base64Decode(void* byteDataDest, const char* base64Src)
    {
        return Base64decode((char*) byteDataDest, base64Src);
    }
    
    extern "C" FILE* CreateTemporaryFile(char* outPath)
    {
        #ifdef IPHONE
        
        return iphone::_private::CreateTemporaryFile(outPath);
        
        #else
        
        printf("ExtensionKit::CreateTemporaryFile() not implemented on this platform.\n");
        return NULL;
        
        #endif
    }
}