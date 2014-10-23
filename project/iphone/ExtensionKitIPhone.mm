#include <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "ExtensionKitIPhone.h"


namespace extensionkit
{
    namespace iphone
    {
        UIColor* UIColorFromRGB(int rgb)
        {
            return UIColorFromARGB(rgb | 0xff000000);
        }
        
        UIColor* UIColorFromARGB(int argb)
        {
            int blue = argb & 0xff;
            int green = argb >> 8 & 0xff;
            int red = argb >> 16 & 0xff;
            int alpha = argb >> 24 & 0xff;
            
            return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f];
        }
        
        bool ClampDimensionsToMaxSize(int* inOutCurrentWidth, int* inOutCurrentHeight, int maxAllowableSize)
        {
            int w = *inOutCurrentWidth;
            int h = *inOutCurrentHeight;
            int currentMaxSize = (w > h ? w : h);
            
            if (currentMaxSize > maxAllowableSize)
            {            
                float scale = (float)maxAllowableSize / (float)currentMaxSize;
                *inOutCurrentWidth = roundf(w * scale);
                *inOutCurrentHeight = roundf(h * scale);
                return true;
            }
            else
            {
                return false;
            }            
        }
        
        
        const void* UIImageAsJPEGBytes(UIImage* src, int* outLength, float quality)
        {
            NSData* imageAsJPEG = UIImageJPEGRepresentation(src, quality);
            int dataLength = [imageAsJPEG length];
            const void* data = [imageAsJPEG bytes];
            
            if (outLength)
            {
                *outLength = dataLength;
            }
            
            return data;
        }
        
        
        const void* UIImageAsPNGBytes(UIImage* src, int* outLength)
        {
            NSData* imageAsPNG = UIImagePNGRepresentation(src);
            int dataLength = [imageAsPNG length];
            const void* data = [imageAsPNG bytes];
            
            if (outLength)
            {
                *outLength = dataLength;
            }
            
            return data;
        }
        
        
        UIImage* RotateUIImageToOrientationUp(UIImage* src)
        {
            // No-op if the orientation is already correct
            if (src.imageOrientation == UIImageOrientationUp) 
            {
                return src;
            }

            // We need to calculate the proper transformation to make the image upright.
            // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
            CGAffineTransform transform = CGAffineTransformIdentity;

            switch (src.imageOrientation) 
            {
                case UIImageOrientationDown:
                case UIImageOrientationDownMirrored:
                    transform = CGAffineTransformTranslate(transform, src.size.width, src.size.height);
                    transform = CGAffineTransformRotate(transform, M_PI);
                    break;

                case UIImageOrientationLeft:
                case UIImageOrientationLeftMirrored:
                    transform = CGAffineTransformTranslate(transform, src.size.width, 0);
                    transform = CGAffineTransformRotate(transform, M_PI_2);
                    break;

                case UIImageOrientationRight:
                case UIImageOrientationRightMirrored:
                    transform = CGAffineTransformTranslate(transform, 0, src.size.height);
                    transform = CGAffineTransformRotate(transform, -M_PI_2);
                    break;
                    
                case UIImageOrientationUp:
                case UIImageOrientationUpMirrored:
                    break;
            }

            switch (src.imageOrientation) 
            {
                case UIImageOrientationUpMirrored:
                case UIImageOrientationDownMirrored:
                    transform = CGAffineTransformTranslate(transform, src.size.width, 0);
                    transform = CGAffineTransformScale(transform, -1, 1);
                    break;

                case UIImageOrientationLeftMirrored:
                case UIImageOrientationRightMirrored:
                    transform = CGAffineTransformTranslate(transform, src.size.height, 0);
                    transform = CGAffineTransformScale(transform, -1, 1);
                    break;
                    
                case UIImageOrientationUp:
                case UIImageOrientationDown:
                case UIImageOrientationLeft:
                case UIImageOrientationRight:
                    break;
            }

            // Now we draw the underlying CGImage into a new context, applying the transform
            // calculated above.
            CGContextRef ctx = CGBitmapContextCreate(NULL, src.size.width, src.size.height,
                                                     CGImageGetBitsPerComponent(src.CGImage), 0,
                                                     CGImageGetColorSpace(src.CGImage),
                                                     CGImageGetBitmapInfo(src.CGImage));
            CGContextConcatCTM(ctx, transform);
            
            switch (src.imageOrientation) 
            {
                case UIImageOrientationLeft:
                case UIImageOrientationLeftMirrored:
                case UIImageOrientationRight:
                case UIImageOrientationRightMirrored:
                    // Grr...
                    CGContextDrawImage(ctx, CGRectMake(0, 0, src.size.height, src.size.width), src.CGImage);
                    break;

                default:
                    CGContextDrawImage(ctx, CGRectMake(0, 0, src.size.width, src.size.height), src.CGImage);
                    break;
            }

            // And now we just create a new UIImage from the drawing context
            CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
            UIImage *img = [UIImage imageWithCGImage:cgimg];
            CGContextRelease(ctx);
            CGImageRelease(cgimg);
            return img;
        }
        
        
        UIImage* ResizeUIImage(UIImage* src, int width, int height)
        {
            CGRect newRect = CGRectMake(0, 0, width, height);
            CGImageRef imageRef = src.CGImage;
            
            // Build a context that's the same dimensions as the new size
            CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                        newRect.size.width,
                                                        newRect.size.height,
                                                        CGImageGetBitsPerComponent(imageRef),
                                                        0,
                                                        CGImageGetColorSpace(imageRef),
                                                        CGImageGetBitmapInfo(imageRef));
                       
            // Set the quality level to use when rescaling
            CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
            
            // Draw into the context; this scales the image
            CGContextDrawImage(bitmap, newRect, imageRef);
            
            // Get the resized image from the context and a UIImage
            CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
            UIImage* newImage = [UIImage imageWithCGImage:newImageRef];
            
            // Clean up
            CGContextRelease(bitmap);
            CGImageRelease(newImageRef);
            
            return newImage;
        }        
        
        
        UIImage* CropUIImage(UIImage* src, int x, int y, int width, int height)  
        {
            CGImageRef imageRef = CGImageCreateWithImageInRect([src CGImage], CGRectMake(x, y, width, height));
            UIImage* croppedImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            return croppedImage;
        }
    }
}
