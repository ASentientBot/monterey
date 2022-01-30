overlay="SystemOverlay"
rm -rf "$overlay"
mkdir "$overlay"

if test "$target" = "null"
then
	exit 0
fi

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
mkdir -p "$frameworks/QuartzCore.framework/Versions/A"

cp "Wrapped/Common/SkyLight" "Wrapped/Common/SkyLightOld.dylib" "$privateFrameworks/SkyLight.framework/Versions/A"
cp "Wrapped/Common/CoreDisplay" "Wrapped/Common/CoreDisplayOld.dylib" "$frameworks/CoreDisplay.framework/Versions/A"
cp "Wrapped/Common/QuartzCore" "Wrapped/Common/QuartzCoreOld.dylib" "$frameworks/QuartzCore.framework/Versions/A"

ln -s "A" "$privateFrameworks/SkyLight.framework/Versions/Current"
ln -s "A" "$frameworks/CoreDisplay.framework/Versions/Current"
ln -s "A" "$frameworks/IOSurface.framework/Versions/Current"

ln -s "Versions/Current/SkyLight" "$privateFrameworks/SkyLight.framework/SkyLight"
ln -s "Versions/Current/CoreDisplay" "$frameworks/CoreDisplay.framework/CoreDisplay"
ln -s "Versions/Current/IOSurface" "$frameworks/IOSurface.framework/IOSurface"

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

	cp -R "10.14.3/Payload/System/Library/PrivateFrameworks/GPUSupport.framework" "$privateFrameworks"

	cp "Wrapped/Zoe/IOSurface" "Wrapped/Zoe/IOSurfaceOld.dylib" "$frameworks/IOSurface.framework/Versions/A"

	if test "$major" = "12"
	then
		mkdir -p "$overlay/usr/sbin"
		cp "bluetoothd" "BlueTool" "$overlay/usr/sbin"

		# TODO: check needed on Cass2
		webkit="$overlay/System/Library/Frameworks/WebKit.framework/Versions/A/XPCServices"
		mkdir -p "$webkit"
		cp -R "com.apple.WebKit.WebContent.xpc" "$webkit"

#		kernels="$overlay/System/Library/Kernels"
#		mkdir "$kernels"
#		cp "kernel" "$kernels"

		iokit="$overlay/System/Library/Frameworks/IOKit.framework/Versions/A"
		mkdir -p "$iokit"
		cp "IOKit" "$iokit"

		powerd="$overlay/System/Library/CoreServices/powerd.bundle"
		mkdir -p "$powerd"
		cp "powerd" "$powerd"

		# TODO: probably non-ideal way to fix the 12.3 DP1 800 MHz issue
		cp -R "10.15.7/Payload/System/Library/Extensions/IOPlatformPluginFamily.kext" "$extensions"
	fi

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

elif test "$target" = "cass3"
then
	cp -R "10.13.6/Payload/System/Library/Extensions/AMD4800Controller.kext" "$extensions"

	# TODO: check loaded/needed
	cp -R "10.13.6/Payload/System/Library/Extensions/AMDLegacyFramebuffer.kext" "$extensions"

	cp -R "10.13.6/Payload/System/Library/Extensions/AMDLegacySupport.kext" "$extensions"
	cp -R "10.13.6/Payload/System/Library/Extensions/ATIRadeonX2000.kext" "$extensions"
	cp -R "10.13.6/Payload/System/Library/Extensions/ATIRadeonX2000GLDriver.bundle" "$extensions"

	# TODO: unify these non-TS2 patches to avoid copy+paste
	
	cp -R "10.15.7/Payload/System/Library/Extensions/IOSurface.kext" "$extensions"
	cp "IOSurface" "$extensions/IOSurface.kext/Contents/MacOS"

	cp -R "10.14.3/Payload/System/Library/PrivateFrameworks/GPUSupport.framework" "$privateFrameworks"

	cp "Wrapped/Zoe/IOSurface" "Wrapped/Zoe/IOSurfaceOld.dylib" "$frameworks/IOSurface.framework/Versions/A"
fi