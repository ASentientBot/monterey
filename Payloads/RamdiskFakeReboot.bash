#!/mnt1/bin/bash

set -e

source="/SystemOverlay"
target="/mnt1"
preboot="/mnt9"

PATH+=:"$target/bin:$target/usr/bin:$target/usr/sbin:$target/usr/libexec"

while read file
do
	rm -rf "$target/$file"
done < "/Delete.txt"

set +e

cp -R "$source/" "$target"

# TODO: non ideal
export DYLD_SHARED_CACHE_DIR="$target/System/Library/dyld"
export DYLD_SHARED_REGION=private
kmutil install --update-all --update-preboot --volume-root "$target"
unset DYLD_SHARED_CACHE_DIR
unset DYLD_SHARED_REGION

set -e

# TODO: this is unreliable
long="$(ls -t "$preboot" | head -1)"

cp "/ffffffff.efi" "$preboot/$long/System/Library/CoreServices/boot.efi"

args='-no_compat_check amfi_get_out_of_my_way=1 -nokcmismatchpanic keepsyms=1 -v bcom.platform-check=0 ASB_MadeItToRamdiskFakeReboot ipc_control_port_options=0'
nvram boot-args="$args"
plist="$preboot/$long/Library/Preferences/SystemConfiguration/com.apple.Boot.plist"
PlistBuddy "$plist" -c "Set 'Kernel Flags' $args"

/RealReboot