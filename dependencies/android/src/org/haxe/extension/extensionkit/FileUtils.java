package org.haxe.extension.extensionkit;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.haxe.extension.Extension;

import android.graphics.BitmapFactory;


public class FileUtils
{
    private static final int EOF = -1;
    
    public static File CreateTemporaryFile() throws IOException
    {
        return CreateTemporaryFile(false);
    }
    
    public static File CreateTemporaryFile(boolean useExternalStorage) throws IOException
    {
        File outputDir;
        
        if (useExternalStorage)
        {
            outputDir = Extension.mainActivity.getExternalFilesDir(null);
        }
        else
        {
            outputDir = Extension.mainActivity.getCacheDir();
        }
        
        if (!outputDir.exists())
        {
            outputDir.mkdirs();
        }
        
        File outputFile = File.createTempFile("tempfile", null, outputDir);
        return outputFile;
    }
    
    public static byte[] ReadFileToByteArray(File file) throws IOException
    {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        CopyInputToOutputStream(new FileInputStream(file), baos);
        return baos.toByteArray();        
    }
    
    public static long CopyInputToOutputStream(InputStream input, OutputStream output) throws IOException 
    {
        byte[] buffer = new byte[4096];
        long count = 0;
        int n = 0;
        while (EOF != (n = input.read(buffer))) 
        {
            output.write(buffer, 0, n);
            count += n;
        }
        return count;
    }
}
