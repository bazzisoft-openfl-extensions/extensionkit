#ifndef EXTENSIONKITPRIVATE_H
#define EXTENSIONKITPRIVATE_H


class AutoGCRoot;


namespace extensionkit
{
    void SetHaxeCallbackForDispatchingEvents(AutoGCRoot* haxeCallback);
    void TriggerTestEvent();
}


#endif