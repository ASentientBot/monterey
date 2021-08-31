# TODO: move logic into Stubber

source "$code/Tasks/Common.zsh"

prefixOut="Wrapped"
rm -rf "$prefixOut"
mkdir "$prefixOut"

function build
{
	oldIn="$1"
	newIn="$2"
	mainInstall="$3"
	
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
	shimsIn="$code/Shims/${name}"

	if test -d "$shimsIn"
	then
		./Stubber "$oldIn" "$newIn" "$mainIn" "$shimsIn/"*".m"
	else
		./Stubber "$oldIn" "$newIn" "$mainIn"
	fi
	
	clangCommon -dynamiclib -compatibility_version 1.0.0 -current_version 1.0.0 -install_name "$mainInstall" -Xlinker -reexport_library "$oldOut" -I "$code/Shims" "$mainIn" -o "$mainOut" $4
	
	codesign -f -s - "$oldOut"
	codesign -f -s - "$mainOut"
}

build "SkyLight" "Current/Ramdisk/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight" "/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight"
build "10.14.4/Payload/System/Library/Frameworks/CoreDisplay.framework/Versions/A/CoreDisplay" "Current/Ramdisk/System/Library/Frameworks/CoreDisplay.framework/Versions/A/CoreDisplay" "/System/Library/Frameworks/CoreDisplay.framework/Versions/A/CoreDisplay"
build "10.15.7/Payload/System/Library/Frameworks/IOSurface.framework/Versions/A/IOSurface" "Current/Ramdisk/System/Library/Frameworks/IOSurface.framework/Versions/A/IOSurface" "/System/Library/Frameworks/IOSurface.framework/Versions/A/IOSurface"