#!/bin/zsh

source "$(dirname "$0")/Tasks/Common.zsh"

runTask "BuildBinpatcher"
runTask "BuildRenamer"
runTask "BuildStubber"

runTask "PatchBooter"
runTask "PatchLSK"

runTask "PatchTesla"
runTask "PatchSkyLight"
runTask "PatchCoreDisplay"
runTask "PatchIOSurface"

if test "$major" = "12"
then
	runTask "PatchWeb"
	runTask "PatchBluetooth"
	runTask "PatchLPM"
fi

runTask "PatchWifi"
runTask "PatchHibernate"

runTask "BuildWrappers"

runTask "BuildInstallerInject"

finish