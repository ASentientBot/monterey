# installer volume

overlay="InstallerOverlay"
rm -rf "$overlay"
mkdir "$overlay"

cp "InstallerInject.dylib" "$overlay"
cp "$code/Payloads/InstallerWrapper.bash" "$overlay"
chmod +x "$overlay/InstallerWrapper.bash"

cp "$code/Payloads/InstallerPost.bash" "$overlay"

cp -R "DataOverlay" "$overlay"
cp -R "RamdiskOverlay" "$overlay"

echo "$target" > "$overlay/Target.txt"