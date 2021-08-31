rm -rf "AirPortBrcmNIC.kext"

# Big Sur IO80211Family.kext, Monterey IO80211FamilyLegacy.kext
cp -R "Current/Payload/System/Library/Extensions/IO80211Family"*".kext/Contents/PlugIns/AirPortBrcmNIC.kext" .

/usr/libexec/PlistBuddy "AirPortBrcmNIC.kext/Contents/Info.plist" -c 'add "IOKitPersonalities:Broadcom 802.11 PCI:IONameMatch:0" string pci14e4,4353'