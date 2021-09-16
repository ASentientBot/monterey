# OpenCore ThirdPartyDrives mIOAHCIBlockStoragePatchV2Find

./Binpatcher "Current/Payload/System/Library/Extensions/IOAHCIFamily.kext/Contents/PlugIns/IOAHCIBlockStorage.kext/Contents/MacOS/IOAHCIBlockStorage" "IOAHCIBlockStorage" '
# APPLE
forward 0x4150504c4500
write 0x00'