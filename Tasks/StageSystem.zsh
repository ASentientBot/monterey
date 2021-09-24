overlay="SystemOverlay"
rm -rf "$overlay"

extensions="$overlay/System/Library/Extensions"
privateFrameworks="$overlay/System/Library/PrivateFrameworks"
frameworks="$overlay/System/Library/Frameworks"

mkdir -p "$extensions"
mkdir -p "$privateFrameworks"
mkdir -p "$frameworks"

cp -R "10.14.3/Payload/System/Library/Frameworks/OpenGL.framework" "$frameworks"
rm -f "$frameworks/OpenGL.framework/Versions/A/Libraries/libCoreFSCache.dylib"

mkdir -p "$privateFrameworks/SkyLight.framework/Versions/A"
mkdir -p "$frameworks/CoreDisplay.framework/Versions/A"
mkdir -p "$frameworks/IOSurface.framework/Versions/A"

cp "Wrapped/Common/SkyLight" "Wrapped/Common/SkyLightOld.dylib" "$privateFrameworks/SkyLight.framework/Versions/A"
cp "Wrapped/Common/CoreDisplay" "Wrapped/Common/CoreDisplayOld.dylib" "$frameworks/CoreDisplay.framework/Versions/A"

ln -s "A" "$privateFrameworks/SkyLight.framework/Versions/Current"
ln -s "A" "$frameworks/CoreDisplay.framework/Versions/Current"
ln -s "A" "$frameworks/IOSurface.framework/Versions/Current"

ln -s "Versions/Current/SkyLight" "$privateFrameworks/SkyLight.framework/SkyLight"
ln -s "Versions/Current/CoreDisplay" "$frameworks/CoreDisplay.framework/CoreDisplay"
ln -s "Versions/Current/IOSurface" "$frameworks/IOSurface.framework/IOSurface"

plistFolder="$overlay/System/Library/LaunchDaemons"
plistPath="$PWD/$plistFolder/HiddHack.plist"
mkdir -p "$plistFolder"
cp "10.15.7/Payload/System/Library/LaunchDaemons/com.apple.hidd.plist" "$plistPath"
defaults write "$plistPath" ProgramArguments -array-add eventSystem
defaults write "$plistPath" Label HiddHack

if test "$target" = "zoe"
then
	cp -R "10.13.6/Payload/System/Library/Extensions/AppleHDA.kext" "$extensions"
	cp -R "10.14.6/Payload/System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns/nvenet.kext" "$extensions"
	cp -R "10.13.6/Payload/System/Library/Extensions/GeForceTesla.kext" "$extensions"
	cp -R "10.13.6/Payload/System/Library/Extensions/NVDAResmanTesla.kext" "$extensions"
	cp -R "10.13.6/Payload/System/Library/Extensions/NVDANV50HalTesla.kext" "$extensions"
	cp -R "10.13.6/Payload/System/Library/Extensions/GeForceTeslaGLDriver.bundle" "$extensions"
	cp -R "10.15.7/Payload/System/Library/Extensions/IOSurface.kext" "$extensions"

	# TODO: up to Monterey DP6 works
	cp -R "10.15.7/Payload/System/Library/Extensions/NVDAStartup.kext" "$extensions"

	cp "GeForceTesla" "$extensions/GeForceTesla.kext/Contents/MacOS"
	cp "NVDAResmanTesla" "$extensions/NVDAResmanTesla.kext/Contents/MacOS"
	cp "IOSurface" "$extensions/IOSurface.kext/Contents/MacOS"

	if test "$major" = "11"
	then
		wifi="$extensions/IO80211Family.kext/Contents/PlugIns"
	else
		wifi="$extensions/IO80211FamilyLegacy.kext/Contents/PlugIns"
	fi
	mkdir -p "$wifi"
	cp -R "AirPortBrcmNIC.kext" "$wifi"

	ahci="$extensions/IOAHCIFamily.kext/Contents/PlugIns/IOAHCIBlockStorage.kext/Contents/MacOS"
	mkdir -p "$ahci"
	cp "IOAHCIBlockStorage" "$ahci"

	mkdir -p "$overlay/usr/sbin"
	cp "bluetoothd" "BlueTool" "$overlay/usr/sbin"

	cp -R "10.14.3/Payload/System/Library/PrivateFrameworks/GPUSupport.framework" "$privateFrameworks"

	cp "Wrapped/Zoe/IOSurface" "Wrapped/Zoe/IOSurfaceOld.dylib" "$frameworks/IOSurface.framework/Versions/A"

	# TODO: check needed on Cass2
	webkit="$overlay/System/Library/Frameworks/WebKit.framework/Versions/A/XPCServices"
	mkdir -p "$webkit"
	cp -R "com.apple.WebKit.WebContent.xpc" "$webkit"

elif test "$target" = "cass2"
then
	cp -R "10.13.6/Payload/System/Library/Extensions/AMD5000Controller.kext" "$extensions"
	cp -R "10.13.6/Payload/System/Library/Extensions/AMDLegacyFramebuffer.kext" "$extensions"
	cp -R "10.13.6/Payload/System/Library/Extensions/AMDLegacySupport.kext" "$extensions"
	cp -R "10.13.6/Payload/System/Library/Extensions/AMDRadeonX3000.kext" "$extensions"
	cp -R "10.13.6/Payload/System/Library/Extensions/IOAcceleratorFamily2.kext" "$extensions"
	cp -R "10.13.6/Payload/System/Library/Extensions/AMDRadeonX3000GLDriver.bundle" "$extensions"
	cp -R "10.14.6/Payload/System/Library/Extensions/IOSurface.kext" "$extensions"

	cp -R "10.13.6/Payload/System/Library/PrivateFrameworks/GPUSupport.framework" "$privateFrameworks"

	cp "Wrapped/Cass2/IOSurface" "Wrapped/Cass2/IOSurfaceOld.dylib" "$frameworks/IOSurface.framework/Versions/A"

	mkdir -p "$privateFrameworks/IOAccelerator.framework/Versions/A"
	cp "Wrapped/Cass2/IOAccelerator" "Wrapped/Cass2/IOAcceleratorOld.dylib" "$privateFrameworks/IOAccelerator.framework/Versions/A"

fi