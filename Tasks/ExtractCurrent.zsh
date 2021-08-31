in="$PWD/Current.pkg"
out="$PWD/Current"

if test -e "$out"
then
	exit
fi

mkdir "$out"
cd "$out"

hdiutil mount -noverify "$in"
mount="/Volumes/Shared Support"
mkdir "Zip"
cd "Zip"
unzip "$mount/com_apple_MobileAsset_MacSoftwareUpdate/"*".zip"
hdiutil eject "$mount"
cd ..

hdiutil mount -noverify "Zip/AssetData/usr/standalone/update/ramdisk/x86_64SURamDisk.dmg"
mount=("/Volumes/"*".x86_64SURamDisk")
cp -a "$mount" "Ramdisk"
hdiutil eject "$mount"

mkdir "Payload"
cd "Payload"
for archive in .."/Zip/AssetData/payloadv2/payload.0"??
do
	aa extract -i "$archive"
done
cd ..

pkgutil --expand-full "$in" "Assistant"
contentsPath=("Assistant/Payload/Applications/Install"*"/Contents")

# pkgutil extracts bare dmg, installer expects pkgdmg
rm "Assistant/SharedSupport.dmg"
mkdir -p "$contentsPath/SharedSupport"
ln "$in" "$contentsPath/SharedSupport/SharedSupport.dmg"