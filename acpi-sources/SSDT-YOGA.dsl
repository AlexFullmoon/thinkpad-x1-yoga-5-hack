/*
 * YogaSMC supplementary patches.
 *
 * ESEN: Sensor access.
 *
 * RE1B,RECB,WE1B,WECB,NBAT: EC rw access for YogaSMC.
 *
 * CSSI: some LED control fixes.
 *
 * RCSM,GCSM,SCSM,_Q2A: clamshell mode. While it is on, lid opening is ignored,
 * so the internal display stays off and the keyboard and touchpad stay usable.
 * Needs ACPI patch _Q2A to XQ2A (lid open EC query) in config.plist.
 *
 */
DefinitionBlock ("", "SSDT", 2, "hack", "YOGA", 0x00000000)
{

    External(_SB_.PCI0.LPCB.EC__, DeviceObj)
    External(_SB_.PCI0.LPCB.EC__.HKEY, DeviceObj)
    External(_SB_.PCI0.LPCB.EC__.BAT1, DeviceObj)
    External(_SI_._SST, MethodObj)
    External(_SB_.PCI0.LPCB.EC__.XQ2A, MethodObj)

    Scope (_SB.PCI0.LPCB.EC)
    {

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

        // EC RW methods
        
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

        // Clamshell mode, set by YogaSMC through HKEY.SCSM
        Name (RCSM, Zero)

        // Lid open, original renamed to XQ2A
        Method (_Q2A, 0, NotSerialized)
        {
            If (!_OSI ("Darwin") || (RCSM == Zero))
            {
                XQ2A ()
            }
        }

    }

    Scope (\_SB.PCI0.LPCB.EC.HKEY)
    {
        // Optional: Route to customized LED pattern or origin _SI._SST
        // if differ from built in pattern. Unsure if required.

        Method (CSSI, 1, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                \_SI._SST (Arg0)
            }
        }

        // Clamshell mode for YogaSMC
        Method (GCSM, 0, NotSerialized)
        {
            Return (\_SB.PCI0.LPCB.EC.RCSM)
        }

        Method (SCSM, 1, NotSerialized)
        {
            If ((Arg0 == Zero))
            {
                \_SB.PCI0.LPCB.EC.RCSM = Zero
            }
            Else
            {
                \_SB.PCI0.LPCB.EC.RCSM = One
            }

            Return (Zero)
        }
    }
}
