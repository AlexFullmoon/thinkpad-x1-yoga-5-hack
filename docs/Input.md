# Information on input devices

## Current status

**Important!** Do not use Fn-4 without YogaSMC, it crashes the system.

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

## Keyboard Fn keys

### Current status

- [x] Fn-Space works OOB, even outside of OS. YogaSMC adds notifications.
- [x] Fn-Esc (FnLock) works OOB and independent of OS. YogaSMC adds notifications.
- [x] Fn-F1 to F3 work OOB. Indicator on F1 works(?) with YogaSMC.
- [x] Fn-F4 (mute mic). Fully works with YogaSMC.
- [x] Fn-F5-F6 work with BrightnessKeys.
- [ ] Fn-F7 (dual display). YogaSMC shows notification but doesn't seem to do anything.
  - Might be something to do with my monitor configuration.
- [x] Fn-F8 (airplane mode). Fully works with YogaSMC and AirportItlwm.
- [ ] Fn-F9-F11 (custom Windows-only keys) — YogaSMC reports events 0x1317:0 to 0x1319:0.
  - No keyboard events.
- [ ] Fn-F12 (custom key, star) — unclear, YogaSMC doesn't report anything.
  - No keyboard events.
  - Sometimes gets detected, YogaSMC shows special notification, opens settings. Requires debugging, apparently.
- [ ] Fn-PrtSc (snipping tool) — YogaSMC reports event 0x1312:0.
  - No keyboard events.
- [ ] Fn-Tab (zoom) — YogaSMC reports event 0x1014:0.
  - No keyboard events.
- [x] Fn-B = Break — outputs something weird.
  - Correct keycode should be PS2:e046 ABD:0x80, output in log has extra Ctrl.
  - Actually this is correct behaviour, it maps to Ctrl-Break by default.
  - Remapped to F19.
- [x] Fn-K = Scroll Lock — works, but VoodooPS2 maps it to brightness down.
  - Unclear if it's possible to un-map it, as we already have Fn-F5/F6 for that.
  - Remapped to F17.
- [x] Fn-P = Pause — works, but VoodooPS2 maps it to brightness up.
  - Same, remapped to F16.
- [x] Fn-S = SysRq — works.
  - Curiously, it shows as Opt-F18. Probably intended to work as Magic SysRq key? Not remapping.
- [x] Fn-4 = Sleep — works, **requires YogaSMC** or certain SSDT patch. We'll be using YogaSMC anyway. 
- [x] Fn-Left/Right = Home/End — works.
- [x] Fn-H/M/L = Performance mode High/Med/Low — work. No notifications.
- [x] PrtSc — works, not used in system.
  - Remapped to RightCmd.
  - Optionally it can be remapped to high F key, e.g. F20, and used to take screenshots or whatever.
- [x] Ctrl-Ins — for *some* reason works as power button?
  - Actually this is correct behaviour. Insert doubles as Media Eject key, which is used in a bunch of [default Apple shortcuts](https://support.apple.com/en-us/HT201236) for sleep/reboot/power.
  - Might be unexpected to user — e.g. Ctrl-Cmd-Insert will cause reboot.
  - One option (provided but commented out in SSDT-KEYMAP) is to remap it to Numpad Ins.

I suspect that YogaSMC events can somehow be used, but how exactly is unclear.

Display brightness stuff: BrightnessKeys kext connects to Fn-F5/F6, which output EC queries. Meanwhile, VoodooPS2 additionally maps brightness up/down to ADB keys 0x71/0x6b (F15/F14).

Fn-4 — can crash system without patches. System shuts down and on start gives CMOS checksum error. Probably related to RTC memory regions, see [docs/Hardware.md](docs/Hardware.md) notes on hibernation. As I've read somewhere, it's caused by key sending system into non-standard sleep mode. Aside from RTC blacklisting, this can be fixed either with SSDT edit ([TODO] try to find that information again) or simply by installing YogaSMC.

### Remapping

To recap, here are currently implemented key remappings (last two are disabled):

| Key      | Keycodes    | Maps to  | Keycode |
| -------- | ----------- | -------- | ------- |
| PrtSc    | e037 0x69   | RCmd     | 0x36    |
| Fn-P     | e045 0x71   | F16      | 0x6a    |
| Fn-K     | 46 0x6b     | F17      | 0x40    |
| Fn-B     | e046 0x80   | F19      | 0x50    |
| *PrtSc*  | *e037 0x69* | *F20*    | *0x5a*  |
| *Insert* | *e052 0x92* | *NumIns* | *0x52*  |

Set F16-F20 as shortcuts to whatever you like in macOS keyboard settings. If you need original function of e.g. Break, comment it out. You can also disable any key by remapping it to ADB deadkey 0x80, e.g. `"e037=80"`.

Unfortunately, I don't see how to remove brightness controls from Pause and ScrollLock outside of recompiling VoodooPS2Keyboard.

I use SSDT to inject remaps; it is also possible to edit plist in VoodooPS2Keyboard kext, but SSDT is more update-proof.
 
## Debugging information

Some key codes:
| Key    | PS2   | ADB |
| ------ | ----- | --- |
| PrtSc  | e0 37 | 69  |
| RCmd   | e0 5c | 36  |
| Fn     | e0 63 | 80  |
| Insert | e0 52 | 92  |
| NumIns | 52    | 52  |
| Break  | e0 46 | 80  |
| Pause  | e0 45 | 71  |
| ScrLck | 46    | 6b  |
| SysRq  | 54    | 44  |
| F16    |       | 6a  |
| F17    |       | 40  |
| F18    |       | 4f  |
| F19    |       | 50  |
| F20    |       | 5a  |

Note: ADB 0x80 = DEADKEY

Full list of keycodes: https://github.com/acidanthera/VoodooPS2/blob/master/VoodooPS2Keyboard/ApplePS2ToADBMap.h

Some EC queries:

LID method in: `_Q2A`, `_Q2B`

Convertible button (?): `_Q2E`

## Links

[TODO] Add more.

https://www.insanelymac.com/forum/topic/330440-beginners-guide-fix-keyboard-hot-keys-functional-keys/

https://github.com/jsassu20/OpenCore-HotPatching-Guide/tree/master/07-PS2%20keyboard%20mapping%20and%20brightness%20shortcuts
