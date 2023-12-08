# Hardware details

## Video

WhateverGreen obviously works, but we also need some extra framebuffer finetuning and more. Here are comments to DeviceProperties in config. Note that I have 4K internal display, for FHD/2K some options are not necessary.

Some options may not be necessary, require testing.

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

Just in case you're wondering — yes, Lenovo's ethernet adapters just work, they simply convert proprietary plug into 8P8C, no extra logic.

I have model EX280, P/N Sc10P42352, FRU 01YU026. There are several compatible P/N.

## WiFi

Both variants — itlwm + HeliPort and AirportItlwm — work. 

- itlwm lacks some minor QoL things: YogaSMC doesn't disable it with Fn-F8, terminal scripts that work with airport utility will fail, etc. HeliPort app is well-made. 
- AirportItlwm is more native, but I had some cases when WiFi after sleep had no connection until I disabled and reenabled it. Further testing required. Also, at time of writing there is no release for Sonoma.