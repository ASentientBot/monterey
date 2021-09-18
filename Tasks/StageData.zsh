# installer target volume

overlay="DataOverlay"
rm -rf "$overlay"

booterOutFolder="$overlay/macOS Install Data/UpdateBundle/AssetData/boot/Firmware/System/Library/CoreServices"
mkdir -p "$booterOutFolder"
cp "ffffffff.efi" "$booterOutFolder/bootbase.efi"