# TODO: a mess

overlay="SystemOverlay"
rm -rf "$overlay"

extensions="$overlay/System/Library/Extensions"
mkdir -p "$extensions"
cp -R "10.13.6/Payload/System/Library/Extensions/AppleHDA.kext" "$extensions"
cp -R "10.14.6/Payload/System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns/nvenet.kext" "$extensions"
cp -R "10.13.6/Payload/System/Library/Extensions/GeForceTesla.kext" "$extensions"
cp -R "10.13.6/Payload/System/Library/Extensions/NVDAResmanTesla.kext" "$extensions"
cp -R "10.13.6/Payload/System/Library/Extensions/NVDANV50HalTesla.kext" "$extensions"
cp -R "10.13.6/Payload/System/Library/Extensions/GeForceTeslaGLDriver.bundle" "$extensions"
cp -R "10.15.7/Payload/System/Library/Extensions/IOSurface.kext" "$extensions"
cp "GeForceTesla" "$extensions/GeForceTesla.kext/Contents/MacOS"
cp "NVDAResmanTesla" "$extensions/NVDAResmanTesla.kext/Contents/MacOS"
cp "IOSurface" "$extensions/IOSurface.kext/Contents/MacOS"

if test "$major" = "11"
then
	wifiTarget="$extensions/IO80211Family.kext/Contents/PlugIns"
else
	wifiTarget="$extensions/IO80211FamilyLegacy.kext/Contents/PlugIns"
fi
mkdir -p "$wifiTarget"
cp -R "AirPortBrcmNIC.kext" "$wifiTarget"

mkdir -p "$extensions/IOAHCIFamily.kext/Contents/PlugIns/IOAHCIBlockStorage.kext/Contents/MacOS"
cp "IOAHCIBlockStorage" "$extensions/IOAHCIFamily.kext/Contents/PlugIns/IOAHCIBlockStorage.kext/Contents/MacOS"

mkdir -p "$overlay/usr/sbin"
cp "bluetoothd" "BlueTool" "$overlay/usr/sbin"

overlayPFrameworks="$overlay/System/Library/PrivateFrameworks"
overlayFrameworks="$overlay/System/Library/Frameworks"
mkdir -p "$overlayPFrameworks"
mkdir -p "$overlayFrameworks"

cp -R "10.14.3/Payload/System/Library/PrivateFrameworks/GPUSupport.framework" "$overlayPFrameworks"
cp -R "10.14.3/Payload/System/Library/Frameworks/OpenGL.framework" "$overlayFrameworks"
rm -f "$overlayFrameworks/OpenGL.framework/Versions/A/Libraries/libCoreFSCache.dylib"

mkdir -p "$overlayPFrameworks/SkyLight.framework/Versions/A"
mkdir -p "$overlayFrameworks/CoreDisplay.framework/Versions/A"
mkdir -p "$overlayFrameworks/IOSurface.framework/Versions/A"
cp "Wrapped/SkyLight" "Wrapped/SkyLightOld.dylib" "$overlayPFrameworks/SkyLight.framework/Versions/A"
cp "Wrapped/CoreDisplay" "Wrapped/CoreDisplayOld.dylib" "$overlayFrameworks/CoreDisplay.framework/Versions/A"
cp "Wrapped/IOSurface" "Wrapped/IOSurfaceOld.dylib" "$overlayFrameworks/IOSurface.framework/Versions/A"

ln -s "A" "$overlayPFrameworks/SkyLight.framework/Versions/Current"
ln -s "A" "$overlayFrameworks/CoreDisplay.framework/Versions/Current"
ln -s "A" "$overlayFrameworks/IOSurface.framework/Versions/Current"

ln -s "Versions/Current/SkyLight" "$overlayPFrameworks/SkyLight.framework/SkyLight"
ln -s "Versions/Current/CoreDisplay" "$overlayFrameworks/CoreDisplay.framework/CoreDisplay"
ln -s "Versions/Current/IOSurface" "$overlayFrameworks/IOSurface.framework/IOSurface"

plistFolder="$overlay/System/Library/LaunchDaemons"
plistPath="$PWD/$plistFolder/HiddHack.plist"
mkdir -p "$plistFolder"
cp "10.15.7/Payload/System/Library/LaunchDaemons/com.apple.hidd.plist" "$plistPath"
defaults write "$plistPath" ProgramArguments -array-add eventSystem
defaults write "$plistPath" Label HiddHack

mkdir -p "$overlay/System/Library/Frameworks/WebKit.framework/Versions/A/XPCServices"
cp -R "com.apple.WebKit.WebContent.xpc" "$overlay/System/Library/Frameworks/WebKit.framework/Versions/A/XPCServices"

######################################################################

overlay="DataOverlay"
rm -rf "$overlay"

booterOutFolder="$overlay/macOS Install Data/UpdateBundle/AssetData/boot/Firmware/System/Library/CoreServices"
mkdir -p "$booterOutFolder"
cp "ffffffff.efi" "$booterOutFolder/bootbase.efi"

######################################################################

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

mv "SystemOverlay" "$overlay"

######################################################################

overlay="InstallerOverlay"
rm -rf "$overlay"
mkdir "$overlay"

cp "InstallerInject.dylib" "$overlay"
cp "$code/Payloads/InstallerWrapper.bash" "$overlay"
chmod +x "$overlay/InstallerWrapper.bash"

cp "$code/Payloads/InstallerPost.bash" "$overlay"

mv "DataOverlay" "$overlay"
mv "RamdiskOverlay" "$overlay"