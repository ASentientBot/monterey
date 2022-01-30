"./Binpatcher" "Current/Ramdisk/System/Library/Frameworks/IOKit.framework/Versions/A/IOKit" "IOKit" '
otool forward (?m)^.*?MacBookAir
otool forward (?m)^.*?setae

# TODO: probably not very stable across changes
# or r15b,0x1
write 0x4180cf01
nop 0x3'

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