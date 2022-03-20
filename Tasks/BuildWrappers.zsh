# TODO: move more logic to Stubber

source "$code/Tasks/Common.zsh"

folderOut="Wrapped"
rm -rf "$folderOut"
mkdir "$folderOut"

function build
{
	oldIn="$1"
	newIn="$2"
	mainInstall="$3"

	prefixOut="$folderOut/$4"
	mkdir -p "$prefixOut"
	
	name="$(basename "$mainInstall")"
	mainNameOut="$name"
	oldNameOut="${name}Old.dylib"
	
	prefixInstall="$(dirname "$mainInstall")"
	oldInstall="$prefixInstall/$oldNameOut"
	
	mainOut="$prefixOut/$mainNameOut"
	oldOut="$prefixOut/$oldNameOut"
	
	cp "$oldIn" "$oldOut"
	install_name_tool -id "$oldInstall" "$oldOut"
	
	mainIn="$prefixOut/${name}Wrapper.m"
	shimsIn="$code/Shims"

	./Stubber "$oldIn" "$newIn" "$shimsIn" "$mainIn"

	current="$(otool -l "$newIn" | grep -m 1 'current version' | cut -d ' ' -f 9)"
	compatibility="$(otool -l "$newIn" | grep -m 1 'compatibility version' | cut -d ' ' -f 3)"
	echo "current $current compatibility $compatibility"
	
	clangCommon -dynamiclib -compatibility_version "$compatibility" -current_version "$current" -install_name "$mainInstall" -Xlinker -reexport_library "$oldOut" -I "$code/Shims" "$mainIn" -o "$mainOut" "${@:5}"
	
	codesign -f -s - "$oldOut"
	codesign -f -s - "$mainOut"
}

build "SkyLight" "Current/Ramdisk/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight" "/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight" "Common" -F "/System/Library/PrivateFrameworks" -framework AppleSystemInfo -framework CoreBrightness
build "CoreDisplay" "Current/Ramdisk/System/Library/Frameworks/CoreDisplay.framework/Versions/A/CoreDisplay" "/System/Library/Frameworks/CoreDisplay.framework/Versions/A/CoreDisplay" "Common"
build "10.15.7/Payload/System/Library/Frameworks/QuartzCore.framework/Versions/A/QuartzCore" "Current/Ramdisk/System/Library/Frameworks/QuartzCore.framework/Versions/A/QuartzCore" "/System/Library/Frameworks/QuartzCore.framework/Versions/A/QuartzCore" "Common"

build "10.15.7/Payload/System/Library/Frameworks/IOSurface.framework/Versions/A/IOSurface" "Current/Ramdisk/System/Library/Frameworks/IOSurface.framework/Versions/A/IOSurface" "/System/Library/Frameworks/IOSurface.framework/Versions/A/IOSurface" "Zoe"

build "10.14.6/Payload/System/Library/Frameworks/IOSurface.framework/Versions/A/IOSurface" "Current/Ramdisk/System/Library/Frameworks/IOSurface.framework/Versions/A/IOSurface" "/System/Library/Frameworks/IOSurface.framework/Versions/A/IOSurface" "Cass2"
build "10.13.6/Payload/System/Library/PrivateFrameworks/IOAccelerator.framework/Versions/A/IOAccelerator" "Current/Ramdisk/System/Library/PrivateFrameworks/IOAccelerator.framework/Versions/A/IOAccelerator" "/System/Library/PrivateFrameworks/IOAccelerator.framework/Versions/A/IOAccelerator" "Cass2"