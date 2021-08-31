# https://archive.org/download/71prereqs

# 17G66 http://cass2.local:11111/file/L1ZvbHVtZXMvVGVtcG9yYXJ5IDEyL0Rvd25sb2FkcyBPdmVyZmxvdyAxNGIvQXBwbGUgbWFjT1MgMTAuMTMuNiBIaWdoIFNpZXJyYSBTb2Z0d2FyZSBDYXRhbG9nIEZpbGVzICgyMDIwLTEwLTMwKS9JbnN0YWxsRVNERG1nLnBrZw==
# 18D109 http://cass2.local:11111/file/L1ZvbHVtZXMvVGVtcG9yYXJ5L0Rvd25sb2FkcyBPdmVyZmxvdy9BcHBsZSBtYWNPUyAxMC4xNC4zIE1vamF2ZSBTb2Z0d2FyZSBDYXRhbG9nIEZpbGVzIChBZnRlciBTdXBwbGVtZW50YWwgVXBkYXRlKS9JbnN0YWxsRVNERG1nLnBrZw==
# 18E2034 http://cass2.local:11111/file/L1ZvbHVtZXMvVGVtcG9yYXJ5L0Rvd25sb2FkcyBPdmVyZmxvdy9BcHBsZSBtYWNPUyAxMC4xNC40IE1vamF2ZSBTb2Z0d2FyZSBDYXRhbG9nIEZpbGVzL0luc3RhbGxFU0REbWcucGtn
# 18G103 http://cass2.local:11111/file/L1ZvbHVtZXMvVGVtcG9yYXJ5IDEwL0Rvd25sb2FkcyBPdmVyZmxvdyAxMi9BcHBsZSBtYWNPUyAxMC4xNC42IE1vamF2ZSBTb2Z0d2FyZSBDYXRhbG9nIEZpbGVzL0luc3RhbGxFU0REbWcucGtn
# 19H4 http://cass2.local:11111/file/L1ZvbHVtZXMvVGVtcG9yYXJ5IDEyL0Rvd25sb2FkcyBPdmVyZmxvdyAxNGIvQXBwbGUgbWFjT1MgMTAuMTUuNyBDYXRhbGluYSBTb2Z0d2FyZSBDYXRhbG9nIEZpbGVzICgyMDIwLTEwLTI4KS9JbnN0YWxsRVNERG1nLnBrZw==

function extract
{
	if ! test -e "$1"
	then
		hdiutil mount -noverify "$2"
		pkgutil --expand-full "/Volumes/InstallESD/Packages/Core.pkg" "$1"
		hdiutil eject "/Volumes/InstallESD"
	fi
}

extract "10.13.6" "17G66.pkg"
extract "10.14.3" "18D109.pkg"
extract "10.14.4" "18E2034.pkg"
extract "10.14.6" "18G103.pkg"
extract "10.15.7" "19H4.pkg"