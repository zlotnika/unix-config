# setup a new unix computer
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew cask install google-chrome
brew cask install flux
brew cask install spectacle
brew cask install flash

brew install emacs
brew install bash-completion
brew install git
brew install switchaudio-osx

mkdir ~/Library/KeyBindings
cp ~/scripts/DefaultKeyBinding.dict ~/Library/KeyBindings/
