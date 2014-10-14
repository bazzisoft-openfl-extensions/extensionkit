package org.haxe.extension.extensionkit;

import org.haxe.extension.extensionkit._private.ExtensionKit;

import android.os.Handler;
import android.view.KeyEvent;
import android.view.View;


public class MobileDevice
{
    private static boolean s_keyHandlerInstalled = false;
    private static boolean s_disableBackKey = false;

    //---------------------------------
    // Public methods
    //---------------------------------    
    
    /**
     * When launching a 3rd party app via an Intent, pressing BACK to cancel
     * that app sometimes propagates the back button press to our app and
     * closes it. In that case, you can disable the back button temporarily
     * and re-enable it in onResume after a delay.
     */    
    public static void DisableBackButton()
    {
        InstallKeyListener();
        s_disableBackKey = true; 
    }
    
    public static void EnableBackButton()
    {
        EnableBackButton(1000);
    }
    
    public static void EnableBackButton(int delay)
    {
        new Handler().postDelayed(new Runnable()
        {
            @Override
            public void run()
            {
                s_disableBackKey = false;
            }
        }, delay);
    }
    
    //---------------------------------
    // Private methods
    //---------------------------------
    
    private static void InstallKeyListener()
    {
        if (!s_keyHandlerInstalled)
        {
            s_keyHandlerInstalled = true;
            
            ExtensionKit.mainView.setOnKeyListener(new View.OnKeyListener()
            {
                @Override
                public boolean onKey(View view, int keyCode, KeyEvent event)
                {
                    return (s_disableBackKey && KeyEvent.KEYCODE_BACK == keyCode);
                }
            });
        }
    }    
}
