# credits
Please tell me if I forgot you.
- [dosdude1](http://dosdude1.com): 10.14.4+ GL bundle fix, Mojave/Catalina patchers, countless macOS insights
- [Dortania](https://dortania.github.io) ([khronokernel](https://github.com/khronokernel), [dhinakg](https://github.com/dhinakg), et al.): OpenCore Legacy Patcher, Broadcom Wi-Fi fix, TeraScale 2 insights, excellent hackintosh guides, countless other insights and help
- [SpiraMira](https://github.com/SpiraMira) ([pkouame](https://forums.macrumors.com/members/pkouame.1036080/)), [testheit](https://forums.macrumors.com/members/1133139/): SkyLight insights, previous transparancy patches
- [jackluke](https://github.com/jacklukem): 10.14+ Penryn panic fix (telemetry plugin), Tesla insights, testing
- [Minh Ton](https://minh-ton.github.io): many macOS insights, testing
- [moosethegoose2213](https://moosethegoose2213.github.io) (ASentientHedgehog): TeraScale 2 insights, lots of testing
- EduCovas: WebKit insights, testing
- [ParrotGeek](https://parrotgeek.com): Tesla and SIP insights
- [Julian Fairfax](https://julianfairfax.gitlab.io): many macOS insights, testing
- [me](http://asentientbot.github.io), Zoe, Cass2, Alice: code, most fixes not listed above
- other contributors and moderators on [Unsupported Macs Discord](https://discord.gg/XbbWAsE), [OCLP Discord](https://discord.gg/rqdPgH8xSN), [MacRumors Forums](https://forums.macrumors.com)

# build
Place [these](https://archive.org/download/71prereqs) in `Build.noindex`; run `Extract.tool`, then `Build.tool`. Most people will want `Build.noindex/Wrapped`; the rest is unsupported for now.

# todo
Roughly ordered by priority.

## immediately
- add proper occlusion notifications
- rewrite Stubber
- rewrite Glyphs
- framework symlinks

## hopefully soon
- fix CALayer corner radius
- support Big Sur
- support TeraScale 2
- automatically handle TeraScale 2 colors
- support Intel
- support TeraScale 1
- improve DisplayLink
- fix NSVisualEffectView blurs
- fix shifted/missing icons
- fix Catalyst app scrolling
- improve Defenestrator
- better separate wrappers/pseudopatcher

## maybe eventually
- improve replicant handling
- fix VNC, screencapture
- fix Photo Booth
- fix accessibility zoom
- rewrite BootThing
- fix hidd, keyboard backlight
- automatically color menu bar text (temporary: `defaults write -g ASB_DarkMenuBar -bool true`)
- fix Control Center sliders
- implement auto appearance
- implement Screen Time locking

# fixes

## since Monterey DP5 release (OCLP server, 2021-8-26)
- none yet

## since Big Sur release (OCLP server)

### new Monterey issues
- WebKit (CSS animations, `requestAnimationFrame`), frozen Activity Monitor
- missing menu bar text, black menu bar
- scrolling crashes
- DisplayLink crashes
- missing symbols

### existing Big Sur issues
- unreliable sleep/wake
- dual-monitor replicants, Reduce Transparency black menu bar
- several memory leaks
- incorrect reversed interfaces
- horrifying code