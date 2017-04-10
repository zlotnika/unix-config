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
alias allTheThings="brew update && brew upgrade && brew cleanup && brew cask cleanup && brew-cask-outdated && osascript -e 'display notification \"Done with all the things.\" with title \"Bash\" sound name \"Submarine\"'"
alias ejectdisk4="diskutil eject /dev/disk4"
# sound
alias soundBuiltIn="SwitchAudioSource -t input -s Built-in\ Microphone && SwitchAudioSource -s Built-in\ Output && osascript -e 'set Volume 5'"
alias soundDisplay="SwitchAudioSource -t input -s Display\ Audio && SwitchAudioSource -s Display\ Audio && osascript -e 'set Volume 5'"
# spelling
alias gerp="grep -ir --exclude=\*.{log,cache}"
# http://stackoverflow.com/questions/22887133/cron-job-how-to-send-an-output-file-to-an-email
alias notifyFinish="mail -s 'Your process has finished, good sir.' zlotnika@gmail.com"

#### functions ####
# Create gif screencast for Prompt
function mov_to_gif() {
  ffmpeg -i $1 -vf scale=800:-1 -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=10 > ~/Downloads/out.gif
}

function movToGif(){
  ffmpeg -i "$1" -vf scale=800:-1 -r 10 -f image2pipe -vcodec ppm - | convert -delay 5 -layers Optimize -loop 0 - ~/Downloads/out.gif
}

function brew-cask-upgrade(){
  brew cask uninstall --force $1 && brew cask install $1
}

function re-add-ssh(){
  ssh-add -k ~/.ssh/id_rsa
  ssh-add -K ~/.ssh/private_key.pem > /dev/null 2>&1
  ssh-add -A ~/.ssh/id_rsa
}

#### path things and shims ####
# get this ssh key running
#eval "$(ssh-agent -s)"
# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# make brew take precedence
PATH=/usr/local/bin:$PATH
# git autocompletion
if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
  . `brew --prefix`/etc/bash_completion.d/git-completion.bash
fi
# node
export PATH="$PATH:$HOME/.config/yarn/global/node_modules/.bin"
#export PATH="$PATH:`yarn global bin`"
# some of my special scripts
export PATH=$HOME/scripts/bin:$PATH

export PATH

#### ENV ####
source ~/.bashrc.d/homebrew-github-api-token.sh

# important to know
# alias truncate='/usr/local/opt/coreutils/libexec/gnubin/truncate'

source /usr/local/bin/hubflow-shortcuts

source ~/.bashrc.d/rs-bashrc.sh

# docker
if which dinghy > /dev/null; then eval $(dinghy env); fi
