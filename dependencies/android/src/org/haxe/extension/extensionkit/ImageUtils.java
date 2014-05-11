package org.haxe.extension.extensionkit;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;


public class ImageUtils
{
    public static class Dimensions
    {
        public int width;
        public int height;
        
        public Dimensions(int w, int h)
        {
            width = w;
            height = h;
        }        
    }
        
    public static Bitmap LoadBitmapFromFile(File bitmapFile) throws IOException
    {
        Bitmap bitmap = BitmapFactory.decodeFile(bitmapFile.getAbsolutePath());
        if (null == bitmap)
        {
            throw new IOException("Unable to read or decode image file '" + bitmapFile.getAbsolutePath() + "'.");
        }
        
        return bitmap;
    }

    public static void SaveBitmapAsJPEG(Bitmap srcBitmap, File destFile) throws IOException
    {
        SaveBitmapAsJPEG(srcBitmap, destFile, 0.9f);
    }
    
    public static void SaveBitmapAsJPEG(Bitmap srcBitmap, File destFile, float quality) throws IOException
    {
        if (!srcBitmap.compress(Bitmap.CompressFormat.JPEG, Math.round(quality * 100.0f), new FileOutputStream(destFile)))
        {
            throw new IOException("Unable to write JPEG to '" + destFile.getAbsolutePath() + "'.");
        }
    }

    public static void SaveBitmapAsPNG(Bitmap srcBitmap, File destFile) throws IOException
    {
        if (!srcBitmap.compress(Bitmap.CompressFormat.PNG, 100, new FileOutputStream(destFile)))
        {
            throw new IOException("Unable to write PNG to '" + destFile.getAbsolutePath() + "'.");
        }
    }    
    
    public static Bitmap ResizeBitmap(Bitmap srcBitmap, int width, int height)
    {
        return srcBitmap.createScaledBitmap(srcBitmap, width, height, true);
    }    
    
    public static Bitmap CropBitmap(Bitmap srcBitmap, int x, int y, int width, int height)
    {
        return srcBitmap.createBitmap(srcBitmap, x, y, width, height);
    }
    
    public static Dimensions GetBitmapFileDimensions(File bitmapFile)
    {
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(bitmapFile.getAbsolutePath(), options);
        return new Dimensions(options.outWidth, options.outHeight);
    }
    
    public static boolean ClampDimensionsToMaxSize(Dimensions inOutCurrentSize, int maxAllowableSize)
    {
        int currentMaxSize = Math.max(inOutCurrentSize.width, inOutCurrentSize.height);
        
        if (currentMaxSize > maxAllowableSize)
        {            
            float scale = (float)maxAllowableSize / (float)currentMaxSize;
            inOutCurrentSize.width = Math.round(inOutCurrentSize.width * scale);
            inOutCurrentSize.height = Math.round(inOutCurrentSize.height * scale);
            return true;
        }
        else
        {
            return false;
        }
    }
}
