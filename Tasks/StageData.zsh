# installer target volume

source "$code/Tasks/Common.zsh"

overlay="DataOverlay"
rm -rf "$overlay"

booterOutFolder="$overlay/macOS Install Data/UpdateBundle/AssetData/boot/Firmware/System/Library/CoreServices"
mkdir -p "$booterOutFolder"
cp "ffffffff.efi" "$booterOutFolder/bootbase.efi"

#if test "$major" = 12
#then
#	kcOutFolder="$overlay/macOS Install Data/UpdateBundle/AssetData/boot/System/Library/KernelCollections"
#	mkdir -p "$kcOutFolder"
#	cp "BootKernelExtensions.kc" "$kcOutFolder"
#fi