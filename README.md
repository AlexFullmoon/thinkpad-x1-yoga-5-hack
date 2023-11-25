# thinkpad-x1-yoga-5-hack

Yet another Opencore config for Lenovo Thinkpad X1 Yoga gen5.

## Hardware

| CPU | Comet Lake (10310U) | PluginType is enough |
| GPU | Intel UHD 620 | WhateverGreen with some extended framebuffer patching |
| Ethernet | Intel i219LM — IntelMausi |
| WiFi | Intel AX201 | itlwm or AirportItlwm |
| Audio | ALC 285 | AppleALC, *layout 21*? some problems with microphones and volume |
| Bluetooth | Intel AX201 | IntelBluetoothFirmware |
| Keyboard | Generic PS/2 | VoodooPS2Keyboard |
| Trackpad | I2C, SYNA8006 | VoodooI2C with HID satellite |
| Trackpoint | PS/2 mouse | VoodooPS2Mouse |
| Touchscreen | USB device | VoodooI2C ? |
| Wacom pen | USB device | ??? |

## Current problems

- CFG Lock in BIOS
  - Usual ways of unlocking **do not work**, the only reported way is to reflash BIOS directly.
- Wacom pen
  - Unclear.
- Thunderbolt
  - Unclear, no hardware to test.
- Several bogus devices in PCI?
  - Unclear.
- Power button not working
  - Likely solved with YogaSMC
- Fn keys.
  - Solved with YogaSMC or Brightness keys; keyboard backlight works independent of OS.

## Current thoughts

From boot log: `OCABC: MMIO devirt end, saved 0 KB` — does that mean I don't need DevirtualiseMmio?

## BIOS settings

[TODO] Recheck

- Config
  - Thunderbolt
    - BIOS Assist mode → Disabled
    - Thunderbolt Device → Enabled
  - Sleep mode → Linux
- Security
  - Security chip → Disabled
  - Fingerprint predesktop → Disabled
  - Secure Boot → Disabled; Clear all keys if needed
  - Intel SGX → Disabled
- Network
  - WOL → Disabled
  - UEFI IPv4,IPv6 stack → Disabled
- Startup
  - CSM Support → Disabled

There is no DVMT Prealloc setting (it's inside engineering menu along with CFG Lock), but apparently it's already 64Mb default.

## ACPI files

Required:

| SSDT-PLUG | PluginType | CPU location is `_SB_.PR00` |
| SSDT-USBX | USB power | Standard one. EC device is present and correct. |
| SSDT-PNLF | Backlight | GPU location is `_SB_.PCI0.GFX0`. SSDTTime generated one is smaller and works. |
| SSDT-RTCAWAC | RTC fix | Standard one. |
| SSDT-RHUB | USB hub fix | `_SB_.PCI0.XHC.RHUB`. Standard one is okay. |
| SSDT-XOSI | For I2C trackpad, GPI0 stub is apparently insufficient. **Patch required.** |


Testing:

| SSDT-THINK | Thinkpad-specific | Several patches for sensors. Also a replacement for XOSI. |
| SSDT-HPET | IRQ patches | How necessary are those? |
| SSDT-AC | AC adapter patch | Loads AppleACPIAC adapter. Supposedly required for Lenovo, check. |
| SSDT-ALS0 | Fake ALS0 | Needed? |
| SSDT-PWRB | Power button fix | Check if works. |
| SSDT-MCHC | Another missing device | Needed? |
| SSDT-SBUS | Another missing device | Needed? |
| SSDT-PMCR | Another missing device | Needed? |
| SSDT-PPMC | Another missing device | Needed? |
| DMAR | Memory regions fix | Via SSDTTime; Requires SSDT-DMAC. OC manual states that DisableIOMapper is preferred instead. |
| SSDT-DMAC | Missing DMA controller | Missing device for DMAR table |

Thoughts
- According to some reports using cleaned DMAR may be better than DisableIOMapper

## Kexts

- Lilu
- VirtualSMC with plugins
- WhateverGreen
- AppleALC
- IntelMausi
- *Wireless*
  - itlwm + Heliport *or*
  - AirportItlwm
- *Bluetooth*
  - IntelBluetoothFirmware
  - IntelBTPatcher
  - BlueToolFixup
- UsbToolbox + map
- *Input*
    - VoodooPS2 for keyboard
    - VoodooI2C for trackpad
    - VoodooI2C for USB touchscreen
    - VoodooPS2 for trackpoint
    - YogaSMC for Fn keys?
- *Thunderbolt & USBC stuff*
  - **???**
- *Minor stuff*
    - ECEnabler
    - RestrictEvents
    - HibernationFixup
    - NVMEFix
    - Camera **?**
    - IOElectrify **?**


