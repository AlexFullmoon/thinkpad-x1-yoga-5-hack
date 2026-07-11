//
// SSDT to disable RHUB device
//
DefinitionBlock ("", "SSDT", 2, "CORP", "UsbReset", 0x00001000)
{
    External (\_SB.PCI0.XHC.RHUB, DeviceObj)
    External (OSDW, MethodObj)

    Scope (\_SB.PCI0.XHC.RHUB)
    {
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If (OSDW())
            {
                Return (Zero)
            }
            Else
            {
                Return (0x0F)
            }
        }
    }

}
