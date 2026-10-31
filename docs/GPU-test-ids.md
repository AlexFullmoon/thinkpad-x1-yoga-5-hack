# iGPU ID pairs to test

Candidates for `AAPL,ig-platform-id` / `device-id` (UHD 620, Comet Lake, 4K internal panel). Values are shown as they appear in OpenCore (`Data`, byte-reversed).

Change one pair at a time, keep the rest of DeviceProperties, and check: acceleration (VRAM > 7 MB), 4K at 60 Hz (if available), HDMI hotplug, sleep/wake, brightness, video playback, performance.
Note that `framebuffer-con1/con2` patches are tuned for the current framebuffer; disable them (or remove `framebuffer-patch-enable`) when testing a different one.

| # | ig-platform-id (Data) | = platform | device-id (Data) | = device | Notes |
| - | --------------------- | ---------- | ---------------- | -------- | ----- |
| 1 | `00009B3E`            | 0x3E9B0000 | `9B3E0000`       | 0x3E9B   | [Dortania](https://dortania.github.io/OpenCore-Install-Guide/config-laptop.plist/coffee-lake-plus.html) recommendation for UHD 620 on Comet Lake. |
| 2 | `0900A53E`            | 0x3EA50009 | `A53E0000`       | 0x3EA5   | WhateverGreen mobile CFL/CML FB, 3 connectors, 58 MB stolen. Matches its native device-id. |
| 3 | `0900A53E`            | 0x3EA50009 | `C89B0000`       | 0x9BC8   | Used by [X1C8 repo](https://github.com/HJebbour/ThinkPad-X1C8-Hackintosh). |
| 4 | `00009B3E`            | 0x3E9B0000 | `C89B0000`       | 0x9BC8   | Dortania FB with X1C8 device-id. |
| 5 | `0900A53E`            | 0x3EA50009 | none (native)    | 0x9B41   | Real ID of 10310U iGPU, no spoof. Verify yours in Windows/`gfxutil`. **Doesn't boot** |
| 6 | `0000A53E`            | 0x3EA50000 | `A53E0000`       | 0x3EA5   | Default FB WhateverGreen assumes when platform-id is missing. |
| 7 | `0000A53E`            | 0x3EA50000 | none             |          | Same, no device-id at all; baseline "does it work out of the box". |
| 8 | `07009B3E`            | 0x3E9B0007 | `9B3E0000`       | 0x3E9B   | Desktop/NUC FB (3 connectors, no eDP assumed). Last resort, expect internal display issues. |

The stolen memory of 3EA50009 and 3E9B0000 is 58 MB, covered by the default DVMT pre-alloc of 64 MB.
