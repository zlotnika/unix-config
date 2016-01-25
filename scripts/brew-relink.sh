# http://apple.stackexchange.com/questions/129991/packages-installed-with-homebrew-not-found-after-restore
brew list -1 | while read line; do brew unlink $line; brew link $line; done
