# credits
- [dosdude1](http://dosdude1.com): 10.14.4+ OpenGL fix, Mojave/Catalina patchers, countless macOS insights
- [Dortania](https://dortania.github.io) ([khronokernel](https://github.com/khronokernel), [dhinakg](https://github.com/dhinakg), et al.): OpenCore Legacy Patcher, Broadcom Wi-Fi fix, Bluetooth insights, TeraScale 2 insights, excellent hackintosh guides, countless other insights and help
- [SpiraMira](https://github.com/SpiraMira) ([pkouame](https://forums.macrumors.com/members/pkouame.1036080/)), [testheit](https://forums.macrumors.com/members/1133139/): SkyLight insights, previous transparency patches
- [jackluke](https://github.com/jacklukem): 10.14+ Penryn panic fix (telemetry plugin), Tesla insights, testing
- [Minh Ton](https://minh-ton.github.io): many macOS insights, testing
- [moosethegoose2213](https://moosethegoose2213.github.io) (ASentientHedgehog): TeraScale 2 and QuartzCore insights, testing
- [EduCovas](https://github.com/educovas): WebKit and QuartzCore insights, testing
- [Acidanthera](https://github.com/acidanthera): aftermarket SSD hibernation patch
- [parrotgeek1](https://parrotgeek.com): Tesla and SIP insights
- [Julian Fairfax](https://julianfairfax.gitlab.io): macOS insights, testing
- [me](http://asentientbot.github.io): code, most fixes not listed above

Thanks as well to other contributors, moderators, and testers on [Unsupported Macs Discord](https://discord.gg/XbbWAsE), [OCLP Discord](https://discord.gg/rqdPgH8xSN), and [MacRumors Forums](https://forums.macrumors.com). Please tell me if I forgot to mention you.

# build
Place [these](https://archive.org/download/71prereqs) in `Build.noindex`. Add the target version's `InstallAssistant.pkg` as `Current.pkg`. Run `Extract.tool`, then `Build.tool`.

Run `Install.tool` to prepare patches for a given machine:
- `zoe`: MacBook7,1
- `cass2`: minimal TeraScale 2 system

Select `reveal` to show the output in Finder. Other modes are unsupported; see [OCLP](https://dortania.github.io/OpenCore-Legacy-Patcher/) for all practical uses.

# changes

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

- add proper occlusion notifications
- rewrite Glyphs
- fix NSVisualEffectView blurs
- support Big Sur
- automatically handle TeraScale 2 colors (workaround: set "millions" in SwitchResX)
- fix VNC on TeraScale 2
- support Intel
- support TeraScale 1
- fix CALayer corner radius (workaround: downgrade QuartzCore to Big Sur version)
- investigate space switching notifications
- improve DisplayLink
- fix shifted/missing icons
- fix Catalyst app scrolling
- improve Defenestrator
- fix corrupt shadows on Dock, zoom button popups
- improve replicant handling
- fix Photo Booth (workaround: downgrade to Big Sur version)
- fix accessibility zoom
- rewrite BootThing
- fix hidd, keyboard backlight (workaround: use Lab Tick)
- automatically color menu bar text (workaround: `defaults write -g ASB_DarkMenuBar -bool true`)
- fix Control Center sliders
- fix hardware cursor
- implement auto appearance (workaround: use NightOwl)
- implement Screen Time locking
- fix full-screen transition