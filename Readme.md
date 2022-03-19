# credits
- [EduCovas](https://github.com/educovas): Safari Extensions, WebKit, SkyLight, and Safari freeze (DisplayLink) insights, swipe between pages workaround, QuartzCore (Control Center, missing icons, blur saturation, corners) insights and shim code, Catalyst scrolling workaround, extensive testing
- [ASentientHedgehog](https://moosethegoose2213.github.io): TeraScale 2 and QuartzCore (corners) insights, previous keyboard backlight workaround, OpenCL downgrade, Night Shift prefpane fix, extensive testing
- [dosdude1](http://dosdude1.com): 10.14.4+ OpenGL fix, Mojave/Catalina patchers, countless macOS insights
- [Dortania](https://dortania.github.io) ([khronokernel](https://github.com/khronokernel), [dhinakg](https://github.com/dhinakg), et al.): OpenCore Legacy Patcher, Broadcom Wi-Fi fix, Bluetooth insights, TeraScale 2 insights, excellent hackintosh guides, countless other explanations and help
- [Flagers](https://github.com/flagersgit): various macOS insights and help
- [SpiraMira](https://github.com/SpiraMira) ([pkouame](https://forums.macrumors.com/members/pkouame.1036080/)), [testheit](https://forums.macrumors.com/members/1133139/): SkyLight insights, previous transparency patches
- [jackluke](https://github.com/jacklukem): 10.14+ Penryn panic fix (telemetry plugin), Tesla insights, testing
- [Minh Ton](https://minh-ton.github.io): many macOS insights, QuartzCore brightness workaround, testing
- [parrotgeek1](https://parrotgeek.com): macOS and graphics insights regarding Tesla, TeraScale 2, SIP, OpenGL and more
- [Syncretic](https://forums.macrumors.com/members/syncretic.1173816/): [MonteRand](https://forums.macrumors.com/threads/monterand-probably-the-start-of-an-ongoing-saga.2320479/)
- [Acidanthera](https://github.com/acidanthera): aftermarket SSD hibernation patch
- [Julian Fairfax](https://julianfairfax.gitlab.io): macOS insights, testing
- IronApple: OpenCL downgrade testing
- [me](http://asentientbot.github.io): most fixes not listed above

Thanks as well to other contributors, moderators, and testers on [Unsupported Macs Discord](https://discord.gg/XbbWAsE), [OCLP Discord](https://discord.gg/rqdPgH8xSN), and [MacRumors Forums](https://forums.macrumors.com). Please tell me if I forgot to mention you.

# build
Place [these](https://archive.org/download/71prereqs) in `Build.noindex`. Add the target version's `InstallAssistant.pkg` as `Current.pkg`. Run `Import.tool`, then `Build.tool`.

Run `Install.tool` to prepare patches for a given machine:
- `zoe`: MacBook7,1
- `cass2`: minimal Radeon HD 5850 system
- `cass3`: minimal Radeon HD 4870 system

Select `reveal` to show the output in Finder. Other modes are unsupported; see [OCLP](https://dortania.github.io/OpenCore-Legacy-Patcher/) for all practical uses.

# changes

## 2022-3-7
- whitelist Displays prefpane service in Night Shift fixes, thanks ASentientHedgehog for this finding

## 2022-2-23
- disable TS2 hacks since ASentientHedgehog and IronApple fixed OpenCL
- enable open/save buttons on 12.3 DP4

## 2022-2-9
- reduce keyboard backlight hack delay, disable by default (`sudo defaults write /Library/Preferences/.GlobalPreferences.plist NonMetal_BacklightHack -bool true` to enable)

## 2022-2-8
- temporarily fix keyboard backlight by delaying until AppleSMCLMU comes online (_not_ production-ready: can increase boot time considerably)
- add workaround for EXC_GUARD crashes with AMFI off

## 2022-2-6
- add hack to allow quitting Catalyst apps with downgraded QuartzCore

## 2022-2-3
- support new InstallAssistant DMG format

## 2022-1-30
- add hacks for 12.3 DP1: workaround 800 MHz problem by downgrading `IOPlatformPluginFamily.kext`, tweak LPM patch for changes in IOKit
- fix Catalyst scrolling; thank you very much EduCovas for figuring this out!

## 2022-1-26
- fix Finder animations with downgraded QuartzCore
- implement custom menu bar colors (`sudo defaults write /Library/Preferences/.GlobalPreferences.plist NonMetal_MenuBarOverride 'R,G,B,A'` where 0 ≤ R,G,B,A ≤ 1)
- fix brightness slider on some hardware; thanks to Minh Ton for this hack!

## 2022-1-25
- re-enable old CABackdropLayer scale override to reduce blur glitching with downgraded QuartzCore; another thank you to EduCovas for noticing this
- fix Siri with downgraded QuartzCore

## 2022-1-24
- implement QuartzCore downgrade and supporting shims to fix Control Center graphical bugs, system-wide missing icons, desaturated blurs, and more; **huge thanks to EduCovas for extensive research and over half of the shim code**
- strip out obsolete fixes (disables `ASB_BlurOverride`)
- add credits in verbose boot

## 2022-1-16
- forcibly enable Night Shift
- call `SkyLightPluginEntry` in plugins if present
- remove now-unnecessary blur blacklisting

## 2022-1-6
- interpret negative `ASB_RimOverride` value as "hide legacy border but don't draw a fake one"
- properly deallocate wrapper object on window termination
- improve reliability of active blur detection

## 2021-12-15
- simulate Metal window borders in dark mode (enable with `defaults write -g ASB_RimBeta -bool true`, tweak brightness with `defaults write -g ASB_RimOverride -float <value from 0 to 1, 0.2 default>`)
- re-add Big Sur Photos hack

## 2021-12-14
- properly disable inactive blurs for better multitasking performance

## 2021-12-9
- plugins v2 (now in `/Library/Application Support/SkyLightPlugins` to workaround sandbox, target paths read from `<dylib name>.txt` for easier management)

## 2021-11-26
- update DisplayLink hacks (thanks EduCovas!)
- support Big Sur

## 2021-11-16
- implement basic plugin functionality (place dylibs in `/etc/SkyLightPlugins`, append lines `<target path or *> : <dylib name>` to `List.txt`)

## 2021-11-11
- start testing blur fixes (opt-in with `defaults write -g ASB_BlurBeta -bool true`, tweak strength with `defaults write -g ASB_BlurOverride -float <radius>`, disable per-app with `defaults write <bundle id> ASB_BlurBeta -bool false`)

## 2021-11-4
- enable greyscale color filter
- fix accessibility zoom

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

- fix Catalyst timeout crash
- fix mouse event weirdness on dual monitors with blur fix
- fix unresponsive password dialogs with downgraded QuartzCore
- implement Objective-C functions in Stubber
- change defaults and logging prefix to reflect that this is a multi-person project
- fix Safari frozen HTML canvas (workaround: `defaults write -g InternalDebugUseGPUProcessForCanvasRenderingEnabled -bool false`)
- fix graphical bugs with fake window rims
- improve blur fix performance
- fix remaining blur flickering issues
- fix "Cycle Through Windows"
- fix "Swipe Between Pages" (workaround: `defaults write -g AppleEnableMouseSwipeNavigateWithScrolls -bool true`)
- investigate rare binaries not seeing re-exported symbols (Dropbox-specific workaround: [SkyLight plugin](https://github.com/ASentientBot/monterey/releases/download/2021-12-17/throw.this.in.the.SkyLight.plugins.folder.to.fix.Dropbox.in.a.really.non.ideal.way.zip))
- support Ironlake
- investigate slow compositing in all browsers
- investigate broken WebGL in all browsers (workaround: use Chrome's `ignore-gpu-blocklist`)
- improve status bar item resizing, replicant handling
- investigate Maps crash
- rewrite Glyphs
- investigate space switching notifications
- fix Photo Booth (workaround: use Big Sur version)
- fix Books (workaround: use Big Sur version)
- automatically color menu bar text (workaround: `defaults write -g ASB_DarkMenuBar -bool true`)
- fix beachball with hardware cursor (workaround: downgrade `IOHIDFamily` to Catalina and edit WindowServer's sandbox file to allow `HIDWaitCursorFrameInterval`)
- implement auto appearance (workaround: use NightOwl)
- implement Screen Time locking
- fix full-screen transition
- fix Migration Assistant
- fix "Move to Display"