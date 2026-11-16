## Extras

### UTBMap.kext

Premapped USB potrs for this model. Of specific importance is setting several USBs (camera, touchscreen and bluetooth) as internal.

### CPUFriendDataProvider.kext

CPU power profiles. Selected SMBIOS corresponds to Macbook Pro, which this laptop clearly isn't - by default you get too much power throttling. Provided config is more balanced to power-saving, e.g. it sets lowest frequency to 800 instead of 1200. I consider it a good default starting point; run CPUFriendFriend if you want to tune it yourself.

### OTD 0.6.8

Configuration and plugin for OpenTabletDriver to recognize digitizer. Fully functional. 

### VoodooI2CHID.kext

To get both touchscreen and touchpad working you need to install this patched kext. Stock VoodooI2CHID enables reading from digitizer, which gives double readings with OTD. Patch disables it.

### revert-rp72-pen-parse.patch

Aforementioned patch for VoodooI2CHID kext

### fix-bgscan-unref-null.patch

Patch for AirportItlwm. Fixes intermittent kernel panic caused by network scan during roaming switch (usually when using several APs with same SSID).
