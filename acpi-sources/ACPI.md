# ACPI files

Required:

| Name         | What it is  | Comment                                                                     |
| ------------ | ----------- | --------------------------------------------------------------------------- |
| SSDT-PLUG    | PluginType  | CPU location is `_SB_.PR00`                                                 |
| SSDT-USBX    | USB power   | Standard one. EC device is present and correct.                             |
| SSDT-PNLF    | Backlight   | GPU location is `_SB_.PCI0.GFX0`. Choosing between variants.                |
| SSDT-RTCAWAC | RTC fix     | Standard one is okay.                                                       |
| SSDT-RHUB    | USB hub fix | `_SB_.PCI0.XHC.RHUB`. Standard one is okay.                                 |
| SSDT-XOSI    | OS patch    | For I2C trackpad, GPI0 stub is apparently insufficient. **Patch required.** |


Probably required:

| Name       | What it is             | Comment                                                                                       |
| ---------- | ---------------------- | --------------------------------------------------------------------------------------------- |
| SSDT-THINK | Thinkpad-specific      | Several patches for sensors. Also serves as a replacement for XOSI.                           |
| SSDT‑HPET  | IRQ patches            | How necessary are those?                                                                      |
| SSDT-AC    | AC adapter patch       | Loads AppleACPIAC adapter. Supposedly required for Lenovo, check.                             |
| DMAR       | Memory regions fix     | Via SSDTTime; Requires SSDT-DMAC. OC manual states that DisableIOMapper is preferred instead. |
| SSDT-DMAC  | Missing DMA controller | Missing device for DMAR table                                                                 |




Probably optional:

| Name      | What it is             | Comment         |
| --------- | ---------------------- | --------------- |
| SSDT-ALS0 | Fake ALS0              | Needed?         |
| SSDT-PWRB | Power button fix       | Check if works. |
| SSDT-MCHC | Another missing device | Needed?         |
| SSDT-SBUS | Another missing device | Needed?         |
| SSDT-PMCR | Another missing device | Needed?         |
| SSDT-PPMC | Another missing device | Needed?         |
