extensions="10.13.6/Payload/System/Library/Extensions"

./Binpatcher "$extensions/GeForceTesla.kext/Contents/MacOS/GeForceTesla" "GeForceTesla" '
# IOFree panic je --> jmp
set 0x5cf9a
write 0xeb'

./Binpatcher "$extensions/NVDAResmanTesla.kext/Contents/MacOS/NVDAResmanTesla" "NVDAResmanTesla" '
# like NDRVShim but worse
set 0x1ea598
write 0xeb
set 0x0
forward 0x56534c47657374616c74
write 0x494f4c6f636b4c6f636b'