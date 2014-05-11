#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include <string.h>
#include "ExtensionKit.h"
#include "ExtensionKitPrivate.h"


static void extensionkit_set_haxe_callback_for_dispatching_events(value haxeCallback)
{
    AutoGCRoot* callback = new AutoGCRoot(haxeCallback);
    extensionkit::_private::SetHaxeCallbackForDispatchingEvents(callback);
}
DEFINE_PRIM(extensionkit_set_haxe_callback_for_dispatching_events, 1);


static void extensionkit_trigger_test_event()
{
    extensionkit::_private::TriggerTestEvent();
}
DEFINE_PRIM(extensionkit_trigger_test_event, 0);


static value extensionkit_get_temp_directory()
{
    const char* dir = extensionkit::GetTempDirectory();
    
    if (dir != NULL)
    {
        return alloc_string_len(dir, strlen(dir));
    }
    else
    {
        return alloc_null();
    }
}
DEFINE_PRIM(extensionkit_get_temp_directory, 0);


static value extensionkit_get_private_app_files_directory()
{
    const char* dir = extensionkit::GetPrivateAppFilesDirectory();

    if (dir != NULL)
    {
        return alloc_string_len(dir, strlen(dir));
    }
    else
    {
        return alloc_null();
    }    
}
DEFINE_PRIM(extensionkit_get_private_app_files_directory, 0);


static value extensionkit_get_public_documents_directory()
{
    const char* dir = extensionkit::GetPublicDocumentsDirectory();
    
    if (dir != NULL)
    {
        return alloc_string_len(dir, strlen(dir));
    }
    else
    {
        return alloc_null();
    }
}
DEFINE_PRIM(extensionkit_get_public_documents_directory, 0);


static value extensionkit_create_temporary_file()
{
    const char* tempFile = extensionkit::CreateTemporaryFile(NULL);
    
    if (tempFile != NULL)
    {        
        return alloc_string_len(tempFile, strlen(tempFile));
    }
    else
    {
        return alloc_null();
    }
}
DEFINE_PRIM(extensionkit_create_temporary_file, 0);


extern "C" void extensionkit_main () {

    val_int(0); // Fix Neko init

}
DEFINE_ENTRY_POINT(extensionkit_main);



extern "C" int extensionkit_register_prims () { return 0; }