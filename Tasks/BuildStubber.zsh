source "$code/Tasks/Common.zsh"

clangCommon "$code/Tools/Stubber.m" -o "Stubber"

clangCommon "$code/Tools/StubberObjcHelper.m" -o "StubberObjcHelper"

# ./Stubber "10.14.6/Payload/System/Library/Frameworks/QuartzCore.framework/Versions/A/QuartzCore" "Current/Ramdisk/System/Library/Frameworks/QuartzCore.framework/Versions/A/QuartzCore" "../Shims" "StubberTestOutput.m"; false

# ./StubberObjcHelper "10.15.7/Payload/System/Library/Frameworks/IOSurface.framework/Versions/A/IOSurface"; false