lipo -thin x86_64 "10.14.4/Payload/System/Library/Frameworks/CoreDisplay.framework/Versions/A/CoreDisplay" -output "CoreDisplay"

./Binpatcher "CoreDisplay" "CoreDisplay" '
# TODO: AGDC hack
set 0x7e53f
write 0xe9c5feffff'