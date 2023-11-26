# thinkpad-x1-yoga-5-hack

Yet another Opencore config for Lenovo Thinkpad X1 Yoga gen5.

OC 0.9.6 | macOS 13.6.1

## Hardware

| Part        | Model                     | How to enable                                                           |
| ----------- | ------------------------- | ----------------------------------------------------------------- |
| CPU         | Comet Lake (10310U)       | PluginType is enough.                                             |
| GPU         | Intel UHD 620             | WhateverGreen with some extended framebuffer patching.            |
| Ethernet    | Intel i219LM              | IntelMausi. Just works™.                                          |
| WiFi        | Intel AX201               | itlwm *or* AirportItlwm.                                          |
| Audio       | ALC 285                   | AppleALC, layout *??*. Problems with microphones and volume. |
| Bluetooth   | Intel AX201               | IntelBluetoothFirmware.                                           |
| Keyboard    | Generic PS/2              | VoodooPS2Keyboard.                                                |
| Trackpad    | I2C, SYNA8006             | VoodooI2C with HID satellite.                                     |
| Trackpoint  | PS/2 mouse                | VoodooPS2Mouse.                                                   |
| Touchscreen | USB device                | VoodooI2C                                                       |
| Wacom pen   | USB device                | ???                                                               |

## Current issues

- CFG Lock in BIOS.
  - Usual ways of unlocking **do not work**. Either flash BIOS directly or use quirks.
- Wacom pen not detected.
  - Unclear. There are reports of it working.
- Built-in microphones don't work.
  - Unclear. Playing with AppleALC layouts. Will consider trying to write my own.
- Yoga conversion detection (i.e. rotate screen and disable keyboard) doesn't work.
  - Unclear. Check if YogaSMC can do this at all.
- Thunderbolt
  - [TODO] Unclear, no hardware to test.
- Middle button of trackpoint not working.
  - Supposedly some extra configuration of VoodooPS2 required.
- Fn keys.
  - Most are solved with YogaSMC and Brightness keys.
- [No DRM playback](https://github.com/acidanthera/WhateverGreen/blob/master/Manual/FAQ.Chart.md) — dosn't use anyway.
- Usual incompatibilities: fingerprint reader.

## Notes on work in progress

### Next thing to do

Thunderbolt.

### Thoughts

From boot log: `OCABC: MMIO devirt end, saved 0 KB` — does that mean I don't need DevirtualiseMmio? Seems to work fine without it.

According to some reports replacing DMAR table may be better than DisableIOMapper quirk.

Resetting NVRAM is reported to brick certain Thinkpads with certain BIOS versions. Better not to risk that.

VoodooSMBus — check if needed/better. Seems to be incompatible with Trackpoint. Everything seems to work fine without it.

A couple unknown devices, poorly recognised Thunderbolt/USB3.1:

- "ExpressCard" unknown 8086:15d2 sub 17aa:25be, x4
- "ExpressCard" XHCI 8086:15d4 sub 17aa:25be, x4

Also consider cometic SSDT devices for:

- 8086:2a4 - 17aa:22be @1f,5 — SPI (Flash) controller
- 8086:2ef - 17aa:22be @14,2 — Shared SRAM
- 8086:2f9 - 17aa:22be @12 — Coffee Lake Thermal Subsystem

Increase max VRAM? Set `framebuffer-unifiedmem` to 0xFFFFFFFF or other. Default one is 1.5 Gb

### Keys

- [x] Fn-Space works OOB and outside of OS (but doesn't show keyboard backlight either)
- [x] Fn-Esc (FnLock) works OOB and independent of OS
- [x] Fn-F1 to F3 work OOB
- [x] Fn-F4 (mute mic) with YogaSMC
- [x] Fn-F5-F6 work with BrightnessKeys
- [x] Fn-F7 (dual display) with YogaSMC
- [x] Fn-F8 (airplane mode) with YogaSMC
- [ ] Fn-F9-F11 (custom Windows-only keys) - detects, check value
- [ ] Fn-F12 (custom key) — unclear.
- [ ] Fn-PrnScr (snipping tool) - detects, check value
- [ ] Fn-B = Break - detects, check value
- [ ] Fn-K = Scroll Lock - detects, check value
- [ ] Fn-P = Pause - detects, check value
- [ ] Fn-S = SysRq - detects, check value
- [x] Fn-4 = Sleep - **requires YogaSMC**. Kernel panic with CMOS checksum error without it.

### Audio

Requires testing. Layouts: 11, 21, 31, 52, 61, 66, 71, 88

- 11
- 21 — only top dynamics, rather low volume, no builtin microphones, jack ?
- 31
- 52
- 61
- 66
- 71
- 88

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

There is no CFG lock in BIOS (it's inside engineering menu), and usual ways of switching it **do not work**. Reportedly, the only way to toggle it is through direct BIOS write, with programmer clip and all, with corresponding dangers (it breaks TPM, among other things).

There is no DVMT Prealloc setting (it's inside engineering menu along with CFG Lock), but apparently it's already 64Mb by default.

## ACPI files

Required:

| Name         | What it is  | Comment                                                                                 |
| ------------ | ----------- | --------------------------------------------------------------------------------------- |
| SSDT-PLUG    | PluginType  | CPU location is `_SB_.PR00`                                                             |
| SSDT-USBX    | USB power   | Standard one. EC device is present and correct.                                         |
| SSDT-PNLF    | Backlight   | GPU location is `_SB_.PCI0.GFX0`. The one from SSDTTime is smaller, but requires patch. |
| SSDT-RTCAWAC | RTC fix     | Standard one.                                                                           |
| SSDT-RHUB    | USB hub fix | `_SB_.PCI0.XHC.RHUB`. Standard one is okay.                                             |
| SSDT-OSI     | OS patches  | For I2C trackpad and some other things.                                                 |
| SSDT-ECFIX   | Edits to EC | Most are required by YogaSMC                                                            |
| SSDT-Devices | Add devices | DMAC for DMAR table; power button; fake ALS0; several mostly cosmetic ones              |
| DMAR         | Replacement | Either use it (and drop original) or enable DisableIOMapper, or disable VT-d            |
| SSDT‑HPET    | IRQ patches | Might not be necessary.                                                                 |

Testing:

| Name      | What it is  | Comment                            |
| --------- | ----------- | ---------------------------------- |
| SSDT-TB   | Thunderbolt | Testing                            |
| SSDT-YVPC | YVPC device | From YogaSMC; unclear if required. |
| SSDT-WMIS | WMIS ?      | From YogaSMC; unclear if required. |

## Kexts

- Lilu
- VirtualSMC
  - SMCBattery
  - SMCProcessor
  - SMCSuperIO
  - SMCLightSensor
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
    - YogaSMC for Fn keys
- *Thunderbolt & USBC stuff*
  - **???**
- *Minor stuff*
    - ECEnabler
    - RestrictEvents
    - HibernationFixup
    - NVMEFix
    - Camera **?**
    - IOElectrify **?**

## Acknowledgements

Dortania, AcidAnthera team and other people from community
https://github.com/jsassu20/OpenCore-HotPatching-Guide
https://github.com/tylernguyen/x1c6-hackintosh
https://github.com/Jamesxxx1997/thinkpad-x1-yoga-2018-hackintosh
User Balo77 from [OSXLatitude](https://osxlatitude.com/forums/topic/18146-lenovo-thinkpad-x1-yoga-gen-5-type-20ub-20uc/?do=findComment&comment=118324).
