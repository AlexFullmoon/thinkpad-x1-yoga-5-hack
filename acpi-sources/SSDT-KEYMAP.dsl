/*
 * Keyboard remaps for VoodooPS2Keyboard.
 * 
 * First, for X1 Yoga tablet mode we enable keyboard/touchpad toggle.
 * By default it is coded to PrtSc, PS2 keycode e037.
 * Then, as PrtSc is too conveniently located, we remap it around.
 * 
 *  PrtSc - Right Cmd
 *  Fn-P - PrtSc (keyboard toggle)
 *  Fn-K - F17 (ScrollLock isn't used in system)
 *
 * Keyboard toggle works as follows:
 *  
 *  PrtSc - toggles touchpad
 *  Win-PrtSc (i.e. LCmd-PrtSc) - toggles touchpad and keyboard
 *  Ctrl-Alt-PrtSc - reset and enable touchpad (don't know how useful is this)
 *  Shift-PrtSc - SysRq interrupt.
 * 
 * For X1 Carbon keyboard toggle is not needed, so you can map Fn-P to F16.
 * 
 * Then you can set F16/F17 to anything else in system.
 * Originally Fn-P/Fn-K are set to F14/F15, hardcoded to brightness keys. 
 *
 * Note: Fn-B (Break) and Fn-S (SysRq) are not remappable due to special logic.
 * Most other Fn keys do not emit PS2 codes.
 *
 */
DefinitionBlock ("", "SSDT", 2, "hack", "KEYMAP", 0)
{
    External(_SB.PCI0.LPCB.KBD, DeviceObj)
    Scope (_SB.PCI0.LPCB.KBD)
    {
        Name (RMCF,Package() 
        {
            "Keyboard", Package()
            {
                // Enable keyboard/touchpad toggle via PrtSc
                // For Yoga tablet mode.
                "RemapPrntScr", ">y",   
                
                // Remaps via PS2 codes
                "Custom PS2 Map", Package()
                {
                    Package(){},
                    "e037=e05c",    // PrtSc to RCmd
                    "e045=e037",      // Fn-P Pause - PrtSc
                    // "e045=67",      // Fn-P Pause - F16
                    "46=68",        // Fn-K ScrollLock - F17
                },
                // Remaps via ADB codes. This way doesn't work with keyboard toggle.
               /* "Custom ADB Map", Package()
                {
                    Package(){},
                  //  "e037=36",      // PrtSc to RCmd
                  //  "e045=6a",      // Fn-P Pause - F16
                  //  "46=40",        // Fn-K ScrollLock - F17
                }*/
            },
        })
    }
}