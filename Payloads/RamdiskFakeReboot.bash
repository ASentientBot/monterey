#!/mnt1/bin/bash

set -e

source=/SystemOverlay
target="/mnt1"
preboot="/mnt9"

PATH+=:"$target/bin:$target/usr/bin:$target/usr/sbin/"

rm -rf "$target/System/Library/UserEventPlugins/com.apple.telemetry.plugin"

# TODO: stop doing this
extensions="$target/System/Library/Extensions"
rm -rf "$extensions/IOAcceleratorFamily2.kext"
rm -rf "$extensions/IOGPUFamily.kext"
rm -rf "$extensions/AMDRadeonX"*".kext"
rm -rf "$extensions/AppleIntel"*"Graphics"*".kext"
rm -rf "$extensions/AppleIntelFramebuffer"*".kext"
rm -rf "$extensions/AppleParavirtGPU.kext"
rm -rf "$extensions/GeForce.kext"

set +e

cp -R "$source/" "$target"

# TODO: non ideal
export DYLD_SHARED_CACHE_DIR="$target/System/Library/dyld"
export DYLD_SHARED_REGION=private
kmutil install --update-all --update-preboot --volume-root "$target"
unset DYLD_SHARED_CACHE_DIR
unset DYLD_SHARED_REGION

set -e

# TODO: BootThing replacement
long="$(ls -t "$preboot" | head -1)"
cp "/ffffffff.efi" "$preboot/$long/System/Library/CoreServices/boot.efi"
nvram boot-args='-no_compat_check amfi_get_out_of_my_way=1 -nokcmismatchpanic keepsyms=1 -v bcom.platform-check=0 ASB_MadeItToRamdiskFakeReboot'

/RealReboot