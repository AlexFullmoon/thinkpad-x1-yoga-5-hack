# thinkpad-x1-yoga-5-hack

Yet another Opencore config for Lenovo Thinkpad X1 Yoga Gen5.

OC 0.9.6 | macOS 13.6.1

## Hardware

| Part        | Model               | How to enable                                 |
| ----------- | ------------------- | --------------------------------------------- |
| CPU         | Comet Lake (10310U) | PluginType is enough.                         |
| GPU         | Intel UHD 620       | WhateverGreen with some framebuffer patching. |
| Ethernet    | Intel i219LM        | IntelMausi. Just works™.                      |
| WiFi        | Intel AX201         | itlwm *or* AirportItlwm.                      |
| Audio       | ALC 285             | AppleALC, layout 71.                          |
| Bluetooth   | Intel AX201         | IntelBluetoothFirmware.                       |
| Keyboard    | Generic PS/2        | VoodooPS2Keyboard.                            |
| Trackpad    | I2C, SYNA8006       | VoodooI2C with HID satellite.                 |
| Trackpoint  | PS/2 mouse          | VoodooPS2Mouse.                               |
| Touchscreen | USB device          | VoodooI2C                                     |
| Wacom pen   | USB device          | ???                                           |


## Final issues (won't ever work)

- Usual suspects: fingerprint, IR camera (if present), WWAN (if present).
- Internal microphone.
- [DRM playback](https://github.com/acidanthera/WhateverGreen/blob/master/Manual/FAQ.Chart.md) — broken on iGPU.

## Current issues

- Wacom pen not detected.
  - Unclear. There are reports of it working through VoodooRMI or VoodooI2C.
- Yoga conversion detection (i.e. rotate screen and disable keyboard) doesn't work.
  - Unclear. YogaSMC supposed to do this.
- Middle button of trackpoint not working.
  - Supposedly some extra configuration of VoodooPS2 required.
  - Pressing trackpoint buttons stops trackpad for a half second. Mildly infuriating.
    - Same happens on Windows, so probably nothing can be done here.
    - There is a setting in kext, but apparently delay is needed for filtering out packets from trackpoint.
- Fn keys.
  - Many are solved with YogaSMC and Brightness keys. Some issues remain.
- Thunderbolt
  - Controller appears in system and I can connect another monitor over TB/DP. Requires further testing, but I have no hardware to test.

## Notes on work in progress

### Next thing to do

Keyboard and trackpoint.

VoodooRMI — check again.

Check if GPRW fix is needed. Doesn't seem to be any sleep problems though.

Final cleaning: ScanPolicy, removing serial, public repo, etc.

### Thoughts

From boot log: `OCABC: MMIO devirt end, saved 0 KB` — does that mean I don't need DevirtualiseMmio? Seems to work fine without it.

According to some reports replacing DMAR table may be better than DisableIOMapper quirk. Works fine with DMAR, leaving it.

Resetting NVRAM is reported to brick certain Thinkpads with certain BIOS versions. Better not to risk that.

Increase max VRAM? Set `framebuffer-unifiedmem` to 0xFFFFFFFF or other. Default one is 1.5 Gb or more?

YogaSMC doesn't need YVPS and \_LID.

### Input devices

Current state:
- VoodooPS2 for keyboard, trackpoint (seems to be PS/2 as well).
- VoodooI2C for trackpad (works without need for GPIO pinning) and touchscreen
- Pen doesn't work.
- Middle trackpoint key doesn't work.
- Several keys work weirdly, require remapping

There are reports that pen could work with VoodooI2C. 

Enter VoodooRMI. Supposedly helps with pen?
Trackpoint (along with buttons) doesn't work, pen doesn't work, and I don't see any trackpad improvements. What's the deal with it?
Ideas:
- Try older 1.2 version that has separate kext for trackpoint
- Be a grownup and open issue with debugging information.
- Ask around if anyone actually managed to make pen work.
- Try to find that UPDD driver from those guys. It's paid, and bloody expensive.

### Extra keys

- [x] Fn-Space works OOB even outside of OS. YogaSMC adds notifications.
- [x] Fn-Esc (FnLock) works OOB and independent of OS. YogaSMC adds notifications.
- [x] Fn-F1 to F3 work OOB. Indicator on F1 works with YogaSMC.
- [x] Fn-F4 (mute mic). Fully works with YogaSMC.
- [x] Fn-F5-F6 work with BrightnessKeys. Check with only YogaSMC.
- [x] Fn-F7 (dual display). Fully works with YogaSMC.
- [x] Fn-F8 (airplane mode). Fully works with YogaSMC.
- [ ] Fn-F9-F11 (custom Windows-only keys) — YogaSMC reports events 0x1317:0 to 0x1319:0. No keyboard events.
- [ ] Fn-F12 (custom key, star) — unclear, YogaSMC doesn't report anything. No keyboard events.
- [ ] Fn-PrnScr (snipping tool) — YogaSMC reports event 0x1312:0. No keyboard events.
- [ ] Fn-Tab (zoom) — YogaSMC reports event 0x1014:0. No keyboard events.
- [ ] Fn-B = Break — keycode not detected. Should it be?
- [ ] Fn-K = Scroll Lock — keycode not detected, works as brightness down.
- [ ] Fn-P = Pause — keycode not detected, works as brightness up.
- [ ] Fn-S = SysRq — keycode detected, shows as Opt-F18, 79/0x4f.
- [x] Fn-4 = Sleep - works, **requires YogaSMC**. Got a reboot with CMOS checksum error without it.
- [x] Fn-Left/Right = Home/End — works.
- [ ] Ctrl-Ins — for *some* reason works as power button, at least with YogaSMC.

There also exists a SSDT fix for Fn-4 sleep crash.
Very rarely YogaSMC actually detects one of Fn-F10-F12 keys. Weird.

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

See acpi/ACPI.md for details.

| Name         | What it is                       |
| ------------ | -------------------------------- |
| SSDT-PLUG    | CPU PluginType enabler           |
| SSDT-USBX    | USB power injection              |
| SSDT-PNLF    | Backlight fix                    |
| SSDT-RTCAWAC | RTC fix                          |
| SSDT-RHUB    | USB hub fix                      |
| SSDT-XOSI    | OS version patches               |
| SSDT‑HPET    | IRQ patches                      |
| SSDT-FIXDEV  | Fixes to some devices.           |
| SSDT-YOGA    | Supplementary SSDT for YogaSMC   |
| SSDT-TB      | Thunderbolt fixes                |
| SSDT-EXTRAS  | Cosmetic device fixes, optional  |
| DMAR         | See below. Requires SSDT-FIXDEV  |

DMAR is a replacement DMA Regions table with protected regions removed. Basically, macOS is incompatible with VT-d without some fix, and you have three options:

- Disable VT-d in BIOS. Best option if you don't need it in other OSes.
- Use DisableIOMapper quirk in OC. OC manual recommend this, but there are also reports that next option sometimes work better.
- Add DMAC device (in SSDT-FIXDEV), remove protected regions in DMAR table and reinject it, dropping original.

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
Authors of all drivers and software used here.
https://github.com/jsassu20/OpenCore-HotPatching-Guide
https://github.com/tylernguyen/x1c6-hackintosh
https://github.com/Jamesxxx1997/thinkpad-x1-yoga-2018-hackintosh
User Balo77 from [OSXLatitude](https://osxlatitude.com/forums/topic/18146-lenovo-thinkpad-x1-yoga-gen-5-type-20ub-20uc/?do=findComment&comment=118324).
