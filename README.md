# Yet another Opencore config for Lenovo Thinkpad X1 Yoga 5.

OC 1.0.5 | macOS Sonoma 14.8.1 | BIOS 1.39

Build is considered complete. Should work for X1 Carbon 8, possibly also would be useful for X1 Carbon 7 and X1 Yoga 4.

## Why isn't there an EFI folder that I can just drop in and use?

You must build it yourself.

Also, I don't think that packaging a bunch of outdated precompiled files is right.

## Hardware

| Part        | Model               | How to enable                                            |
| ----------- | ------------------- | -------------------------------------------------------- |
| CPU         | Comet Lake (10310U) | PluginType is enough                                     |
| GPU         | Intel UHD 620       | WhateverGreen, see [docs/Hardware.md](docs/Hardware.md)  |
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

- Fingerprint, IR camera (if present), WWAN (if present).
- Internal microphone.
- [DRM playback](https://github.com/acidanthera/WhateverGreen/blob/master/Manual/FAQ.Chart.md) — broken on iGPU.

## ❓ Lesser issues

- Wacom pen has limited functionality.
- Fn keys. Most works with YogaSMC and Brightness keys, but several are missing, mostly Windows-only functions.
- Yoga conversion detection (i.e. rotate screen and disable keyboard) doesn't work.
  - Apparently *Thinkpad* Yogas are not supported by YogaSMC.
  - You can manually disable keyboard and touchpad (but not trackpoint, currently).
- Thunderbolt
  - Controller appears in system and I can hotplug another monitor over TB/DP.
  - Requires further testing, but as I have no hardware to test, it remains an open issue.

## ⚠️ Warnings

Do not press Fn-4 without installing YogaSMC, it crashes the system.

Resetting NVRAM is reported to **brick** certain Thinkpads (X1 Extreme 1 and 2?) with certain BIOS versions. Most likely completely unrelated to this model, and other users report no issues, so take this warning as additional disclaimer of warranty. 

## ⚠️ Sonoma notes

1. Sonoma requires specific version of AirportItlwm. Also, version 14.4 and above require yet another version.

2. Installing Sonoma above 14.4 requires setting Misc/Security/SecureBootModel to 'Disabled'. This is required *only* at installation time, and should be set to `Default` or to SMBios-specific value (j223 for MacBookPro16,3) afterwards.

3. Overall I find Sonoma to be less performant than Ventura, but it has one more year of support from brew.

## BIOS settings

*Italics* — supposed to work either way, but recommended setting should reduce debugging surface

**Bold** — required settings

- Config
  - Network
    - Wake-on-LAN → *Disabled*
    - UEFI network stack → *Disabled*
  - Power
    - Sleep mode → **Linux**
  - Thunderbolt
    - BIOS Assist mode → *Disabled*
    - Security → *Disabled*
    - Thunderbolt Preboot → *Disabled*
  - Intel AMT → *Disabled*
- Security
  - Fingerprint predesktop → *Disabled*
  - Secure Boot → **Disabled**; Clear all keys if needed.
  - Virtualization
    - Kernel DMA → *Disabled*
    - Vt-d → **Disable** this or enable DisableIOMapper quirk. Disabling in BIOS recommended for macOS-only configuration.
    - Enhanced Windows Biometrics → **Disabled**
  - IO ports
    - I suggest disabling all devices you won't use. 
    - In particular, disable WWAN (if you even have one), fingerprint if you're going to use only macOS.
  - Intel SGX → **Disabled**
  - Device Guard → **Disabled**
- Startup
  - UEFI/Legacy → **UEFI**
  - CSM Support → **Disabled**

There is no CFG lock available in BIOS (it's inside engineering menu), and usual ways of switching it (modified GRUB, RU) **do not work**. Reportedly, the only way to toggle it or enable engineering menu is through direct BIOS write, with programmer clip and all, and with corresponding dangers (doing that breaks TPM, among other things).

Surprisingly, system boots just fine with AppleXcpmCfgLock quirk disabled. As [Voice of God](https://github.com/acidanthera/bugtracker/issues/2355#issuecomment-2779677232) said, *On some newer CPUs macOS can work even with Cfg Lock. Depending on the BIOS performance may be suboptimal, however.* AppleCpuPmCfgLock is not required on modern macOS at all. 

There is no DVMT Prealloc setting (rather, it's inside engineering menu along with CFG Lock), but fortunately it's already 64Mb by default, enough for framebuffer.

According to one source, setting Thunderbolt / BIOS Assist mode *Enabled* results in Thunderbolt hotplug not working but decreased battery consumption.

Intel AMT is remote administration for enterprise. This switch does not actually turn it off (it's built in CPU, see [1](https://www.reddit.com/r/thinkpad/comments/ae9qsy/permanently_disabled_intel_amt_did_i_fuck_up/) [2](https://libreboot.org/faq.html#intel)), just disables management interface.

Secure boot can be enabled, but requires signing Opencore binaries and adding your signing key to Secureboot db. You can use my [sbsign script](https://github.com/AlexFullmoon/sbsign).
**DO NOT wipe stock Secureboot keys**, this has been reported to brick Thinkpads; add single key into db instead (minimal mode in sbsign).

## ACPI files

See [docs/ACPI.md](docs/ACPI.md) for more details.

| Name         | What it is                      |
| ------------ | ------------------------------- |
| SSDT-PLUG    | CPU power management            |
| SSDT-USBX    | USB power injection             |
| SSDT-PNLF    | Backlight fix                   |
| SSDT-RTCAWAC | RTC fix                         |
| SSDT-RHUB    | USB hub fix                     |
| SSDT-OSI     | OS version patches              |
| SSDT‑HPET    | IRQ patches                     |
| SSDT-FIXDEV  | Fixes for some devices          |
| SSDT-YOGA    | Supplementary SSDT for YogaSMC  |
| SSDT-TB      | Thunderbolt fixes               |
| SSDT-KEYMAP  | Keyboard remaps                 |
| SSDT-EXTRAS  | Cosmetic device fixes, optional |

## Kexts

I am providing UTBMap (USB mapping). For everything else you should grab latest versions.

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
    - HibernationFixup
    - RTCMemoryFixup
- *Debugging*
  - DebugEnhancer

## OpenCore config

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
    - `AppleXcpmCfgLock` and `AppleCpuPmCfgLock` — see BIOS section.
    - `CustomSMBIOSGuid` is used for multiboot configuration. If you use only macOS, disable it.
    - `DisableIoMapper` is required unless you disable Vt-d in BIOS. Quirk recommended for multiboot configuration.
- Misc
  - I use `ScanPolicy` 0x00280303, which means only NVMe and USB drives and only Apple FS partitions.
    - For OpenLinuxBoot 0x00284303 adds Linux bootloader partition (you still need corresponding driver for it).
  - Boot/`LauncherOption` is `Full` for multiboot configuration. For installer or when using only macOS, it should be set to `Disabled`.
  - Security/`SecureBootModel` should be set to `Disabled` for installing/updating Sonoma above certain version, and to `j223` for normal use (value for this SMBios only, see [Dortania article](https://dortania.github.io/OpenCore-Post-Install/universal/security/applesecureboot.html#securebootmodel)). 
- NVRAM/Bootargs:
  - `rtcfx_exclude=80-AB` — required for hibernation.
  - `revpatch=sbvmm` — RestrictEvent options, sbvmm is required for system upgrades to Sonoma and above.
  - config_installer also has standard debugging bootargs.
  - Additional UUID E09B... contains HibernationFixup configuration.
- PlatformInfo
  - `UpdateSMBIOSMode` is `Custom` for multiboot configuration. If using only macOS, set to `Create`.
- UEFI/ReservedMemory
  - One region that is apparently required for hibernation.

Provided configs differ mainly in enabled debug options and boot picker interface.

## Acknowledgements

Dortania, AcidAnthera team and other people from community.

Authors of all drivers and software used here.

Prebuilt configs I've used:

- https://github.com/jsassu20/OpenCore-HotPatching-Guide
- https://github.com/tylernguyen/x1c6-hackintosh
- https://github.com/Jamesxxx1997/thinkpad-x1-yoga-2018-hackintosh
- User Baio77 from [OSXLatitude](bio).
