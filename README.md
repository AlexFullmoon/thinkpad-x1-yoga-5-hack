# Yet another Opencore config for Lenovo Thinkpad X1 Yoga Gen5.

OC 0.9.6 | macOS 13.6.1

## Why isn't there an EFI folder that I can just drop in and use?

You must build it yourself.

I am also not sure if packaging a bunch of precompiled files with different licenses is right and which license should *I* use for that.

## Hardware

| Part        | Model               | How to enable                           |
| ----------- | ------------------- | --------------------------------------- |
| CPU         | Comet Lake (10310U) | PluginType is enough                    |
| GPU         | Intel UHD 620       | WhateverGreen with framebuffer patching |
| Ethernet    | Intel i219LM        | IntelMausi. Just works™                 |
| WiFi        | Intel AX201         | itlwm *or* AirportItlwm                 |
| Audio       | ALC 285             | AppleALC, layout 71, no internal mic    |
| Bluetooth   | Intel AX201         | IntelBluetoothFirmware                  |
| Keyboard    | Generic PS/2        | VoodooPS2Keyboard                       |
| Trackpad    | I2C, SYNA8006       | VoodooI2C with HID satellite            |
| Trackpoint  | PS/2 mouse          | VoodooPS2Mouse                          |
| Touchscreen | USB device          | VoodooI2C                               |
| Wacom pen   | USB device          | VoodooI2C, see details below            |

See docs/Hardware.md for more details

## Final issues (won't ever work)

- Usual suspects: fingerprint, IR camera (if present), WWAN (if present).
- Internal microphone.
- [DRM playback](https://github.com/acidanthera/WhateverGreen/blob/master/Manual/FAQ.Chart.md) — broken on iGPU.

## Current issues

- Wacom pen not detected.
  - Known problem on VoodooI2C side. See below.
- Yoga conversion detection (i.e. rotate screen and disable keyboard) doesn't work.
  - Unclear. YogaSMC supposed to do this.
- Fn keys.
  - Many are solved with YogaSMC and Brightness keys. Some issues remain.
- Middle button of trackpoint works as middle button — unclear if it could be configured as scroll.
- Thunderbolt
  - Controller appears in system and I can connect another monitor over TB/DP. Requires further testing, but as I have no hardware to test, it remains an unclosed issue.
- Rare night-time sleep crashes. Hard to debug.
  - Simplest way is disabling hibernation and related features via usual `pmset` litany.
  - Check with *enabled* HibernationFixup. Though it might be unrelated to crash.

## Notes on work in progress

### Next thing to do

Remaining keyboard buttons.

Wacom pen fix.

Yoga conversion — if possible.

Check if GPRW fix is needed. Doesn't seem to be any sleep problems though.

Final cleaning: ScanPolicy, removing serial, public repo, etc.
 
Cosmetic stuff injection in DeviceProperties.

### Thoughts

From boot log: `OCABC: MMIO devirt end, saved 0 KB` — does that mean I don't need DevirtualiseMmio? Seems to work fine without it.

According to some reports replacing DMAR table may be better than DisableIOMapper quirk. Works fine with DMAR, leaving it.

Resetting NVRAM is reported to brick certain Thinkpads with certain BIOS versions. Better not to risk that.

Increase max VRAM? Set `framebuffer-unifiedmem` to 0xFFFFFFFF or other. Default one is 1.5 Gb or more?

YogaSMC doesn't need YVPS and \_LID.

### Input devices

Current state:
- VoodooPS2 for keyboard, trackpoint (seems to be PS/2 as well).
- VoodooI2C for trackpad (works without need for GPIO pinning) and touchscreen.
- VoodooRMI for some improvements: better trackpoint, no trackpad lag with trackpoint buttons.
- Pen doesn't work.
  - Requires VoodooI2CHID v.2.6.5 or compiling VoodooI2C, no released fix yet. Testing.
- Middle trackpoint key works only as middle mouse button.
- Several keys require (re)mapping.

VoodooRMI requires *only* VoodooRMI, RMII2C and bundled VoodooInput kexts.

### Extra keys

Some Fn keys would work even outside of OS, most will work with YogaSMC and BrightnessKeys. See more details in docs/Keyboard.md.

**Important!** Do not use Fn-4 without YogaSMC, it calls for wrong sleep state.

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

There is no CFG lock in BIOS (it's inside engineering menu), and usual ways of switching it (modified GRUB, RU) **do not work**. Reportedly, the only way to toggle it is through direct BIOS write, with programmer clip and all, with corresponding dangers (doing that breaks TPM, among other things).

There is no DVMT Prealloc setting (it's inside engineering menu along with CFG Lock), but fortunately it's already 64Mb by default, enough for framebuffer.

## ACPI files

See docs/ACPI.md for more details.

| Name         | What it is                      |
| ------------ | ------------------------------- |
| SSDT-PLUG    | CPU PluginType enabler          |
| SSDT-USBX    | USB power injection             |
| SSDT-PNLF    | Backlight fix                   |
| SSDT-RTCAWAC | RTC fix                         |
| SSDT-RHUB    | USB hub fix                     |
| SSDT-OSI     | OS version patches              |
| SSDT‑HPET    | IRQ patches                     |
| SSDT-FIXDEV  | Fixes to some devices.          |
| SSDT-YOGA    | Supplementary SSDT for YogaSMC  |
| SSDT-TB      | Thunderbolt fixes               |
| SSDT-KEYMAP  | Keyboard remaps. Optional.      |
| SSDT-EXTRAS  | Cosmetic device fixes, optional |
| DMAR         | See below. Requires SSDT-FIXDEV |

DMAR is a replacement DMA Regions table with protected regions removed. Basically, macOS is incompatible with VT-d without some fix, and you have three options:

1. Disable VT-d in BIOS. Best option if you don't need it in other OSes.
2. Use DisableIOMapper quirk in OC. OC manual recommend this, but there are also reports that next option sometimes work better.
3. Add DMAC device (in SSDT-FIXDEV), remove protected regions in DMAR table and reinject it while dropping original.

As it could change with BIOS update, **you must make it yourself**, so it is not provided. Use SSDTTime for that.

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
    - VoodooPS2 for keyboard and trackpoint
    - VoodooI2C for trackpad and touchscreen
    - VoodooRMI for general improvements
    - YogaSMC for Fn keys
- *Other stuff*
    - ECEnabler
    - RestrictEvents
    - HibernationFixup ??
    - NVMEFix

## Acknowledgements

Dortania, AcidAnthera team and other people from community.

Authors of all drivers and software used here.

Prebuilt configs I've usedol:

- https://github.com/jsassu20/OpenCore-HotPatching-Guide
- https://github.com/tylernguyen/x1c6-hackintosh
- https://github.com/Jamesxxx1997/thinkpad-x1-yoga-2018-hackintosh
- User Balo77 from [OSXLatitude](https://osxlatitude.com/forums/topic/18146-lenovo-thinkpad-x1-yoga-gen-5-type-20ub-20uc/?do=findComment&comment=118324).
