#!/bin/zsh

source "$(dirname "$0")/Tasks/Common.zsh"

runTask "BuildBinpatcher"
runTask "BuildRenamer"
runTask "BuildStubber"

runTask "PatchBooter"
runTask "PatchLSK"

runTask "PatchTesla"
runTask "PatchSkyLight"
runTask "PatchIOSurface"
runTask "PatchWeb"

runTask "PatchWifi"

runTask "BuildWrappers"

runTask "BuildInstallerInject"
runTask "StagePatches"

finish