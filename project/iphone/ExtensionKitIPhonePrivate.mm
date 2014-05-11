#include <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <stdio.h>
#include <stdlib.h>


namespace extensionkit
{
    namespace iphone
    {
        namespace _private
        {
            FILE* CreateTemporaryFile(char* outPath)
            {
                NSString* tempFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempfile.XXXXXX"];
                const char* tempFileTemplateCString = [tempFileTemplate fileSystemRepresentation];
                char* tempFileNameCString = (char*) malloc(strlen(tempFileTemplateCString) + 1);
                strcpy(tempFileNameCString, tempFileTemplateCString);
                int fileDescriptor = mkstemp(tempFileNameCString);
             
                if (fileDescriptor == -1)
                {
                    // handle file creation failure
                    free(tempFileNameCString);
                    return NULL;
                }
             
                if (outPath != NULL)
                {
                    // copy our file path to the passed parameter if given
                    strcpy(outPath, tempFileNameCString);
                }
                
                free(tempFileNameCString);
                
                return fdopen(fileDescriptor, "w+");
            }
        }
    }
}
