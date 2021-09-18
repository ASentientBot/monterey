# installer ramdisk

overlay="RamdiskOverlay"
rm -rf "$overlay"

lskOutFolder="$overlay/usr/lib/system/"
mkdir -p "$lskOutFolder"
cp "libsystem_kernel.dylib" "$lskOutFolder"

mkdir -p "$overlay/sbin"
cp "$code/Payloads/RamdiskFakeReboot.bash" "$overlay/sbin/reboot"
chmod +x "$overlay/sbin/reboot"

mkdir -p "$overlay/System/Library/Frameworks"
cp -R "Current/Payload/System/Library/Frameworks/KernelManagement.framework" "$overlay/System/Library/Frameworks/"

cp "ffffffff.efi" "$overlay"

cp -R "SystemOverlay" "$overlay"