package org.haxe.extension.extensionkit;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;


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
        
        public Dimensions(Bitmap bitmap)
        {
        	width = bitmap.getWidth();
        	height = bitmap.getHeight();
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
    	FileOutputStream stream = new FileOutputStream(destFile);

    	try
    	{
	        if (!srcBitmap.compress(Bitmap.CompressFormat.JPEG, Math.round(quality * 100.0f), stream))
	        {
	            throw new IOException("Unable to write JPEG to '" + destFile.getAbsolutePath() + "'.");
	        }
    	}
    	finally
    	{
    		stream.close();
    	}
    }

    public static void SaveBitmapAsPNG(Bitmap srcBitmap, File destFile) throws IOException
    {
    	FileOutputStream stream = new FileOutputStream(destFile);
    	
    	try
    	{
	        if (!srcBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream))
	        {
	            throw new IOException("Unable to write PNG to '" + destFile.getAbsolutePath() + "'.");
	        }
    	}
    	finally
    	{
    		stream.close();
    	}
    }    
    
    public static Bitmap ResizeBitmap(Bitmap srcBitmap, int width, int height)
    {
        return Bitmap.createScaledBitmap(srcBitmap, width, height, true);
    }    
    
    public static Bitmap CropBitmap(Bitmap srcBitmap, int x, int y, int width, int height)
    {
        return Bitmap.createBitmap(srcBitmap, x, y, width, height);
    }

    public static Bitmap RotateBitmap(Bitmap srcBitmap, float degrees)
    {
    	Matrix matrix = new Matrix();
        matrix.postRotate(degrees);
        return Bitmap.createBitmap(srcBitmap, 0, 0, srcBitmap.getWidth(), srcBitmap.getHeight(),
                                   matrix, true);    	
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
    
    public static Bitmap RotateBitmapToOrientationUp(Bitmap bitmap, File bitmapFile) throws IOException
    {
    	ExifInterface ei = new ExifInterface(bitmapFile.getAbsolutePath());
    	int orientation = ei.getAttributeInt(ExifInterface.TAG_ORIENTATION,
    	                                     ExifInterface.ORIENTATION_UNDEFINED);

    	Trace.Info(String.format("Bitmap orientation: %d", orientation));
    	float degrees = -1;
    	
    	switch (orientation ) 
    	{
    	    case ExifInterface.ORIENTATION_ROTATE_90:
    	    	degrees = 90;
    	    	break;
    	    	
    	    case ExifInterface.ORIENTATION_ROTATE_180:
    	    	degrees = 180;
    	    	break;

    	    case ExifInterface.ORIENTATION_ROTATE_270:
    	    	degrees = 270;
    	    	break;
    	}
    	
    	if (degrees > 0)
    	{
        	Trace.Info(String.format("Rotating bitmap by %f degrees", degrees));
            return RotateBitmap(bitmap, degrees);
    	}
    	else
    	{
    		return bitmap;
    	}
    }    
}
