in="$PWD/Current.pkg"
new=0

if test -e "Current.dmg"
then
	in="$PWD/Current.dmg"
	new=1
fi

out="$PWD/Current"

if test -e "$out"
then
	exit
fi

mkdir "$out"
cd "$out"

hdiutil mount -noverify "$in"
mkdir "Zip"
cd "Zip"
if test $new = 1
then

	mount="/Volumes/UniversalMacAssistant"
	unzip "$mount"/*.app/Contents/SharedSupport/com_apple_MobileAsset_MacSoftwareUpdate/*.zip

else
	mount="/Volumes/Shared Support"
	unzip "$mount/com_apple_MobileAsset_MacSoftwareUpdate/"*".zip"
fi
cd ..

hdiutil mount -noverify "Zip/AssetData/usr/standalone/update/ramdisk/x86_64SURamDisk.dmg"
ramdiskMount=("/Volumes/"*".x86_64SURamDisk")
cp -a "$ramdiskMount" "Ramdisk"
hdiutil eject "$ramdiskMount"

mkdir "Payload"
cd "Payload"
for archive in .."/Zip/AssetData/payloadv2/payload.0"??
do
	aa extract -i "$archive"
done
cd ..

if test $new = 1
then
	mkdir -p "Assistant/Payload/Applications"
	cp -a "$mount"/*.app "Assistant/Payload/Applications"
else
	pkgutil --expand-full "$in" "Assistant"
	contentsPath=("Assistant/Payload/Applications/Install"*"/Contents")

	# pkgutil extracts bare dmg, installer expects pkgdmg
	rm "Assistant/SharedSupport.dmg"
	mkdir -p "$contentsPath/SharedSupport"
	ln "$in" "$contentsPath/SharedSupport/SharedSupport.dmg"
fi

hdiutil eject "$mount"