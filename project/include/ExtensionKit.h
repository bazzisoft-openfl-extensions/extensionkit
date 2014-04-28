#ifndef EXTENSIONKIT_H
#define EXTENSIONKIT_H


namespace extensionkit
{
    enum
    {
        CEND,
        CSTRING,
        CINT,
        CDOUBLE
    };


    extern "C" void DispatchEventToHaxe(const char* eventClassSpec, ...);
}


#endif