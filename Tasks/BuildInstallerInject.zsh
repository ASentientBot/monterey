source "$code/Tasks/Common.zsh"

clangCommon -dynamiclib "$code/Payloads/InstallerInject.m" -o "InstallerInject.dylib"
codesign -f -s - "InstallerInject.dylib"