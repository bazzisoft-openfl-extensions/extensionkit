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
    extern "C" int Base64EncodedLength(int byteDataSrcLength);
    extern "C" int Base64Encode(char* base64Dest, const void* byteDataSrc, int byteDataSrcLength);
    extern "C" int Base64DecodedLength(const char* base64Src);
    extern "C" int Base64Decode(void* byteDataDest, const char* base64Src);    
}


#endif