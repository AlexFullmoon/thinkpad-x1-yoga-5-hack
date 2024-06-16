# Information on input devices

## Current status

- VoodooPS2 for keyboard and trackpoint.
- VoodooI2C for trackpad (works without need for GPIO pinning) and touchscreen.
- VoodooRMI for some improvements: better trackpoint, no trackpad lag with trackpoint buttons.
- YogaSMC for most Fn keys and other functionality.
- Pen doesn't have pressure detection.
- Middle trackpoint key works only as middle mouse button. See [acidanthera/bugtracker#2263](https://github.com/acidanthera/bugtracker/issues/2263).
- Several keys require (re)mapping. Some Fn keys work even outside of OS, most will require YogaSMC and BrightnessKeys.

VoodooRMI is not strictly required, everything works without it. It fixes an old issue (present both in windows an linux): pressing touchpoint buttons freezes touchpad for half a second.

Note: VoodooRMI requires *only* VoodooRMI, RMII2C and bundled VoodooInput kexts. No VoodooSMBus parts. See kexts part of [README.md](../README.md).

## Pen

Pen support is broken in VoodooI2C (in VoodooI2CHID satellite, to be specific) from version 2.7 to at least 2.8. See [VoodooI2C/VoodooI2C#500](https://github.com/VoodooI2C/VoodooI2C/issues/500) for details. You can:

- Roll back to v.2.6.5. Outdated.
- Use the one I compiled (December 2023). Probably would get outdated before long.
- Wait for devs to release fixed version. Good luck with that.
- Compile VoodooI2CHID from source. See short guide below.

Pen support in VoodooI2C is also limited — no pressure detection. no system integration (e.g. handwriting input like in Windows), essentially a mouse. Frankly, it's amazing it works so well for unsupported hardware.

You might want to try third-party driver [Touch-Base UPDD](https://www.touch-base.com/), it is reported to work on X1Y3, and is supposedly more functional. Unfortunately it did not detect supported devices on my X1Y5, and is quite expensive, anyway.

### Building VoodooI2CHID

Docs are quite outdated, as part of toolchain depends on Python 2. You'll need XCode and some recent Python 3 installed.

```sh
# This uses Python 3 instead of 2, but works fine.
pip3 install cpplint

# You might jump in the rabbit hole that is installing special version of cldoc.
# It requires coffeescript and sass, which require Node 16 and Python 2, and
# still fails when building the project. Luckily there is no need for all that.
# It is needed for documentation only, and kexts are compiled successfully. 
# You can even try installing it from pip3 and ignore Python 2 altogether.

git clone --recursive https://github.com/VoodooI2C/VoodooI2C.git
cd VoodooI2C

# Dependencies
git clone https://github.com/acidanthera/MacKernelSDK

src=$(/usr/bin/curl -Lfs \
    https://raw.githubusercontent.com/acidanthera/VoodooInput/master/VoodooInput/Scripts/bootstrap.sh) \
    && eval "$src" \
    && mv VoodooInput Dependencies

# Update VoodooI2CHID to _latest_ commit. This is what we're here for.
git submodule sync
git submodule update --init --recursive --remote
```

Then in XCode open VoodooI2C folder, go to root of project navigator in left panel, select Build Settings tab and switch Build active architecture from Debug to Release. Press ⌘B to build. Select Product in navigator, and open results folder in right panel.

Grab VoodooI2CHID kext (*not* kext.dSYM). You're done.

## Keyboard

### Current status

| ?  | Key       | Comments                                                          | Kext           |
| -- | --------- | ----------------------------------------------------------------- | -------------- |
| ✔️ | Fn-Space  | Works OOB, even outside of OS.                                    |                |
| ✔️ | Fn-Esc    | Works OOB, even outside of OS                                     |                |
| ✔️ | Fn-F1-F3  | Media keys, work OOB.                                             |                |
| ✔️ | Fn-F4     | Mute mic.                                                         | YogaSMC        |
| ✔️ | Fn-F5-F6  | Brightness down/up.                                               | BrightnessKeys |
| ❌  | Fn-F7     | Dual display. YogaSMC gives notification but doesn't do anything. | YogaSMC        |
| ✔️ | Fn-F8     | Airplane mode. Works with AirportItlwm                            | YogaSMC        |
| ❌  | Fn-F9-F11 | Windows-only keys. Output Event 0x1317:0 to 0x1319:0              | YogaSMC        |
| ❌  | Fn-F12    | Custom key. Unclear. *Sometimes* detected, opens settings.        | YogaSMC        |
| ❌  | Fn-Tab    | Windows HiDPI zoom. Outputs Event 0x1014:0                        | YogaSMC        |
| ❌  | Fn-PrtSc  | Windows Snipping tool. Outputs Event 0x1312:0                     | YogaSMC        |
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

Fn- F9 to F12, Tab, PrtSc do not emit PS2 codes, probably they work via EC queries, caught by YogaSMC. I suspect that YogaSMC events can somehow be used, but how exactly is unclear. Additionally, Fn-F7 shows notification but doesn't seem to do anything. Might be something wrong with my display configuration, though.

BrightnessKeys kext connects to Fn-F5/F6, which output standard EC queries. Meanwhile, VoodooPS2 additionally maps brightness up/down to ADB keys 0x71/0x6b (F15/F14). I cannot unassign brightness change from these without recompiling VoodooPS2Keyboard, so I remap them.

Fn-4 can crash system without patches. System shuts down and on start gives CMOS checksum error. Seems to be due to writes into restricted RTC memory regions, see [docs/Hardware.md](Hardware.md) notes on hibernation. Aside from RTC blacklisting, this can be fixed either with SSDT edit ([TODO] try to find that information again) or simply by installing YogaSMC.

VoodooPS2 can optionally use PrtSc to disable touchpad and keyboard. This is useful for manually locking keyboard in tablet mode for Yoga. To enable that, set variable `RemapPrntScr` to true either in VoodooPS2Keyboard.kext/Info.plist, or via SSDT (recommended). This actually *disables* remapping PrtSc to F13. As PrtSc is so conveniently placed, I remap it to RCmd, and use one of other keys (Fn-P, currently) for keyboard lock.

Keyboard lock works as follows:

- PrtSc - toggles touchpad.
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
 
## Debugging information

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

Some EC queries:

LID method in: `_Q2A`, `_Q2B`

Convertible button (?): `_Q2E`

## Links

[TODO] Add more.

https://www.insanelymac.com/forum/topic/330440-beginners-guide-fix-keyboard-hot-keys-functional-keys/

https://github.com/jsassu20/OpenCore-HotPatching-Guide/tree/master/07-PS2%20keyboard%20mapping%20and%20brightness%20shortcuts
