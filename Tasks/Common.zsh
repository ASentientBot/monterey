set -e

export code="$(dirname "$(dirname "$0")")"

mkdir -p "$code/Build.noindex"
cd "$code/Build.noindex"

export major="$(defaults read "$PWD/Current/Payload/System/Library/CoreServices/SystemVersion.plist" ProductVersion | cut -d '.' -f 1)"

function clangCommon
{
	clang -fmodules -I "$code/Utils" -Wno-unused-getter-return-value -Wno-objc-missing-super-calls $@
}

function runTask
{
	printf "\e[36m$1\e[0m\n"
	zsh -e "$code/Tasks/$1.zsh"
}

function runTaskRoot
{
	printf "\e[31m$1\e[0m\n"
	sudo -E zsh -e "$code/Tasks/$1.zsh"
}

function promptFolder
{
	osascript -e 'tell app "Terminal" to posix path of (choose folder)'
}

function finish
{
	printf "\e[32mdone\e[0m\n"
}