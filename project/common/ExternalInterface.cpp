#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include "ExtensionKitPrivate.h"


static void extensionkit_set_haxe_callback_for_dispatching_events(value haxeCallback)
{
    AutoGCRoot* callback = new AutoGCRoot(haxeCallback);
    extensionkit::SetHaxeCallbackForDispatchingEvents(callback);
}
DEFINE_PRIM(extensionkit_set_haxe_callback_for_dispatching_events, 1);


static void extensionkit_trigger_test_event()
{
    extensionkit::TriggerTestEvent();
}
DEFINE_PRIM(extensionkit_trigger_test_event, 0);



extern "C" void extensionkit_main () {

    val_int(0); // Fix Neko init

}
DEFINE_ENTRY_POINT(extensionkit_main);



extern "C" int extensionkit_register_prims () { return 0; }