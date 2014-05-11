#ifndef EXTENSIONKITIPHONEPRIVATE_H
#define EXTENSIONKITIPHONEPRIVATE_H


namespace extensionkit
{
    namespace iphone
    {
        namespace _private
        {
            const char* GetTempDirectory();
            const char* GetPrivateAppFilesDirectory();
            const char* GetPublicDocumentsDirectory();    
            const char* CreateTemporaryFile(FILE** outFp);
        }
    }
}


#endif