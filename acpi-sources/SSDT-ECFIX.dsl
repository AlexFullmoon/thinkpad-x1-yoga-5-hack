/*
 *  Several EC fixes
 *
 *  AC: Patching AC Device so that AppleACPIACAdapter driver loads.
 *  Device named ADP1 on Mac
 *
 *  ESEN: Sensor access or something?
 *
 *  RE1B,RECB,WE1B,WECB,NBAT - EC rw access for YogaSMC. 
 *  
 */


DefinitionBlock ("", "SSDT", 2, "hack", "_AC", 0x00001000)
{
    External (_SB_.PCI0.LPCB.EC__, DeviceObj)
    External (_SB_.PCI0.LPCB.EC__.AC__, DeviceObj)
    External (_SB_.PCI0.LPCB.EC__.HKEY, DeviceObj)
    External (_SB_.PCI0.LPCB.EC__.BAT1, DeviceObj)
    External (_SI_._SST, MethodObj)


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
        
    /*
     * Sensor access for YogaSMC
     * 
     * Double check name of FieldUnit for collision
     * Registers return 0x00 for non-implemented, 
     * and return 0x80 when not available.
     */
        If (_OSI ("Darwin")) 
        {
            OperationRegion (ESEN, EmbeddedControl, Zero, 0x0100)
            Field (ESEN, ByteAcc, Lock, Preserve)
            {
                Offset (0x78), // TP_EC_THERMAL_TMP0
                EST0,   8, // CPU
                EST1,   8, 
                EST2,   8, 
                EST3,   8, // GPU ?
                EST4,   8, // Battery ?
                EST5,   8, // Battery ?
                EST6,   8, // Battery ?
                EST7,   8, // Battery ?
                Offset (0xC0), // TP_EC_THERMAL_TMP8
                EST8,   8, 
                EST9,   8, 
                ESTA,   8, 
                ESTB,   8, 
                ESTC,   8, 
                ESTD,   8, 
                ESTE,   8, 
                ESTF,   8
            }
        }

        // EC RW methods for YogaSMC
        Method (RE1B, 1, NotSerialized)
        {
            OperationRegion (ERAM, EmbeddedControl, Arg0, One)
            Field (ERAM, ByteAcc, NoLock, Preserve)
            {
                BYTE,   8
            }

            Return (BYTE)
        }

        Method (RECB, 2, Serialized)
        {
            Arg1 = ((Arg1 + 0x07) >> 0x03)
            Name (TEMP, Buffer (Arg1) {})
            Arg1 += Arg0
            Local0 = Zero
            While ((Arg0 < Arg1))
            {
                TEMP [Local0] = RE1B (Arg0)
                Arg0++
                Local0++
            }

            Return (TEMP)
        }

        Method (WE1B, 2, NotSerialized)
        {
            OperationRegion (ERAM, EmbeddedControl, Arg0, One)
            Field (ERAM, ByteAcc, NoLock, Preserve)
            {
                BYTE,   8
            }

            BYTE = Arg1
        }

        Method (WECB, 3, Serialized)
        {
            Arg1 = ((Arg1 + 0x07) >> 0x03)
            Name (TEMP, Buffer (Arg1) {})
            TEMP = Arg2
            Arg1 += Arg0
            Local0 = Zero
            While ((Arg0 < Arg1))
            {
                WE1B (Arg0, DerefOf (TEMP [Local0]))
                Arg0++
                Local0++
            }
        }
        
        // Optional: Notify battery on conservation mode change
        
        Method (NBAT, 0, Serialized)
        {
            If (CondRefOf (BAT1))
            {
                Notify (BAT1, 0x80)
            }
        }   

    }
}
