lipo -thin x86_64 "10.14.6/Payload/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight" -output "SkyLight"

./Renamer "SkyLight" "SkyLight" _SLSNewWindowWithOpaqueShape _SLSSetMenuBars _SLSCopyDevicesDictionary _SLSCopyCoordinatedDistributedNotificationContinuationBlock _SLSShapeWindowInWindowCoordinates _SLSEventTapCreate _SLSWindowSetShadowProperties

./Binpatcher "SkyLight" "SkyLight" '
# the transparency hack
set 0x216c60
nop 0x4

# spin cursor hack
# TODO: proper fix
symbol _CGXHWCursorIsAllowed
return 0x0

# menubar height (22.0 --> 24.0)
set 0xb949c
write 0x38

# WSBackdropGetCorrectedColor remove 0x17 (MenuBarDark) material background (floats RGBA)
set 0x26ef70
write 0x00000000000000000000000000000000

# force 0x17 for light, inactive
set 0xb6db6
write 0x17
set 0xb6da3
write 0x17
set 0xb6db0
write 0x17

# override blend mode
# 0: works
# 1: invisible light
# 2: invisible dark
# 3+: corrupt
set 0xb6e4a
write 0x00
set +0x3
nop 0x4

# hide backstop
# TODO: weird
set 0xb88b6
nop 0x2
set 0xb8861
nop 0x2
set 0xb8877
nop 0x8

# prevent prefpane crash
# TODO: shim SLSInstallRemoteContextNotificationHandlerV2 instead
symbol ___SLSRemoveRemoteContextNotificationHandler_block_invoke
return 0x0'

if test -e "$code/Stuff/anti-thing.txt"
then
	./Binpatcher "SkyLight" "SkyLight" "$(cat "$code/Stuff/anti-thing.txt")"
fi