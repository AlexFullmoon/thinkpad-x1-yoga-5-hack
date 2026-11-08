# Information on input devices

## Current status

- VoodooPS2 for keyboard and trackpoint.
- VoodooI2C for trackpad (works without need for GPIO pinning).
- Patched VoodooI2CHID for touchscreen (see [Pen](#pen)).
- VoodooRMI for some improvements: better trackpoint, no trackpad lag with trackpoint buttons.
- YogaSMC for most Fn keys and other Thinkpad-specific functionality. Use [my fork](https://github.com/AlexFullmoon/YogaSMC), it fixes some bugs and enables pose detection.
- Pen works natively in macOS (basic pointer), pressure and tilt via OpenTabletDriver, see [Pen](#pen).
- Middle trackpoint key works only as middle mouse button. See [acidanthera/bugtracker#2263](https://github.com/acidanthera/bugtracker/issues/2263).
- Several keys require (re)mapping. Some Fn keys work even outside of OS, most will require YogaSMC and BrightnessKeys.

VoodooRMI is not strictly required, everything works without it. It fixes an old issue (present both in Windows and Linux): pressing touchpoint buttons freezes touchpad for half a second.

Note: VoodooRMI requires *only* VoodooRMI, RMII2C and bundled VoodooInput kexts. No VoodooSMBus parts. See kexts part of [README.md](../README.md).

## Pen

The pen is part of the same USB HID digitizer as the touchscreen (Wacom `056A:5229`), and macOS handles it natively without any kexts — as a basic pointer, without pressure or tilt.

Stock VoodooI2CHID attaches to this USB device as well: its event drivers match any HID interface with digitizer usage, not only I2C ones. Since [VoodooI2CHID#72](https://github.com/VoodooI2C/VoodooI2CHID/pull/72) (see also [VoodooI2C#500](https://github.com/VoodooI2C/VoodooI2C/issues/500)) it also parses the pen, so you get duplicate readings: one from macOS, one from the kext. Touchscreen only works through VoodooI2CHID, so just disabling it is not an option.

The fix is a patched VoodooI2CHID that does not parse pen elements (the patch reverts #72). Ready kext and patch file are in [extras](../extras). With this kext pen won't be detected until you launch OpenTabletDriver.

### OpenTabletDriver

A much better option is OpenTabletDriver. It works in usermode and doesn't require installing kexts. Copy files from [extras/OTD 0.6.8](../extras/OTD%200.6.8) into `~/Library/Application Support/OpenTabletDriver` (configuration to `Configurations/Wacom`, plugin to `Plugins/WacomHidPlugin`), restart OpenTabletDriver, and you'll get fully functional digitizer: pressure (up to 4095), two pen buttons, eraser, tool type and serial number. Plugin source files and build instructions are at [AlexFullmoon/otd-wacom-hid-plugin](https://github.com/AlexFullmoon/otd-wacom-hid-plugin).

- OpenTabletDriver has no parser for this device, so the plugin supplies one (`WacomHidPlugin.WacomHidPenReportParser`). It is built against the Plugin API of this OpenTabletDriver version, so after an update of OpenTabletDriver it might stop loading and need a rebuild.
- Pen reports use Report ID 6 (18 bytes), touch reports use Report ID 12 (40 bytes). The plugin parses touch too, but OpenTabletDriver cannot pass touch input to the system, so it is only visible in Tablet Debugger.
- The bundled pen does not report tilt, but digitizer does — a pen that supports it works (tested up to ±65°).
- Do **not** add the generic Wacom `FeatureInitReport` (`AgI=`) that most Wacom configurations in OpenTabletDriver use. It switches the digitizer to a legacy mode with a different product ID (`056A:0094`) and no usable HID reports, so both OpenTabletDriver and macOS lose the pen until the device is reset (a reboot should do it).
- Byte 15 of the pen report is declared as "battery strength", but it jumps between 0 and 128/255 independently of pen state. Its meaning is not confirmed, so it is not used.

### Building patched VoodooI2CHID

Only the HID satellite is rebuilt. The documentation toolchain of VoodooI2C (cpplint, cldoc, Python 2, Node) is not needed, and neither is VoodooInput — the build doesn't use them. Tested with Xcode 15.2 on macOS 13.7.8; deployment target warnings are harmless.

```sh
git clone --depth 1 https://github.com/VoodooI2C/VoodooI2C.git
cd VoodooI2C
git submodule update --init --depth 1 "VoodooI2C Satellites/VoodooI2CHID" Dependencies/VoodooGPIO
git clone --depth 1 https://github.com/acidanthera/MacKernelSDK.git

cd "VoodooI2C Satellites/VoodooI2CHID"
# Skip this to build stock VoodooI2CHID
git apply /path/to/extras/revert-pr72-pen-parse.patch

xcodebuild -project VoodooI2CHID.xcodeproj -scheme VoodooI2CHID \
    -configuration Release -derivedDataPath /tmp/voodoo-build CODE_SIGNING_ALLOWED=NO
```

The kext appears in `/tmp/voodoo-build/Build/Products/Release/VoodooI2CHID.kext` (x86_64, unsigned — fine for OpenCore).

Provided kext was built from the VoodooI2CHID commit pinned by VoodooI2C master at the time (`2727793`). The patch also applies to the current VoodooI2CHID master (`16f765d`, not built). To use the latest HID commit, run `git checkout origin/master` (after `git fetch`) inside the HID folder before applying the patch.

## Keyboard

### Current status

| ?  | Key       | Comments                                                          | Kext           |
| -- | --------- | ----------------------------------------------------------------- | -------------- |
| ✔️ | Fn-Space  | Works OOB, even outside of OS.                                    |                |
| ✔️ | Fn-Esc    | Works OOB, even outside of OS                                     |                |
| ✔️ | Fn-F1-F3  | Media keys, work OOB.                                             |                |
| ✔️ | Fn-F4     | Mute mic.                                                         | YogaSMC        |
| ✔️ | Fn-F5-F6  | Brightness down/up.                                               | BrightnessKeys |
| ✔️ | Fn-F7     | Toggle mirror display on and off.                                 | YogaSMC        |
| ✔️ | Fn-F8     | Airplane mode. Works with AirportItlwm                            | YogaSMC        |
| ✔️ | Fn-F9     | Opens notification pane (clicks of clock in menubar)              | YogaSMC        |
| ✔️ | Fn-F10-F12| Custom keys, remappable in YogaSMC prefpane.                      | YogaSMC        |
| ✔️ | Fn-Tab    | Windows HiDPI zoom, remappable in YogaSMC prefpane.               | YogaSMC        |
| ✔️ | Fn-PrtSc  | Screenshot tool.                                                  | YogaSMC        |
| ✔️ | Fn-B      | Break. Hardwired to emit Ctrl-Pause. Non-remappable.              | VoodooPS2      |
| ✔️ | Fn-S      | SysRq. Emits Alt-F18 by default. Non-remappable.                  | VoodooPS2      |
| ✔️ | Fn-K      | ScrollLock. Mapped to F14 Brightness down. Remapped.              | VoodooPS2      |
| ✔️ | Fn-P      | Pause. Mapped to F15 Brightness up. Remapped.                     | VoodooPS2      |
| ✔️ | Fn-4      | Sleep. Requires fixing via YogaSMC or crashes the system.         | YogaSMC        |
| ✔️ | Fn-H/M/L  | Performance mode High/Medium/Low.                                 | YogaSMC        |
| ✔️ | Fn-←/→    | Home/End. Work OOB.                                               |                |
| ✔️ | PrtSc     | By default mapped to F13. Remapped to RCmd.                       | VoodooPS2      |
| ✔️ | Insert    | Doubles as Media Eject, used in several unexpected shortcuts.     |                |


### Notes

YogaSMC adds notifications to most Fn keys.

BrightnessKeys kext connects to Fn-F5/F6, which output standard EC queries. Meanwhile, VoodooPS2 additionally maps brightness up/down to ADB keys 0x71/0x6b (F15/F14). I cannot unassign brightness change from these without recompiling VoodooPS2Keyboard, so I remap them.

Fn-4 can crash system without patches. System shuts down and on start gives CMOS checksum error. Seems to be due to writes into restricted RTC memory regions, see [docs/Hardware.md](Hardware.md) notes on hibernation. Aside from RTC blacklisting, this can be fixed either with SSDT edit ([TODO] try to find that information again) or simply by installing YogaSMC.

VoodooPS2 can optionally use PrtSc to disable touchpad and keyboard. This is useful for manually locking keyboard. To enable that, set variable `RemapPrntScr` to true either in VoodooPS2Keyboard.kext/Info.plist, or via SSDT (recommended). This actually *disables* remapping PrtSc to F13. As PrtSc is so conveniently placed, I remap it to RCmd, and use one of other keys (Fn-P, currently) for keyboard lock.

Keyboard lock works as follows:

- PrtSc (now Fn-P) - toggles touchpad.
- Win-PrtSc (i.e. LCmd-PrtSc) - toggles touchpad *and* keyboard.
- Ctrl-Alt-PrtSc - reset and enable touchpad (don't know how useful is this).
- Shift-PrtSc - SysRq interrupt.

Toggling keyboard lock mapping can also be done in runtime via `ioio -s ApplePS2Keyboard RemapPrntScr true`. Likewise, logging keypresses can be done by executing `ioio -s ApplePS2Keyboard LogScanCodes 1`, and then reading dmesg output with `sudo dmesg | grep ApplePS2Keyboard`. `ioio` can be found [here](https://bitbucket.org/RehabMan/os-x-ioio/downloads/).

Regarding SysRq and Break keys, from some Linux man page: 

> The two keys PrintScrn/SysRq and Pause/Break are special in that they have two keycodes: the former has keycode 84 when Alt is pressed simultaneously, and keycode 99 otherwise; the latter has keycode 101 when Ctrl is pressed simultaneously, and keycode 119 otherwise. The Pause/Break key is also special in another way: it does not generate key-up scancodes, but generates the entire 6-scancode sequence on key-down.

This seems to be emulated by VoodooPS2Keyboard, and that logic seems to execute before remapping. This means that SysRq and Break are not remappable (and not usable) because they always add Ctrl or Alt to (weird) keypresses. Unfortunate, because they are so conveniently placed.

Insert doubles as Media Eject key, which is used in a bunch of [default Apple shortcuts](https://support.apple.com/en-us/HT201236) for sleep/reboot/power. This might be unexpected — e.g. Ctrl-Cmd-Insert will cause reboot. 

Fn and Ctrl could be swapped in BIOS. Regardless of this, bottom left key by itself sends System Wake keycode, and is the only key on keyboard that wakes laptop.

### Remapping

To recap, here are currently implemented key remappings:

| Key    | Keycodes | Maps to | Keycode |
| ------ | -------- | ------- | ------- |
| PrtSc  | e037     | RCmd    | e05c    |
| Fn-P   | e045     | PrtSc   | e037    |
| *Fn-P* | *e045*   | *F16*   | *67*    |
| Fn-K   | 46       | F17     | 68      |

Set F16-F17 as shortcuts to whatever you like in macOS keyboard settings.

I use SSDT to inject remaps; it is also possible to edit plist in VoodooPS2Keyboard kext, but SSDT is more update-proof.
 
### Extras

Some key codes:

| Key    | PS2   | ADB |
| ------ | ----- | --- |
| PrtSc  | e0 37 |     |
| RCmd   | e0 5c | 36  |
| Fn     | e0 63 | 80  |
| Insert | e0 52 | 92  |
| NumIns | 52    | 52  |
| Break  | e0 46 | 80  |
| Pause  | e0 45 | 71  |
| ScrLck | 46    | 6b  |
| SysRq  | 54    | 44  |
| F16    | 67    | 6a  |
| F17    | 68    | 40  |
| F18    | 69    | 4f  |
| F19    | 70    | 50  |
| F20    | 71    | 5a  |

Note: ADB 0x80 = DEADKEY, keys caught by VoodooPS2Keyboard, e.g. PrtSc, report 0x0.

Full list of keycodes: https://github.com/acidanthera/VoodooPS2/blob/master/VoodooPS2Keyboard/ApplePS2ToADBMap.h

## Links

https://www.insanelymac.com/forum/topic/330440-beginners-guide-fix-keyboard-hot-keys-functional-keys/

https://github.com/jsassu20/OpenCore-HotPatching-Guide/tree/master/07-PS2%20keyboard%20mapping%20and%20brightness%20shortcuts
