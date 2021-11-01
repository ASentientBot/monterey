"./Binpatcher" "Current/Ramdisk/System/Library/Frameworks/IOKit.framework/Versions/A/IOKit" "IOKit" '
otool forward (?m)^.*?MacBookAir
otool forward (?m)^.*?andb
# or al,1
write 0x0c01'

codesign -f -s - "IOKit"
chmod +x "IOKit"

rm -f "powerdEnts.xml"
codesign --dump --entitlements "powerdEnts.xml" --xml "Current/Payload/System/Library/CoreServices/powerd.bundle/powerd"
lipo -thin x86_64 "Current/Payload/System/Library/CoreServices/powerd.bundle/powerd" -o "powerd"

"./Binpatcher" "powerd" "powerd" '
otool forward (?m)^.*?/dev/xcpm
otool backward (?m)^.*?cmpl\t\$-0x1
otool forward (?m)^.*?je
nop 0x2
otool forward (?m)^.*?_ioctl
nop 0x5'

codesign -f -s - --entitlements "powerdEnts.xml" "powerd"