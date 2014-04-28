package org.haxe.extension.extensionkit;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;


public class Reflect
{

    /**
     * Invokes a static or instance method.
     * Use <type>.class or <value>.getClass() to get the classObj and paramTypes.
     * For static methods, instance should be null.
     */
    public static Object InvokeMethod(Class<?> classObj, String methodName, Object instance, Class<?>[] paramTypes, Object[] params) throws IllegalAccessException, InvocationTargetException, NoSuchMethodException
    {
        Method method = classObj.getMethod(methodName, paramTypes);
        return method.invoke(instance, params);
    }

    /**
     * Creates a proxy object that causes a class that doesn't implemenent interface X to
     * appear as if it does.
     * 
     * Eg.
     *      Class<?> interfaceClass = Reflect.FindClass("android.view.View$OnSystemUiVisibilityChangeListener");
     *      Object proxy = Reflect.CreateProxyForInterface(interfaceClass, this);
     *      Reflect.InvokeMethod(View.class, "setOnSystemUiVisibilityChangeListener", m_view, new Class<?>[] { interfaceClass }, new Object[] { proxy });        
     */
    public static Object CreateProxyForInterface(Class<?> theInterface, InvocationHandler implementingClassInstance)
    {
        return Proxy.newProxyInstance(theInterface.getClassLoader(), new Class[] { theInterface }, implementingClassInstance);
    }

    /**
     * Returns a Class object given the string package and class name.
     */
    public static Class<?> FindClass(String classPackageAndName) throws ClassNotFoundException
    {
        return Class.forName(classPackageAndName);
    }
}
