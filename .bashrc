#### pretty terminal ####
# https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh
source ~/.bashrc.d/git-prompt.sh
# https://wiki.archlinux.org/index.php/Color_Bash_Prompt
source ~/.bashrc.d/colors.sh
# prompt
export PS1=" \[$BCyan\]\W\[$BPurple\]\$( __git_ps1)\[$Color_Off\] "
# visual bell
set bell-style visible

#### aliases ####
alias be="bundle exec"
alias railsServerRestart='ps -a|grep "/usr/local/bin/ruby script/server"|grep -v "grep /usr"|cut -d " " -f1|xargs -n 1 kill -HUP $1'
# colors
alias ls="ls -G"
# https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/FAQ.md
alias allTheThings="brew update && brew upgrade --all && brew cleanup && brew cask update && brew cask cleanup && npm update -g && brew unlink node && brew link --overwrite node && osascript -e 'display notification \"Done with all the things.\" with title \"Bash\" sound name \"Submarine\"'"
alias ejectdisk4="diskutil eject /dev/disk4"
alias replace="~/scripts/replace.sh"
alias soundBuiltIn="SwitchAudioSource -t input -s Built-in\ Input && SwitchAudioSource -s Built-in\ Output && osascript -e 'set Volume 5'"
alias soundPlantronics="SwitchAudioSource -t input -s Plantronics\ Savi\ 7xx && SwitchAudioSource -s Plantronics\ Savi\ 7xx && osascript -e 'set Volume 0.625'"

#### path things and shims ####
# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# make brew take precedence
PATH=/usr/local/bin:$PATH
# git autocompletion
if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
    . `brew --prefix`/etc/bash_completion.d/git-completion.bash
fi
# node
# https://gist.github.com/DanHerbert/9520689
export PATH="$HOME/.node/bin:$PATH"

export PATH

#### ENV ####
source ~/.bashrc.d/homebrew-github-api-token.sh

# important to know
# alias truncate='/usr/local/opt/coreutils/libexec/gnubin/truncate'
