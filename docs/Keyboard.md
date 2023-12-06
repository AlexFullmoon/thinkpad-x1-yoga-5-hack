# Keyboard keys

## Current status

- [x] Fn-Space works OOB, even outside of OS. YogaSMC adds notifications.
- [x] Fn-Esc (FnLock) works OOB and independent of OS. YogaSMC adds notifications.
- [x] Fn-F1 to F3 work OOB. Indicator on F1 works with YogaSMC.
- [x] Fn-F4 (mute mic). Fully works with YogaSMC.
- [x] Fn-F5-F6 work with BrightnessKeys.
- [ ] Fn-F7 (dual display). YogaSMC shows notification but doesn't seem to do anything.
- [x] Fn-F8 (airplane mode). Fully works with YogaSMC and AirportItlwm.
- [ ] Fn-F9-F11 (custom Windows-only keys) — YogaSMC reports events 0x1317:0 to 0x1319:0.
  - No keyboard events.
- [ ] Fn-F12 (custom key, star) — unclear, YogaSMC doesn't report anything.
  - No keyboard events.
  - Sometimes gets detected, YogaSMC shows special notification, opens settings. Requires debugging, apparently.
- [ ] Fn-PrnScr (snipping tool) — YogaSMC reports event 0x1312:0.
  - No keyboard events.
- [ ] Fn-Tab (zoom) — YogaSMC reports event 0x1014:0.
  - No keyboard events.
- [x] Fn-B = Break — outputs something weird.
  - Correct keycode should be PS2:e046 ABD:deadkey, output in log has extra Ctrl.
  - Actually this is correct behaviour, it maps to Ctrl-Break by default.
  - Remapped to F19.
- [x] Fn-K = Scroll Lock — works, but VoodooPS2 maps it to brightness down.
  - Check if it's possible to un-map it, Fn-F5/f6 with BrightnessKeys kext are enough.
  - Remapped to F17.
- [x] Fn-P = Pause — works, but VoodooPS2 maps it to brightness up.
  - Same, remapped to F16.
- [x] Fn-S = SysRq — works.
  - Curiously, it shows as Opt-F18. Probably intended to work as magic SysRq? Not remapping.
- [x] Fn-4 = Sleep — works, **requires YogaSMC** or certain SSDT patch. Since you'll be using YogaSMC anyway... 
- [x] Fn-Left/Right = Home/End — works.
- [x] PrnScr — works, not used in system.
  - Remapped to RightCmd.
  - Optionally it can be remapped to high F key, e.g. F20, and used to take screenshots.
- [x] Ctrl-Ins — for *some* reason works as power button?
  - Actually this is correct behaviour. Insert doubles as Media Eject key, which is used in a bunch of [default Apple shortcuts](https://support.apple.com/en-us/HT201236) for sleep/reboot/power. Might be unexpected to user — e.g. Ctrl-Cmd-Insert will cause reboot.
  - One option (provided but commented out in SSDT-KEYMAP) is to remap it to Numpad Ins.

I suspect that YogaSMC events can somehow be used, but how exactly is unclear.

Display brightness stuff: BrightnessKeys kext connects to Fn-F5/F6 which output EC queries. Meanwhile, VoodooPS2 additionally maps brightness up/down to ADB keys 0x71/0x6b (F15/F14).

Fn-4 — can crash system without patches. System shuts down and on start gives CMOS checksum error — scary! As I've read somewhere, it's caused by key sending system into non-standard sleep mode. this can be fixed either with SSDT edit ([TODO] try to find that information again) or simply by installing YogaSMC.

## Remapping

To recap, here are currently implemented key remappings:

| Key      | Keycodes    | Maps to  | Keycode |
| -------- | ----------- | -------- | ------- |
| PrtSc    | e037 0x69   | RCmd     | 0x36    |
| Fn-P     | e045 0x71   | F16      | 0x6a    |
| Fn-K     | 46 0x6b     | F17      | 0x40    |
| Fn-B     | e046 0x80   | F19      | 0x50    |
| *PrtSc*  | *e037 0x69* | *F20*    | *0x5a*  |
| *Insert* | *e052 0x92* | *NumIns* | *0x52*  |

Set F16-120 as shortcuts to whatever you like in macOS keyboard settings.

I use SSDT to inject remaps; it is also possible to edit plist in VoodooPS2Keyboard kext, but SSDT is more update-proof.

Insert remap is not enabled by default, uncomment it if you need it. Likewise, if you need default functions of Break for some reason, comment it out. Unfortunately, I don't see how to remove brightness controls from Pause and ScrollLock outside of recompiling VoodooPS2Keyboard.

## Debugging information

| Key    | PS2   | ADB | Comment                                   |
| ------ | ----- | --- | ----------------------------------------- |
| PrtSc  | e0 37 | 69  | Remap to RCmd                             |
| RCmd   | e0 5c | 36  |                                           |
| Fn     | e0 63 | 80  | note: ADB 0x80 = DEADKEY                  |
| Insert | e0 52 | 92  | Remap to Numpad Ins?                      |
| NumIns | 52    | 52  |                                           |
| Break  | e0 46 | 80  | Works. Also adds Ctrl key for reasons     |
| Pause  | e0 45 | 71  | Works, but mapped to brightness           |
| ScrLck | 46    | 6b  | Works, but mapped to brightness           |
| SysRq  | 54    | 44  | Works. Outputs Option-F18 for some reason |

ADB codes for function keys:
f16=6a
f17=40
f18=4f
f19=50
f20=5a

## Links

https://www.insanelymac.com/forum/topic/330440-beginners-guide-fix-keyboard-hot-keys-functional-keys/

https://github.com/jsassu20/OpenCore-HotPatching-Guide/tree/master/07-PS2%20keyboard%20mapping%20and%20brightness%20shortcuts
