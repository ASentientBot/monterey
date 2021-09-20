source "$code/Tasks/Common.zsh"

target="$(promptFolder)"
if test "$target" != "/"
then
	target="${target%/}"
fi

mount -uw "$target"

# live framework swap breaks kmutil, copy kexts first

cp -R "SystemOverlay/System/Library/Extensions/" "$target/System/Library/Extensions"

chown -R root:wheel "$target/System/Library/Extensions"
chmod -R 755 "$target/System/Library/Extensions"

kmutil install --update-all --update-preboot --volume-root "$target"

# TODO: replace symlinks without an error?
set +e
cp -R "SystemOverlay/" "$target"
set -e

chown root:wheel "$target/System/Library/LaunchDaemons/HiddHack.plist"

if test "$target" = "/"
then
	reboot
fi