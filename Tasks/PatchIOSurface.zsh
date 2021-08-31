./Binpatcher "10.15.7/Payload/System/Library/Extensions/IOSurface.kext/Contents/MacOS/IOSurface" "IOSurface" '
# addMemoryRegion/removeMemoryRegion names panic
set 0xdb52
write 0xeb
set 0xdbc6
write 0xeb'