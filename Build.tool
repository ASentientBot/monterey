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
runTask "PatchWeb"

runTask "PatchWifi"
runTask "PatchBluetooth"
runTask "PatchHibernate"
runTask "PatchKernel"

runTask "BuildWrappers"

runTask "BuildInstallerInject"

finish