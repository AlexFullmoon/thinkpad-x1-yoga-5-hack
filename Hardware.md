# Hardware details

## Audio

First of all, internal mic is **unsupported**, end of the line. It's a microphone array powered by Intel Smart Sound Technology.

In short, AppleALC works by explaining to native AppleHDA how to connect with audio layouts inside HDA chip that it doesn't know. What we have is a separate chip that has nothing to do with HDA, so neither AppleALC nor VoodooHDA support that. Unless someone writes a completely new driver, there's nothing to be done.

Out of available layouts the best one is **71**. Both sets of speakers work, jack is fully functional. Second best is 66, if you need it for some reason — top speakers are tweeters and not usable alone.

Unfortunately, macOS can use only one device for output. One solution is to make an aggregate device in MIDI settings, but then you lose some QoL like volume control and autoswitching to headphones. You can install third-party volume control, like [AggregateVolumeMenu](https://github.com/adaskar/AggregateVolumeMenu) or something more advanced like SoundSource.

Result of testing of different audio layouts.

| ID | Speakers | Microphones | Jack out | Jack in | Comments                                       |
| -- | -------- | ----------- | -------- | ------- | ---------------------------------------------- |
| 11 | Top      | **NO**      | Yes      | Yes     |                                                |
| 21 | Top      | **NO**      | Yes      | Yes     | Jack in not detected as headphones.            |
| 31 | Top      | **NO**      | Yes      | Yes     |                                                |
| 52 | Top      | **NO**      | Yes      | Broken? |                                                |
| 61 | Top      | **NO**      | Yes      | Yes     |                                                |
| 66 | Bottom   | **NO**      | Yes      | Yes     |                                                |
| 71 | Both     | **NO**      | Yes      | Yes     | Best one. Requires aggregate device.           |
| 88 | Top      | **NO**      | Yes      | Yes     | Headphones on separate channel without switch. |