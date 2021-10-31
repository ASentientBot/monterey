dmg="macOS Install Data/UpdateBundle/AssetData/usr/standalone/update/ramdisk/x86_64SURamDisk.dmg"

# TODO: delete
find . > "ASB_PreBlessFind.log"

# TODO: stop doing this
hdiutil resize -size 1G "$dmg"

hdiutil mount -noverify "$dmg"
mount=("/Volumes/"*"x86_64SURamDisk")

mv "$mount/sbin/reboot" "$mount/RealReboot"

source="/Volumes/Image Volume/"
cp -R "$source/DataOverlay/" .
cp -R "$source/RamdiskOverlay/" "$mount"

hdiutil eject "$mount"

# TODO: fails on hackintosh, temporary workaround
set +e

nvram 'boot-args=-no_compat_check amfi_get_out_of_my_way=1 -nokcmismatchpanic keepsyms=1 -v ASB_MadeItToInstallerPost'
nvram '4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:ExtendedFirmwareFeatures=%00%00%00%00%08%00%00%00'

exit 0