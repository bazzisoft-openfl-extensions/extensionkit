
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
        va_list params;
        va_start(params, eventClassSpec);
		
		_private::InvokeHaxeCallbackFunctionForDispatchingEvents(0, eventClassSpec, params);
		
		va_end(params);
	}
	
	extern "C" void DispatchEventToHaxeInstance(int eventDispatcherId, const char* eventClassSpec, ...)
	{
        va_list params;
        va_start(params, eventClassSpec);
		
		_private::InvokeHaxeCallbackFunctionForDispatchingEvents(eventDispatcherId, eventClassSpec, params);
		
		va_end(params);
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
    
    extern "C" const char* GetTempDirectory()
    {
        #ifdef IPHONE
        
        return iphone::_private::GetTempDirectory();
        
        #else
        
        printf("ExtensionKit::GetTempDirectory() not yet implemented on this platform.\n");
        return NULL;
        
        #endif
    }
    
    extern "C" const char* GetPrivateAppFilesDirectory()
    {
        #ifdef IPHONE
        
        return iphone::_private::GetPrivateAppFilesDirectory();
        
        #else
        
        printf("ExtensionKit::GetPrivateAppFilesDirectory() not yet implemented on this platform.\n");
        return NULL;
        
        #endif
    }
    
    extern "C" const char* GetPublicDocumentsDirectory()
    {
        #ifdef IPHONE
        
        return iphone::_private::GetPublicDocumentsDirectory();
        
        #else
        
        printf("ExtensionKit::GetPublicDocumentsDirectory() not yet implemented on this platform.\n");
        return NULL;
        
        #endif
    }
    
    extern "C" const char* CreateTemporaryFile(FILE** outFp)
    {
        #ifdef IPHONE
        
        return iphone::_private::CreateTemporaryFile(outFp);
        
        #else
        
        printf("ExtensionKit::CreateTemporaryFile() not yet implemented on this platform.\n");
        return NULL;
        
        #endif
    }
}