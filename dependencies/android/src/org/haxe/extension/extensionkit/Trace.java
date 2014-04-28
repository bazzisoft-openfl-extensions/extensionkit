package org.haxe.extension.extensionkit;

import android.util.Log;


public class Trace
{
    public static void Info(String s)
    {
        Log.i("trace", s);
    }

    public static void Warning(String s)
    {
        Log.w("trace", s);
    }

    public static void Error(String s)
    {
        Log.e("trace", s);
    }

    public static void Exception(Exception e)
    {
        Error(ExceptionToString(e));
    }

    public static String ExceptionToString(Exception e)
    {
        StringBuilder sb = new StringBuilder();
        StackTraceElement[] stack = e.getStackTrace();
        sb.append(e.toString());

        if (e.getCause() != null)
        {
            sb.append("\n    ");
            sb.append(e.getCause().toString());
        }

        for (StackTraceElement st : stack)
        {
            sb.append("\n    ");
            sb.append("in method ");
            sb.append(st.getClassName());
            sb.append(".");
            sb.append(st.getMethodName());
            sb.append("() at ");
            sb.append(st.getFileName());
            sb.append(":");
            sb.append(st.getLineNumber());
        }

        return sb.toString();
    }
}
