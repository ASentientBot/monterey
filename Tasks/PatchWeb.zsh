# TODO: EduCovas replaces the .sb instead, maybe smarter

cp -R "Current/Payload/System/Library/Frameworks/WebKit.framework/Versions/A/XPCServices/com.apple.WebKit.WebContent.xpc" .

# codesign appends
rm -f "WebEnts.plist"
codesign --dump --entitlements "WebEnts.plist" --xml "com.apple.WebKit.WebContent.xpc"

defaults delete "$PWD/WebEnts.plist" "com.apple.private.security.message-filter"

# TODO: what
rm -rf "com.apple.WebKit.WebContent.xpc/Contents/PlugIns/MediaFormatReader.bundle"

plutil -convert xml1 "WebEnts.plist"
codesign -f -s - --entitlements "WebEnts.plist" "com.apple.WebKit.WebContent.xpc"