# Hardware details

## Video

WhateverGreen obviously works, but we also need some extra framebuffer finetuning and more. Here are comments to DeviceProperties in config. Note that I have 4K internal display, for FHD/2K some options are not necessary.

| property                          | value      | what it does                                       |
| --------------------------------- | ---------- | -------------------------------------------------- |
| `AAPL,ig-platform-id`             | 0x00009b3e | Framebuffer IDs.                                   |
| `device-id`                       | 0x93be0000 | Framebuffer IDs.                                   |
| `AAPL,GfxYTile`                   | 0x01000000 | Fix for probable glitch on UHD 620 on 10.14+.      |
| `dpcd-max-link-rate`              | 0x14000000 | Value for 4K display. If yours isn't, remove it.   |
| `enable-backlight-registers-fix`  | 0x01000000 | Backlight bug fix.                                 |
| `enable-dpcd-max-link-rate-fix`   | 0x01000000 | DPCD divide-by-zero fix. Just in case.             |
| `enable-max-pixel-clock-override` | 0x01000000 | Needed for 4K display.                             |
| `force-online`                    | 0x01000000 | Fix for black screen on boot. Just in case.        |
| `framebuffer-...`                 |            | Setting correct framebuffer connectors and values. |

Optional: to increase max VRAM set `framebuffer-unifiedmem` to 0xFFFFFFFF or other value. Default one is 1.5 Gb. Test if this is stable.

## 🚧 Sleep and hibernation

Sleep mostly just works. One thing to consider is choosing between S3 and Modern standby modes in BIOS (Linux and Windows 10 respectively). Former is more battery-friendly (i.e. other option might drain your battery overnight) and is strictly preferred if you're running only macOS. Latter is better for Windows (helps with low-frequency-after-wake bug and generally improves responsiveness).

[TODO] SSDT patch to switch sleep to S3 mode in macOS regardless of BIOS setting. There is one for 

Hibernation easy mode: disable hibernation by executing `sudo pmset -a hibernatemode 0`.

Hibernation hard mode:

Enabling hibernation on this model is slightly trickier than usual due to Lenovo firmware using some memory blocks. Without fix you'll get CMOS errors on resume and fail. Current situation:

- First we need to block some RTC memory addresses from writes because Lenovo uses them. I'm using range 0x80-0xAB found [here](https://github.com/tylernguyen/x1c6-hackintosh/issues/44). This range was found on X1 Carbon 6, but firmware logic seems similar enough. To protect, either:
  - Add RTCMemoryFixup kext and bootarg `rtcfx_exclude=80-AB`. This way works, i.e. I do not get CMOS errors.
  - Set NVRAM variable `rtc-blacklist=808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAAB`
    - Or in reverse order?
    - This does not work as-is, and seems to require something else (setting ProtocolOverride?)
- Add HibernationFixup kext and set Misc/Boot/HibernateMode to Auto or NVRAM.
- *Supposedly* add ReservedMemory region in UEFI block. this should fix black screen on resuming from hbernation.
- *Supposedly* fiddle with Booter quirks, in particular DiscardHibernationMap.
- Enable hibernation in-system with `sudo pmset -a hibernatemode 3` or `sudo pmset -a hibernatemode 25` for testing.

Current state: entering hibernation works, resuming gets me to OC, choosing macOS shows me hibernation screen, but then it hangs up with garbled screen.

Also fiddling with booter quirks seems to increase boot time for unclear reasons.

## Audio

First of all, internal mic is **unsupported**, end of the line. It's a microphone array powered by Intel Smart Sound Technology.

In short, AppleALC works by explaining to native AppleHDA how to connect with audio layouts inside HDA chip that it doesn't know. What we have is a separate chip that has nothing to do with HDA, so neither AppleALC nor VoodooHDA support that. Unless someone writes a completely new driver, there's nothing to be done.

Out of available layouts the best one is **71**. Both sets of speakers work, jack is fully functional. Second best is 66, if you need it for some reason — other layouts use top speakers, which are tweeters and not usable alone.

Unfortunately, macOS can use only one device for output. One solution is to make an aggregate device in MIDI settings, but then you lose some QoL like volume control and autoswitching to headphones. You can install third-party volume control, like [AggregateVolumeMenu](https://github.com/adaskar/AggregateVolumeMenu) or something more advanced like [SoundSource](https://rogueamoeba.com/soundsource/).

Result of testing of different audio layouts.

| ID | Speakers | Jack out | Jack in | Comments                                       |
| -- | -------- | -------- | ------- | ---------------------------------------------- |
| 11 | Top      | Yes      | Yes     |                                                |
| 21 | Top      | Yes      | Yes     | Jack in not detected as headphones.            |
| 31 | Top      | Yes      | Yes     |                                                |
| 52 | Top      | Yes      | Broken? |                                                |
| 61 | Top      | Yes      | Yes     |                                                |
| 66 | Bottom   | Yes      | Yes     |                                                |
| 71 | Both     | Yes      | Yes     | Best one. Requires aggregate device.           |
| 88 | Top      | Yes      | Yes     | Headphones on separate channel without switch. |

## Ethernet

Just in case you're wondering — yes, Lenovo's ethernet adapters just work, they simply convert proprietary plug into 8P8C, there's no extra logic inside.

I have model EX280, P/N Sc10P42352, FRU 01YU026. There are several compatible P/N.

## WiFi

Both variants — itlwm + HeliPort and AirportItlwm — work. 

- itlwm lacks some minor QoL things: YogaSMC doesn't disable it with Fn-F8, terminal scripts that work with airport utility will fail, etc. HeliPort app is well-made.
- AirportItlwm is more native, but I had some cases when WiFi after sleep had no connection until I disabled and reenabled it. Further testing required. Also, note that it requires different kexts for different OS versions. At time of writing the latest supported by stable version was Ventura.