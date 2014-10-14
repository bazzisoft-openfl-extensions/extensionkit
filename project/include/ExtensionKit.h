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

    // Creates an eventClassSpec class in Haxe and dispatches it to the OpenFL stage
    extern "C" void DispatchEventToHaxe(const char* eventClassSpec, ...);
	
	// Creates an eventClassSpec class in Haxe and dispatches it to the Haxe IEventDispatcher
	// instance registered with ExtensionKit.RegisterEventDispatcher() with the given eventDispatcherId.
	extern "C" void DispatchEventToHaxeInstance(int eventDispatcherId, const char* eventClassSpec, ...);
    
    // Return Base64 encoded length of the specified byte buffer size
    extern "C" int Base64EncodedLength(int byteDataSrcLength);
    // Base64 encodes byteDataSrc to base64Dest, which must be at least Base64EncodedLength(byteDataSrcLength) bytes long
    extern "C" int Base64Encode(char* base64Dest, const void* byteDataSrc, int byteDataSrcLength);
    // Determines the byte buffer length given a Base64 encoded buffer
    extern "C" int Base64DecodedLength(const char* base64Src);
    // Base64 decodes base64Src into byteDataDest, which must be at least Base64DecodedLength(base64Src) bytes long
    extern "C" int Base64Decode(void* byteDataDest, const char* base64Src);    

    // Returns the directory for storing temporary files
    extern "C" const char* GetTempDirectory();
    // Returns the directory for storing private app files
    extern "C" const char* GetPrivateAppFilesDirectory();
    // Returns the directory for storing public shared documents
    extern "C" const char* GetPublicDocumentsDirectory();    
    // Creates a temporary file and returns its path. If outFP is not NULL, reutrns an open file pointer.
    extern "C" const char* CreateTemporaryFile(FILE** outFp);
}


#endif