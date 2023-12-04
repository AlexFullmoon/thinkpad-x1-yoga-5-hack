/*
 * Several required device fixes:
 * 
 * AC: Patching AC Device so that AppleACPIACAdapter driver loads.
 * Device named ADP1 on Mac. Might not be as necessary as it seems.
 *
 * ALC0 - Ambient light sensor
 * Starting with macOS 10.15 Ambient Light Sensor presence is required
 * for backlight functioning. Here we create an Ambient Light Sensor ACPI Device
 * which can be used by SMCLightSensor kext.
 *
 * PWRB - Power button. Required for detecting it in macOS.
 * Note: macOS detects button release, not press.
 * Note: also, for some reason Ctrl-Ins works as power button. Check this.
 *
 * DMAC - DMA controller
 * Required for dealing with replacement DMAR table
 * as a replacement for DisableIOMapper quirk.
 * Which way (quirk or DMAR) is preferable is unclear.
 *
 */

DefinitionBlock ("", "SSDT", 2, "hack", "FIXDEV", 0x00001000)
{
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.LPCB, DeviceObj)
    External (_SB_.PCI0.LPCB.EC__, DeviceObj)
    External (_SB_.PCI0.LPCB.EC__.AC__, DeviceObj)

    Scope (_SB)
    {
        Device (ALS0) // Fake ambient light sensor.
        {
            Name (_HID, "ACPI0008" /* Ambient Light Sensor Device */)  // _HID: Hardware ID
            Name (_CID, "smc-als")  // _CID: Compatible ID
            Name (_ALI, 0x012C)  // _ALI: Ambient Light Illuminance
            Name (_ALR, Package (0x01)  // _ALR: Ambient Light Response
            {
                Package (0x02)
                {
                    0x64, 
                    0x012C
                }
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }

        Device (PWRB) // Power button
        {
            Name (_HID, EisaId ("PNP0C0C"))
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }

    Scope (\_SB.PCI0.LPCB)
    {
        Device (DMAC) //DMA controller
        {             // Note: this syntax is correct.
            Name (_HID, EisaId ("PNP0200"))
            Name (_CRS, ResourceTemplate ()
            {
                IO (Decode16,
                    0x0000,             // Range Minimum
                    0x0000,             // Range Maximum
                    0x01,               // Alignment
                    0x20,               // Length
                    )
                IO (Decode16,
                    0x0081,             // Range Minimum
                    0x0081,             // Range Maximum
                    0x01,               // Alignment
                    0x11,               // Length
                    )
                IO (Decode16,
                    0x0093,             // Range Minimum
                    0x0093,             // Range Maximum
                    0x01,               // Alignment
                    0x0D,               // Length
                    )
                IO (Decode16,
                    0x00C0,             // Range Minimum
                    0x00C0,             // Range Maximum
                    0x01,               // Alignment
                    0x20,               // Length
                    )
                DMA (Compatibility, NotBusMaster, Transfer8_16, )
                    {4}
            })
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }

    Scope (\_SB.PCI0.LPCB.EC)
    {
        Scope (AC) // AC fix
        {
            If (_OSI ("Darwin"))
            {
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x17, 
                    0x03
                })
            }
        }
    }
}