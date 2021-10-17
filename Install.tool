#!/bin/zsh

source "$(dirname "$0")/Tasks/Common.zsh"

target="$(promptList 'target machine' 'zoe' 'cass2' 'cass3' 'null')"
export target

runTask "StageSystem"

runTask "StageData"
runTask "StageRamdisk"
runTask "StageInstaller"

mode="$(promptList 'install mode' 'usb' 'shove' 'reveal')"

if test "$mode" = "usb"
then
	runTaskRoot "InstallDisk"

elif test "$mode" = "shove"
then
	runTaskRoot "InstallShove"

elif test "$mode" = "reveal"
then
	open -R "SystemOverlay"

fi

finish