#ifndef EXTENSIONKITIPHONE_H
#define EXTENSIONKITIPHONE_H

#include "ExtensionKit.h"


namespace extensionkit
{
    namespace iphone
    {
        UIColor* UIColorFromRGB(int rgb);
        UIColor* UIColorFromARGB(int argb);
        bool ClampDimensionsToMaxSize(int* inOutWidth, int* inOutHeight, int maxAllowableSize);
        const void* UIImageAsJPEGBytes(UIImage* src, int* outLength, float quality = 0.9f);
        const void* UIImageAsPNGBytes(UIImage* src, int* outLength);
        UIImage* RotateUIImageToOrientationUp(UIImage* src);
        UIImage* ResizeUIImage(UIImage* src, int width, int height);
        UIImage* CropUIImage(UIImage* src, int x, int y, int width, int height);
    }
}


#endif