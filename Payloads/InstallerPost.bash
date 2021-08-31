dmg="macOS Install Data/UpdateBundle/AssetData/usr/standalone/update/ramdisk/x86_64SURamDisk.dmg"

# TODO: stop doing this
hdiutil resize -size 1G "$dmg"

hdiutil mount -noverify "$dmg"
mount=("/Volumes/"*"x86_64SURamDisk")

mv "$mount/sbin/reboot" "$mount/RealReboot"

source="/Volumes/Image Volume/"
cp -R "$source/DataOverlay/" .
cp -R "$source/RamdiskOverlay/" "$mount"

hdiutil eject "$mount"

nvram boot-args='-no_compat_check amfi_get_out_of_my_way=1 -nokcmismatchpanic keepsyms=1 -v ASB_MadeItToInstallerPost'