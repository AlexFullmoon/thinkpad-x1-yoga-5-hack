/*
 * Direct setting of various OS version variables instead of depending on XOSI.
 */
DefinitionBlock ("", "SSDT", 2, "hack", "OSI", 0x00000000)
{
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.LPCB.EC__, DeviceObj)
    External (_SB_.PCI0.LPCB.EC__.HKEY, DeviceObj)
    External (_SB_.PCI0.I2C1, DeviceObj)
    External (_SB_.PCI0.I2C1.TPD0, DeviceObj)
    External (LNUX, IntObj)
    External (WNTF, IntObj)
    External (WIN8, IntObj)
    External (_SI_._SST, MethodObj)    // 1 Arguments

    Scope (\)
    {
        If (_OSI ("Darwin")) 
        {
            //HPTE = Zero    // Disables HPET?
            //TPDM = Zero    // Does something with TPD0?
            
            // YogaSMC
            LNUX = One     // Sets OS type to Linus
                           // Initialze mute button mode like Linux when it's broken
                           // May be combined with MuteLEDFixup in prefpane.
            WNTF = One     // Sets OS version to Windows 2001
                           // Enable DYTC thermal-management on newer Thinkpads.
                           // Requires specifically WNTF
            WIN8 = One     // Sets OS version to Windows 2015 just in case
        }
        Scope (_SB)
        {
            Scope (PCI0)
            {
                Scope (I2C1)
                {
                    Scope (TPD0) // Touchpad stub
                    {
                        If (_OSI ("Darwin"))
                        {
                            Name (OSYS, 0x07DF) // Windows 2015 again
                        }
                    }
                }
            }
        }
        Scope (\_SB.PCI0.LPCB.EC)
        {
            Scope (HKEY) 
            {
                If (_OSI ("Darwin"))
                {
                    Name (OSYS, 0x07DF)
                }
                // Optional: Route to customized LED pattern or origin _SI._SST if differ from built in pattern.
                Method (CSSI, 1, NotSerialized)
                {
                    If (_OSI ("Darwin"))
                    {
                        \_SI._SST (Arg0)
                    }
                }
            }
        }
    }
}