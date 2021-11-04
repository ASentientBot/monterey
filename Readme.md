# credits
- [dosdude1](http://dosdude1.com): 10.14.4+ OpenGL fix, Mojave/Catalina patchers, countless macOS insights
- [Dortania](https://dortania.github.io) ([khronokernel](https://github.com/khronokernel), [dhinakg](https://github.com/dhinakg), et al.): OpenCore Legacy Patcher, Broadcom Wi-Fi fix, Bluetooth insights, TeraScale 2 insights, excellent hackintosh guides, countless other explanations and help
- [SpiraMira](https://github.com/SpiraMira) ([pkouame](https://forums.macrumors.com/members/pkouame.1036080/)), [testheit](https://forums.macrumors.com/members/1133139/): SkyLight insights, previous transparency patches
- [jackluke](https://github.com/jacklukem): 10.14+ Penryn panic fix (telemetry plugin), Tesla insights, testing
- [Minh Ton](https://minh-ton.github.io): many macOS insights, testing
- [moosethegoose2213](https://moosethegoose2213.github.io) (ASentientHedgehog): TeraScale 2 and QuartzCore insights, testing
- [parrotgeek1](https://parrotgeek.com): many macOS and graphics insights regarding Tesla, SIP, OpenGL and more
- [EduCovas](https://github.com/educovas): Safari Extensions, WebKit, and QuartzCore insights, testing
- [Syncretic](https://forums.macrumors.com/members/syncretic.1173816/): [MonteRand](https://forums.macrumors.com/threads/monterand-probably-the-start-of-an-ongoing-saga.2320479/)
- [Acidanthera](https://github.com/acidanthera): aftermarket SSD hibernation patch
- [Julian Fairfax](https://julianfairfax.gitlab.io): macOS insights, testing
- [me](http://asentientbot.github.io): code, most fixes not listed above

Thanks as well to other contributors, moderators, and testers on [Unsupported Macs Discord](https://discord.gg/XbbWAsE), [OCLP Discord](https://discord.gg/rqdPgH8xSN), and [MacRumors Forums](https://forums.macrumors.com). Please tell me if I forgot to mention you.

# build
Place [these](https://archive.org/download/71prereqs) in `Build.noindex`. Add the target version's `InstallAssistant.pkg` as `Current.pkg`. Run `Import.tool`, then `Build.tool`.

Run `Install.tool` to prepare patches for a given machine:
- `zoe`: MacBook7,1
- `cass2`: minimal Radeon HD 5850 system
- `cass3`: minimal Radeon HD 4870 system

Select `reveal` to show the output in Finder. Other modes are unsupported; see [OCLP](https://dortania.github.io/OpenCore-Legacy-Patcher/) for all practical uses.

# changes

## 2021-11-3
- run HID event system under WindowServer (removing the need for `HiddHack.plist`)
- fix Bluetooth again

## 2021-10-31
- automatically apply Low Power Mode patches (IOKit model check, powerd xcpm ioctl)
- further improve Binpatcher's assembly regex mode

## 2021-10-30
- implement [MonteRand](https://forums.macrumors.com/threads/monterand-probably-the-start-of-an-ongoing-saga.2320479/) kernel patch
- add `objdump` wrapper to Binpatcher

## 2021-10-21
- fix PowerChime crash for those who have [enabled it](https://forums.macrumors.com/threads/macos-10-14-mojave-on-unsupported-macs-thread.2121473/post-26339698)
- add hack to fix Safari extension checkboxes

## 2021-10-20
- properly enable occlusion notifications

## 2021-10-19
- add hack to stop crashes if you've downgraded QuartzCore to fix corners

## 2021-10-17
- add preliminary support for TeraScale 1

## 2021-10-2
- patch SkyLight binary to workaround preference pane crash

## 2021-9-24
- workaround ROM feature check in DP7
- add NVDAStartup (removed with Kepler kexts)

## 2021-9-20
- fix TeraScale 2 screen recording

## 2021-9-18
- implement ivars in Stubber
- handle staging/installing multiple targets
- support TeraScale 2

## 2021-9-16
- implement Bluetooth hack
- steal hibernation patch from OpenCore

## 2021-9-7
- implement CoreDisplay hack for AGDC-related WindowServer crash on Intel

## 2021-9-5
- rewrite Stubber (modularity, `Class Stub is implemented...`)
- remove excessive SkyLight shim logs
- create symlinks in shimmed frameworks (Catalyst dyld problem)

## 2021-8-26
Changes since last non-GitHub release.

### new Monterey issues
- add occlusion hack (WebKit animations, frozen Activity Monitor)
- fix missing menu bar
- fix scrolling crashes
- fix DisplayLink crashes
- fix missing symbols

### existing Big Sur issues
- fix unreliable sleep/wake notifications (black screens, missing loginwindow)
- fix replicants (dual-monitor status bar)
- fix Reduce Transparency black menu bar
- fix incorrect reversed private interfaces
- decrease code horrifyingness

# todo
Roughly ordered by priority. Also see [here](https://github.com/dortania/OpenCore-Legacy-Patcher/issues/108#issuecomment-810634088).

- investigate Safari freezing again (workaround: disable `WebKit::TiledCoreAnimationDrawingArea::invalidateRenderingUpdateRunLoopObserver()`)
- fix Catalyst app scrolling
- fix NSVisualEffectView blurs
- support Big Sur
- automatically handle TeraScale 2 colors (workaround: set "millions" in SwitchResX)
- fix VNC on TeraScale 2
- support Ironlake
- fix CALayer corner radius (workaround: downgrade QuartzCore to Big Sur version)
- investigate slow compositing in all browsers
- investigate broken WebGL in all browsers (workaround: use Chrome's `ignore-gpu-blocklist`)
- fix shifted/missing icons
- improve status bar item resizing, replicant handling
- investigate Maps crash
- fix accessibility zoom
- rewrite Glyphs
- investigate space switching notifications
- improve DisplayLink
- improve Defenestrator
- fix corrupt shadows on Dock, zoom button popups
- fix Photo Booth (workaround: downgrade to Big Sur version)
- use `com.apple.Boot.plist` for boot-args
- fix keyboard backlight (workaround: use Lab Tick)
- automatically color menu bar text (workaround: `defaults write -g ASB_DarkMenuBar -bool true`)
- fix Control Center sliders
- fix hardware cursor
- implement auto appearance (workaround: use NightOwl)
- implement Screen Time locking
- fix full-screen transition