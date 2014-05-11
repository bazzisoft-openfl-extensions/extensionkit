#ifndef EXTENSIONKITPRIVATE_H
#define EXTENSIONKITPRIVATE_H


class AutoGCRoot;


//
// Functions internal to ExtensionKit.hx
//

namespace extensionkit
{
    namespace _private 
    {        
        AutoGCRoot* GetHaxeCallbackForDispatchingEvents();
        void SetHaxeCallbackForDispatchingEvents(AutoGCRoot* haxeCallback);
        void TriggerTestEvent();
    }
}


#endif