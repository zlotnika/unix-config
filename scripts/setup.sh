# setup a new unix computer
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew cask install google-chrome
brew cask install spectacle
brew cask install virtualbox
brew cask install slack

brew cask install vagrant
brew cask install 1password
brew cask install knox
brew cask install skype-for-business

brew install emacs
brew install bash-completion
brew install git
brew install switchaudio-osx

brew install docker
brew install dinghy
brew install docker-compose
brew install docker-machine
# brew install openconnect

mkdir ~/Library/KeyBindings
cp ~/scripts/DefaultKeyBinding.dict ~/Library/KeyBindings/

# disable time machine notifications
# 535 -> 12609 where _SYSTEM_CENTER_:com.apple.TMHelperAgent
# `cd `getconf DARWIN_USER_DIR`/com.apple.notificationcenter/db`
# `sqlite3 db`
# `update app_info set flags=12609 where bundleid = '_SYSTEM_CENTER_:com.apple.TMHelperAgent';`
echo "http://apple.stackexchange.com/questions/125054/how-do-i-get-time-machine-to-show-in-notification-center"

# turn off emdash craziness
echo "http://superuser.com/questions/555628/how-to-stop-mac-to-convert-typing-double-dash-to-emdash"
