# OpenCore ThirdPartyDrives mIOAHCIBlockStoragePatchV2Find

./Binpatcher "Current/Payload/System/Library/Extensions/IOAHCIFamily.kext/Contents/PlugIns/IOAHCIBlockStorage.kext/Contents/MacOS/IOAHCIBlockStorage" "IOAHCIBlockStorage" '
# APPLE\0
forward 0x4150504C4500
write 0x00'

chmod +x "IOAHCIBlockStorage"