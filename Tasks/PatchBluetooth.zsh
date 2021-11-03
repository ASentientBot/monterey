lipo -thin x86_64 "Current/Payload/usr/sbin/bluetoothd" -o "bluetoothd"

rm -f "bluetoothdEnts.xml"
codesign --dump --xml --entitlements "bluetoothdEnts.xml" "bluetoothd"

./Binpatcher "bluetoothd" "bluetoothd" '
otool forward (?m)^.*?\[Found_USB_Dongle

otool forward (?m)^.*?CFStringCompare
otool forward (?m)^.*?je
nop 0x2

otool forward (?m)^.*?cmpl\t\$0xa5c
otool forward (?m)^.*?je
write 0xeb

set 0x0
otool forward (?m)^.*?\[GetProductAndVendorID
otool forward (?m)^.*?CFStringCompare
otool forward (?m)^.*?je
nop 0x6'

codesign -f -s - --entitlements "bluetoothdEnts.xml" "bluetoothd"

lipo -thin x86_64 "Current/Payload/usr/sbin/BlueTool" -o "BlueTool"

rm -f "BlueToolEnts.xml"
codesign --dump --xml --entitlements "BlueToolEnts.xml" "BlueTool"

./Binpatcher "BlueTool" "BlueTool" '
# /etc/bluetool/SkipBluetoothAutomaticFirmwareUpdate --> /usr/sbin/BlueTool
forward 0x2f6574632f626c7565746f6f6c2f536b6970426c7565746f6f74684175746f6d617469634669726d7761726555706461746500
write 0x2f7573722f7362696e2f426c7565546f6f6c00'

codesign -f -s - --entitlements "BlueToolEnts.xml" "BlueTool"