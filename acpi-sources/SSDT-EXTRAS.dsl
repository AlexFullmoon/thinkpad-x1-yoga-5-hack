/*
 * Adding missing fake/stub/cosmetic devices
 *
 * MCHC - Host Bridge/DRAM Registers, part of SMBus stuff.
 *
 * PPMC - unclear? Not showing in IOReg
 * Check if we even have PCI device on 0x1F,0x2 in WIndows.
 *
 * PGMM - Core Processor Gaussian Mixture Model.
 * Something something speech recognition co-processor?
 * Need to change it to Comet Lake probably.
 *
 * BUS0 - Missing SMBus device.
 *
 * PMCR - (Coffee?) Comet Lake Thermal Controller.
 *
 * XSPI - Comet Lake SPI controller
 *
 * SRAM - Comet Lake Shared SRAM
 * 
 */

DefinitionBlock ("", "SSDT", 2, "hack", "EXTRAS", 0x00000000)
{
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.LPCB, DeviceObj)
    External (_SB_.PCI0.SBUS, DeviceObj)

    Scope (_SB.PCI0)
    {
        Device (MCHC)
        {
            Name (_ADR, Zero)
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

        // Unclear what exactly it does.  
        // Doesn't seem that we even have 0x1F,0x2 device on PCI
        // Remove.
        /*
        Device (PPMC)
        {
            Name (_ADR, 0x001F0002)
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
        */
        

        Device (PGMM) 
        {
            Name (_ADR, 0x00080000)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (_OSI ("Darwin"))
                {
                    Return (Buffer (One)
                    {
                         0x03                                             // .
                    })
                }

                Return (Package (0x06)
                {
                    "AAPL,slot-name", 
                    Buffer (0x0F)
                    {
                        "Internal@0,8,0"
                    }, 

                    "device_type", 
                    Buffer (0x12)
                    {
                        "System peripheral"
                    }, 

                    "model", 
                    Buffer (0x58)
                    {
                        "Intel Core Processor Gaussian Mixture Model"
                    }
                })
            }
            
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

        Device (PMCR)
        {
            Name (_ADR, 0x00120000)  // _ADR: Address
            //Name (_HID, EisaId ("APP9876"))
            Name (_CRS, ResourceTemplate ()
            {
                Memory32Fixed (ReadWrite,
                    0xFE000000,
                    0x00010000 
                    )

            })
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    // Original _STA value for Device (PMCR) found in MacMini8,1 DSDT was 0x0B which
                    // is 1011 in binary. Reading from right to left, it represents the following:
                    //
                    // 1 - Bit [0] - Set if the device is present
                    // 1 - Bit [1] - Set if the device is enabled and decoding its resources
                    // 0 - Bit [2] - Set if the device should be shown in the UI
                    // 1 - Bit [3] - Set if the device is functioning properly (cleared if device failed its diagnostics)
                    Return (0x0B)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }

        Device (SRAM) 
        {
            Name (_ADR, 0x00140002)  // _ADR: Address
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

        Device (XSPI) // 
        {
            Name (_ADR, 0x001F0005)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If ((Arg2 == Zero))
                {
                    Return (Buffer (One)
                    {
                         0x03                                             // .
                    })
                }

                Return (Package (0x20)
                {
                    "pci-device-hidden", 
                    Buffer (0x08)
                    {
                         0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   // ........
                    }
                })
            }

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
        Scope (SBUS)
        {
            Device (BUS0)
            {
                Name (_CID, "smbus")
                Name (_ADR, Zero)
                Device (DVL0)
                {
                    Name (_ADR, 0x57)
                    Name (_CID, "diagsvault")
                    Method (_DSM, 4, NotSerialized)
                    {
                        If (!Arg2)
                        {
                            Return (Buffer (One)
                            {
                                 0x03
                            })
                        }

                        Return (Package (0x02)
                        {
                            "address", 
                            0x57
                        })
                    }
                }
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
    }
}
