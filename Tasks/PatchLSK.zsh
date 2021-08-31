# disable snapshot
./Binpatcher "Current/Ramdisk/usr/lib/system/libsystem_kernel.dylib" "libsystem_kernel.dylib" '
symbol _fs_snapshot_create
return 0x0
symbol _fs_snapshot_root
return 0x0'

codesign -f -s - "libsystem_kernel.dylib"
chmod +x "libsystem_kernel.dylib"