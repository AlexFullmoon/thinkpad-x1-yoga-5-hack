/*
 * Shared helper method for macOS detection
 * See explanation: https://github.com/5T33Z0/OC-Little-Translated/tree/main/Content/01_Adding_missing_Devices_and_enabling_Features/SSDT-OSDW
 */

DefinitionBlock ("", "SSDT", 2, "OCLT", "OSDW", 0x00000000)
{
    Method (OSDW, 0, NotSerialized)
    {
        If (CondRefOf (\_OSI))
        {
            If (_OSI("Darwin"))
            {
                Return (One)
            }
        }
        Return (Zero)
    }
}
