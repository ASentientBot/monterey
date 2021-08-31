target="$(osascript -e 'posix path of (choose folder)')"

unique="Installer$(date +%s)"
diskutil erasevolume JHFS+ "$unique" "$target"

"Current/Assistant/Payload/Applications/Install macOS"*".app/Contents/Resources/createinstallmedia" --volume "/Volumes/$unique" --nointeraction

target=("/Volumes/Install macOS"*)

# TODO: BootThing replacement
nvram boot-args='-no_compat_check amfi_get_out_of_my_way=1 -nokcmismatchpanic keepsyms=1 -v'
cp "ffffffff.efi" "$target/System/Library/CoreServices/boot.efi"

bs="$target/BaseSystem/BaseSystem.dmg"
bsOld="$target/BaseSystemOld.dmg"
mv "$bs" "$bsOld"
hdiutil convert -format UDRW "$bsOld" -o "$bs"
rm "$bsOld"

bsMount="$(hdiutil mount -noverify "$bs" | grep -Eo '/Volumes/macOS.*$')"
mount -uw "$bsMount"

plist="$bsMount/System/Installation/CDIS/Recovery Springboard.app/Contents/Resources/Utilities.plist"
/usr/libexec/PlistBuddy "$plist" -c 'Add Buttons:0 dict'
/usr/libexec/PlistBuddy "$plist" -c 'Add Buttons:0:Path string "/Volumes/Image Volume/InstallerWrapper.bash"'
/usr/libexec/PlistBuddy "$plist" -c 'Add Buttons:0:TitleKey string "patched installer"'
/usr/libexec/PlistBuddy "$plist" -c "Add Buttons:0:DescriptionKey string \"is this the link you\'re looking for?\""

hdiutil eject "$bsMount"

cp -R "InstallerOverlay/" "$target"