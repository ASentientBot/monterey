lipo -thin x86_64 "Current/Payload/usr/sbin/bluetoothd" -o "bluetoothd"

rm -f "bluetoothdEnts.xml"
codesign --dump --xml --entitlements "bluetoothdEnts.xml" "bluetoothd"

./Binpatcher "bluetoothd" "bluetoothd" '
# Bluetooth USB Host Controller --> BRCM2070 Hub
forward 0x426c7565746f6f74682055534220486f737420436f6e74726f6c6c657200
write 0x4252434d323037302048756200'

codesign -f -s - --entitlements "bluetoothdEnts.xml" "bluetoothd"

lipo -thin x86_64 "Current/Payload/usr/sbin/BlueTool" -o "BlueTool"

rm -f "BlueToolEnts.xml"
codesign --dump --xml --entitlements "BlueToolEnts.xml" "BlueTool"

./Binpatcher "BlueTool" "BlueTool" '
# /etc/bluetool/SkipBluetoothAutomaticFirmwareUpdate --> /usr/sbin/BlueTool
forward 0x2f6574632f626c7565746f6f6c2f536b6970426c7565746f6f74684175746f6d617469634669726d7761726555706461746500
write 0x2f7573722f7362696e2f426c7565546f6f6c00'

codesign -f -s - --entitlements "BlueToolEnts.xml" "BlueTool"