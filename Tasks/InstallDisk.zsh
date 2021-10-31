source "$code/Tasks/Common.zsh"

target="$(promptFolder)"

unique="Installer$(date +%s)"
diskutil erasevolume JHFS+ "$unique" "$target"

"Current/Assistant/Payload/Applications/Install macOS"*".app/Contents/Resources/createinstallmedia" --volume "/Volumes/$unique" --nointeraction

target=("/Volumes/Install macOS"*)

plist="$target/Library/Preferences/SystemConfiguration/com.apple.Boot.plist"
previousArgs="$(defaults read "$plist" "Kernel Flags")"
defaults write "$plist" "Kernel Flags" "$previousArgs -no_compat_check amfi_get_out_of_my_way=1 -nokcmismatchpanic keepsyms=1 -v"
plutil -convert xml1 "$plist"

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

# TODO: finicky on DP7, why?
sleep 10
hdiutil eject "$bsMount"

cp -R "InstallerOverlay/" "$target"