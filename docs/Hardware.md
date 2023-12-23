# Hardware details

## Video

WhateverGreen obviously works, but we also need some extra framebuffer finetuning and more. Here are some comments to DeviceProperties in config. Note that I have 4K internal display, for FHD/2K some options are not necessary.

| property                          | value      | what it does                                       |
| --------------------------------- | ---------- | -------------------------------------------------- |
| `AAPL,ig-platform-id`             | 0x00009b3e | Framebuffer IDs.                                   |
| `device-id`                       | 0x93be0000 | Framebuffer IDs.                                   |
| `AAPL,GfxYTile`                   | 0x01000000 | Fix for probable glitch on UHD 620 on 10.14+.      |
| `dpcd-max-link-rate`              | 0x14000000 | Value for 4K display. If yours isn't, remove it.   |
| `rps-control`                     | 0x01000000 | Supposedly improves performance.                   |
| `enable-backlight-registers-fix`  | 0x01000000 | Backlight bug fix.                                 |
| `enable-dpcd-max-link-rate-fix`   | 0x01000000 | DPCD divide-by-zero fix. Just in case.             |
| `enable-max-pixel-clock-override` | 0x01000000 | Needed for 4K display.                             |
| `force-online`                    | 0x01000000 | Fix for black screen on boot. Just in case.        |
| `framebuffer-unifiedmem`          | 0x00000080 | Raises VRAM to 2Gb. Recommended for 4K displays.   |
| `framebuffer-...`                 |            | Setting correct framebuffer connectors and values. |

For a little extra fluff you can grab stock Lenovo color profiles (so it won't show Unknown Display). 

- Go to Lenovo support, grab "Monitor INF driver", unpack it (in Windows), you'll get a bunch of .icm files.
- Check Hardware IDs in device manager, it'll be something like LEN4168 (depending on panel type). 
- Find .icm files with those numbers, e.g. TPLCD_4168_SDR.icm, etc.
- In macOS copy them to /Library/ColorSync/Profiles/Displays. You can also open them with ColorSync and edit description. 

## Sleep and hibernation

Sleep works. Just toggle sleep mode in BIOS to Linux and you're done.

Basically, there are two options in BIOS Config/Power: Linux and Windows 10. Former is standard S3 sleep, latter is Modern Standby aka S0 low power idle aka AOAC mode, a Microsoft-invented abomination that tries to make a smartphone out of your laptop. Meaning it doesn't really power down and due to various glitches might wake up and drain all battery. Supposedly Windows 10 mode helps with low-frequency-after-wake bug in Windows, so enable it only if you really need it.

Only Fn key wakes laptop from sleep, rest of keyboard doesn't. This is normal behaviour and hard-wired in BIOS.

Hibernation easy mode: disable hibernation by executing `sudo pmset -a hibernatemode 0` etc.

Hibernation hard mode:

Enabling hibernation on this model is initially trickier than usual due to Lenovo firmware using some RTC memory blocks. Without fix you'll get CMOS errors on resume and fail. Current situation:

- First we need to block writes to some RTC memory addresses. I'm using range 0x80-0xAB found [here](https://github.com/tylernguyen/x1c6-hackintosh/issues/44). This range was found on X1 Carbon 6, but firmware logic seems same. Either:
  - Add RTCMemoryFixup kext and bootarg `rtcfx_exclude=80-AB`. This way works, i.e. I do not get CMOS errors.
  - Set NVRAM variable `rtc-blacklist to 808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAAB`
    - This does not seem to work work as-is, probably requires something else (UEFI/ProtocolOverride?)
- Add HibernationFixup kext with at least `hbfx-ahbm=1` (refer to github readme for details) and set Misc/Boot/HibernateMode to NVRAM.
- Add ReservedMemory region in UEFI block. this should fix black screen on resuming from hibernation. No idea where it is from.
- Enable hibernation in OS with `sudo pmset -a hibernatemode 3`, `sudo pmset -a standby 1`.

Hibernation mode 25 doesn't work. Resuming from it results in hang up with garbled screen.

Some glitches seem to happen after resuming from hibernation: Bluetooth requires switching off and on, YogaSMC preference pane glitches a bit...

## Audio

First of all, internal mic is **unsupported**, end of the line. It's a microphone array powered by Intel Smart Sound Technology.

In short, AppleALC works by explaining to native AppleHDA how to connect with audio layouts inside HDA chip that it doesn't know. What we have here is a separate chip that has nothing to do with HDA, so neither AppleALC nor VoodooHDA support that. Unless someone writes a completely new driver, there's nothing to be done.

Out of available layouts the best one is **71**. Both sets of speakers work, jack is fully functional. Second best is 66, if you need it for some reason — other layouts use top speakers, which are tweeters and not usable alone.

Unfortunately, macOS can use only one device for output. One solution is to make an aggregate device in MIDI settings, but then you lose some QoL like volume control and autoswitching to headphones. You can install third-party volume control, like [AggregateVolumeMenu](https://github.com/adaskar/AggregateVolumeMenu) or something more advanced like [SoundSource](https://rogueamoeba.com/soundsource/).

Result of testing different audio layouts.

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

Both variants — itlwm + HeliPort and AirportItlwm — work. Caveats: 

- itlwm lacks some QoL things: YogaSMC doesn't disable it with Fn-F8, terminal scripts that work with airport utility will fail, etc. HeliPort app is well-made, though.
- AirportItlwm is more native, but I had some (albeit rare) kernel panics and some cases when WiFi after sleep had no connection until I disabled and reenabled it. Also, note that it requires different kexts for different OS versions. At time of writing the latest supported by stable version was Ventura.