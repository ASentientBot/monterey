#!/bin/bash

set -e

launchctl setenv DYLD_INSERT_LIBRARIES "/Volumes/Image Volume/InstallerInject.dylib"

"/Volumes/Image Volume/Install macOS"*"app/Contents/MacOS/InstallAssistant"