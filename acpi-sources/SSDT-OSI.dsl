/*
 * Direct setting of various OS version variables instead of depending on XOSI.
 *
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
    External (TPDM, IntObj)
    External (_SI_._SST, MethodObj)    // 1 Arguments

    Scope (\)
    {
        If (_OSI ("Darwin")) 
        {
            TPDM = Zero    // Does something with touchpad GPIO? Doesn't seem to change anything
                           // but appears in other configs, sooo... just in case. 
            
            // YogaSMC
            LNUX = One     // Sets OS type to Linux
                           // Initialze mute button mode like Linux when it's broken
                           // May be combined with MuteLEDFixup in prefpane.
                           // AFAIK adds Fn-H/M/L keys for performance modes
            WNTF = One     // Sets OS version to Windows 2001
                           // Enable DYTC thermal management on newer Thinkpads.
                           // Requires specifically WNTF
            WIN8 = One     // Sets OS version to Windows 2015 just in case.
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
            }
        }
    }
}