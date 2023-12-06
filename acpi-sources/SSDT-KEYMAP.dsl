/*
 * Keyboard remaps for VoodooPS2Keyboard.
 * 
 *  PrtSc - Right Cmd
 *  Insert - Numpad Ins (disabled by default)
 *  Fn-P - F16
 *  Fn-K - F17
 *  Fn-B - F19
 *  PrtSc - F20 (disabled by default)
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
                //Optionally remap via PS2 codes
                /* 
                "Custom PS2 Map", Package()
                {
                    Package(){},
                    "e037=e05c",    // PrtSc to RCmd
                    "e052=52",      // Insert to NumIns
                },
                */
                
                "Custom ADB Map", Package()
                {
                    Package(){},
                    "e037=36",      // PrtSc to RCmd
                  //  "e052=52",      // Insert to NumIns
                    "e045=6a",      // Fn-P Pause - F16
                    "46=40",        // Fn-K ScrollLock - F17
                    "e046=50",      // Fn-B Break - F19 
                  //  "e037=50",      // PrtSc - F20


                }
            },
        })
    }
}