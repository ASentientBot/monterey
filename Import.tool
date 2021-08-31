#!/bin/zsh

source "$(dirname "$0")/Tasks/Common.zsh"

runTaskRoot "ExtractRetro"
runTaskRoot "ExtractCurrent"

finish