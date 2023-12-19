# Yet another Opencore config for Lenovo Thinkpad X1 Yoga 5.

OC 0.9.7 | macOS 13.6.3 | BIOS 1.33

Should work for X1 Carbon 8, possibly also would be useful for X1 Carbon 7 and X1 Yoga 4.

## Why isn't there an EFI folder that I can just drop in and use?

You must build it yourself.

I am also not sure if packaging a bunch of outdated precompiled files is right.

## Hardware

| Part        | Model               | How to enable                                            |
| ----------- | ------------------- | -------------------------------------------------------- |
| CPU         | Comet Lake (10310U) | PluginType is enough                                     |
| GPU         | Intel UHD 620       | WhateverGreen with framebuffer patching                  |
| Ethernet    | Intel i219LM        | IntelMausi. Just works™                                  |
| WiFi        | Intel AX201         | itlwm *or* AirportItlwm                                  |
| Audio       | ALC 285             | AppleALC, layout 71                                      |
| Bluetooth   | Intel AX201         | IntelBluetoothFirmware                                   |
| Keyboard    | Generic PS/2        | VoodooPS2Keyboard, see [docs/Input.md](docs/Input.md)    |
| Trackpad    | I2C, SYNA8006       | VoodooI2C with HID satellite, VoodooRMI                  |
| Trackpoint  | PS/2 mouse          | VoodooPS2Mouse                                           |
| Touchscreen | USB device          | VoodooI2C                                                |
| Wacom pen   | USB device          | VoodooI2C, see details in [docs/Input.md](docs/Input.md) |


See [docs/Hardware.md](docs/Hardware.md) for more details.

## 🚫 Final issues (won't ever work)

- Usual suspects: fingerprint, IR camera (if present), WWAN (if present).
- Internal microphone.
- [DRM playback](https://github.com/acidanthera/WhateverGreen/blob/master/Manual/FAQ.Chart.md) — broken on iGPU.

## ❓ Lesser issues

- Wacom pen has limited functionality.
- Fn keys. Most works with YogaSMC and Brightness keys, but several are missing, mostly Windows-only functions.
- Yoga conversion detection (i.e. rotate screen and disable keyboard) doesn't work.
  - Apparently *Thinkpad* Yogas are not supported by YogaSMC. Consider remapping a key to disable keyboard.
- Thunderbolt
  - Controller appears in system and I can hotplug another monitor over TB/DP.
  - Requires further testing, but as I have no hardware to test, it remains an open issue.
- Hibernation mode isn't working. Yet.

## ⚠️ Warnings

Do not use Fn-4 without YogaSMC, it crashes the system.

Resetting NVRAM is reported to **brick** certain Thinkpads with certain BIOS versions. Might be unrelated to this model, but better not to risk that.

## 🚧 Remaining work

- [ ] Fixing remaining Fn keys — if possible.
- [ ] Fixing Yoga conversion — if possible. ClamshellMode? At least we can disable keyboard.
- [ ] Increase max VRAM?
- [ ] Recheck framebuffer configuration. Is everything there required?
- [ ] Rechecking BIOS options.
- [ ] Final cleaning and public repo.

## BIOS settings

- Config
  - Network
    - Wake-on-LAN → *Disabled* ?
    - UEFI network stack → *Disabled* ?
  - Power
    - Sleep mode → *Linux*
  - Thunderbolt
    - BIOS Assist mode → *Disabled*
    - Security → *Disabled* ?
    - Thunderbolt Preboot → *Disabled* ?
  - Intel AMT → *Disabled* ?
- Security
  - Fingerprint predesktop → *Disabled* ?
  - Secure Boot → *Disabled*; Clear all keys if needed.
  - Virtualization
    - Kernel DMA → *Disabled*
    - Vt-d → see notes on DMAR in next section.
    - Enhanced Windows Biometrics → *Disabled*
  - IO ports
    - I suggest disabling all devices you won't use. 
    - I.e. disable WWAN (if you even have one), fingerprint if you're going to use only macOS.
  - Intel SGX → *Disabled*
  - Device Guard → *Disabled*
- Startup
  - UEFI/Legacy → *UEFI*
  - CSM Support → *Disabled*

There is no CFG lock in BIOS (it's inside engineering menu), and usual ways of switching it (modified GRUB, RU) **do not work**. Reportedly, the only way to toggle it or enable engineering menu is through direct BIOS write, with programmer clip and all, with corresponding dangers (doing that breaks TPM, among other things). Thus we have to use corresponding quirk in OC.

There is no DVMT Prealloc setting (it's inside engineering menu along with CFG Lock), but fortunately it's already 64Mb by default, enough for framebuffer.

## ACPI files

See [docs/ACPI.md](docs/ACPI.md) for more details.

| Name         | What it is                      |
| ------------ | ------------------------------- |
| SSDT-PLUG    | CPU PluginType enabler          |
| SSDT-USBX    | USB power injection             |
| SSDT-PNLF    | Backlight fix                   |
| SSDT-RTCAWAC | RTC fix                         |
| SSDT-RHUB    | USB hub fix                     |
| SSDT-OSI     | OS version patches              |
| SSDT‑HPET    | IRQ patches                     |
| SSDT-FIXDEV  | Fixes to some devices           |
| SSDT-YOGA    | Supplementary SSDT for YogaSMC  |
| SSDT-TB      | Thunderbolt fixes               |
| SSDT-KEYMAP  | Keyboard remaps. Optional       |
| SSDT-EXTRAS  | Cosmetic device fixes, optional |
| DMAR         | See below. Requires SSDT-FIXDEV |

DMAR is a replacement DMA Remapping table with protected regions removed. Basically, macOS is incompatible with VT-d without some fix, and you have three options:

1. Disable VT-d in BIOS. Probably best option if you don't need it in other OSes.
2. Use DisableIOMapper quirk in OC. OC manual recommends this, but there are also reports that next option sometimes work better.
3. Add DMAC device (in SSDT-FIXDEV), remove protected regions in DMAR table and reinject it while dropping original table.

As it could change with BIOS update, **you must make it yourself**, so it is not provided. Use SSDTTime for that.

## Kexts

I am providing UTBMap (USB mapping) and prebuilt VoodooI2CHID (see [docs/Input.md](docs/Input.md) for details). For everything else you should grab latest versions.

- Lilu
- VirtualSMC
  - SMCBatteryManager
  - SMCProcessor
  - SMCSuperIO
  - SMCLightSensor
- WhateverGreen
- AppleALC
- IntelMausi
- *Wireless*
  - itlwm + Heliport *or*
  - AirportItlwm (for specific macOS version)
- *Bluetooth*
  - IntelBluetoothFirmware
  - IntelBTPatcher
  - BlueToolFixup (from BrcmPatchRAM)
- UsbToolbox + map
- *Input*
    - VoodooPS2 for keyboard and trackpoint
    - VoodooI2C for trackpad and touchscreen
    - VoodooRMI for general improvements
    - YogaSMC for Fn keys
- *Other stuff*
    - ECEnabler
    - RestrictEvents
    - NVMEFix
    - *HibernationFixup*
- *Debugging*
  - DebugEnhancer

## Opencore config

Use provided config for reference, follow Dortania guide to build your own for current OpenCore version. Here are some notes:

- ACPI
  - Add all SSDTs, remember to drop DMAR table if using that method.
  - Quirks: none.
- Booter/Quirks
  - `DevirtualiseMmio` is unnecessary.
  - `EnableSafeModeSlide` and thus `ProvideCustomSlide` seems necessary, long boot time if disabled.
- DeviceProperties
  - Audio is at `PciRoot(0x0)/Pci(0x1f,0x3)`.
  - Video is at `PciRoot(0x0)/Pci(0x2,0x0)`, as usual.
- Kernel
  - Kext order: see comments to kext entries in config.
  - Quirks:
    - `AppleXcpmCfgLock` is required, CFG lock cannot be disabled in firmware.
    - `AppleCpuPmCfgLock` is apparently not necessary, though.
    - `CustomSMBIOSGuid` is used for multiboot configuration. If you use only macOS, disable it.
    - `DisableIoMapper` is disabled because I replace DMAR table. See above and [docs/ACPI.md](docs/ACPI.md).
- Misc
  - I use `ScanPolicy` 0x00280F03, which means only NVMe and USB drives and only Apple FS, NTFS and EFI partition.
  - Boot/`LauncherOption` is Full for multiboot configuration. If using only macOS, set to Disabled.
- NVRAM/Bootargs:
  - `rtcfx_exclude=80-AB` — required for hibernation.
  - config_debug also has standard debugging bootargs.
  - Additional UUID E09B... contains HibernationFixup configuration.
- PlatformInfo
  - `UpdateSMBIOSMode` is Custom for multiboot configuration. If using only macOS, set to Create
- UEFI/ReservedMemory
  - One region apparently required for hibernation.

Provided configs differ in enabled debug options and boot picker interface.

## Acknowledgements

Dortania, AcidAnthera team and other people from community.

Authors of all drivers and software used here.

Prebuilt configs I've used:

- https://github.com/jsassu20/OpenCore-HotPatching-Guide
- https://github.com/tylernguyen/x1c6-hackintosh
- https://github.com/Jamesxxx1997/thinkpad-x1-yoga-2018-hackintosh
- User Baio77 from [OSXLatitude](https://osxlatitude.com/forums/topic/18146-lenovo-thinkpad-x1-yoga-gen-5-type-20ub-20uc/?do=findComment&comment=118324).
