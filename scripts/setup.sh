# setup a new unix computer
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install rectangle
brew install bash-completion
brew install git
brew install gpg

brew install emacs --cask

brew install docker --cask

mkdir ~/Library/KeyBindings
cp ~/scripts/DefaultKeyBinding.dict ~/Library/KeyBindings/

# disable time machine notifications
# 535 -> 12609 where _SYSTEM_CENTER_:com.apple.TMHelperAgent
# `cd `getconf DARWIN_USER_DIR`/com.apple.notificationcenter/db`
# `sqlite3 db`
# `select flags from app_info where bundleid = '_SYSTEM_CENTER_:com.apple.TMHelperAgent';`
# `update app_info set flags=12609 where bundleid = '_SYSTEM_CENTER_:com.apple.TMHelperAgent';`
echo "http://apple.stackexchange.com/questions/125054/how-do-i-get-time-machine-to-show-in-notification-center"

# turn off emdash craziness
echo "http://superuser.com/questions/555628/how-to-stop-mac-to-convert-typing-double-dash-to-emdash"

# fix unifi
echo "https://community.ui.com/questions/Unifi-Controller-5-11-50-on-Mac-OS-X-Catalina-fails-to-start-/2fde6f63-b0ac-43a0-83f7-5cf43ba3d40f#answer/313a9c88-0f91-421d-baa0-4959acb7d6df"

sudo ln -s /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk /Applications/UniFi.app/Contents/PlugIns/adoptopenjdk-8.jdk
echo "sudo emacs /Applications/UniFi.app/Contents/Info.plist"
echo "after JVMOptions, do:
<key>JVMRuntime</key>
<string>adoptopenjdk-8.jdk</string>
"

# fix password
echo "https://medium.com/@chearnofficial/how-to-use-short-passwords-on-macos-mojave-4-characters-not-required-4c66a54183eb"
pwpolicy -clearaccountpolicies
