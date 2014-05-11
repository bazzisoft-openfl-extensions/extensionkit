#include <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <stdio.h>
#include <stdlib.h>


static char g_filePathBuffer[2048];


namespace extensionkit
{
    namespace iphone
    {
        namespace _private
        {
            const char* VerifyDirectoryExistsAndReturnPath(NSString* path)
            {
                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil])
                    {
                        return NULL;
                    }
                }
                
                [path getCString:g_filePathBuffer maxLength:sizeof(g_filePathBuffer)/sizeof(*g_filePathBuffer) encoding:NSUTF8StringEncoding];
                return g_filePathBuffer;
            }
            
            const char* GetTempDirectory()
            {
                NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                return VerifyDirectoryExistsAndReturnPath(path);
            }
            
            const char* GetPrivateAppFilesDirectory()
            {
                NSString* path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                return VerifyDirectoryExistsAndReturnPath(path);
            }
            
            const char* GetPublicDocumentsDirectory()
            {
                NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                return VerifyDirectoryExistsAndReturnPath(path);
            }
            
            const char* CreateTemporaryFile(FILE** outFp)
            {
                NSString* tempFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"extensionkit.XXXXXX"];
                strcpy(g_filePathBuffer, [tempFileTemplate fileSystemRepresentation]);
                int fileDescriptor = mkstemp(g_filePathBuffer);
             
                if (fileDescriptor == -1)
                {
                    if (outFp)
                    {
                        *outFp = NULL;
                    }
                    
                    return NULL;
                }
             
                if (outFp != NULL)
                {
                    *outFp = fdopen(fileDescriptor, "w+");
                }
                else
                {
                    close(fileDescriptor);
                }
                
                return g_filePathBuffer;
            }
        }
    }
}
