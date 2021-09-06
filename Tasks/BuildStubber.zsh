source "$code/Tasks/Common.zsh"

clangCommon "$code/Tools/Stubber.m" -o "Stubber"

# ./Stubber "10.14.6/Payload/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight" "Current/Ramdisk/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight" "../Shims" "StubberTestOutput.m"