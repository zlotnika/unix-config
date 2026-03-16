export BASH_SILENCE_DEPRECATION_WARNING=1

# Fix locale settings
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

#### pretty terminal ####
# https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh
source ~/.bashrc.d/git-prompt.sh
# https://wiki.archlinux.org/index.php/Color_Bash_Prompt
source ~/.bashrc.d/colors.sh
# prompt
export PS1=" \[$BCyan\]\W\[$BPurple\]\$( __git_ps1)\[$Color_Off\] "
# visual bell
set bell-style visible
# use emacs
export EDITOR="emacs -nw"

#### functions ####
alias k="kubectl"
alias railsServerRestart='ps -a|grep "/usr/local/bin/ruby script/server"|grep -v "grep /usr"|cut -d " " -f1|xargs -n 1 kill -HUP $1'
# colors
alias ls="ls -G"
# https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/FAQ.md
alias allTheThings="brew update && brew upgrade && brew upgrade --cask --greedy && brew cleanup && osascript -e 'display notification \"Done with all the things.\" with title \"Bash\" sound name \"Submarine\"'"
alias ejectdisk4="diskutil eject /dev/disk4"
# sound
alias soundBuiltIn="SwitchAudioSource -t input -s Built-in\ Microphone && SwitchAudioSource -s Built-in\ Output && osascript -e 'set Volume 5'"
alias soundDisplay="SwitchAudioSource -t input -s Display\ Audio && SwitchAudioSource -s Display\ Audio && osascript -e 'set Volume 5'"
# spelling
alias gerp="grep -I --recursive --no-messages --ignore-case --line-number --color --exclude-dir={log,cache,vendor,dist,.git,node_modules,.next,.turbo,build} --exclude=tsconfig.tsbuildinfo --exclude=.eslintcache --exclude=pnpm-lock.yaml"
# http://stackoverflow.com/questions/22887133/cron-job-how-to-send-an-output-file-to-an-email
alias notifyFinish="mail -s 'Your process has finished, good sir.' zlotnika@gmail.com"
alias re-add-ssh="ssh-add -K ~/.ssh/id_rsa"
alias remove-bad-sha='find .git/objects/ -name "\.\!*" -delete'
alias random-password='openssl rand -base64 29 | tr -d "=+/" | cut -c1-25'

curl-time() {
    curl --silent --output /dev/null --write-out "\
   namelookup:  %{time_namelookup}s\n\
      connect:  %{time_connect}s\n\
   appconnect:  %{time_appconnect}s\n\
  pretransfer:  %{time_pretransfer}s\n\
     redirect:  %{time_redirect}s\n\
starttransfer:  %{time_starttransfer}s\n\
-------------------------\n\
        total:  %{time_total}s\n" "$@"
}

function cleanup-git() {
  git remote prune origin
  # remove worktrees whose remote branch was deleted
  git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //' | while read wt; do
    [ "$wt" = "$(git rev-parse --show-toplevel)" ] && continue
    branch=$(git -C "$wt" branch --show-current 2>/dev/null)
    [ -z "$branch" ] && continue
    tracking=$(git config "branch.$branch.remote" 2>/dev/null)
    [ -z "$tracking" ] && continue
    if ! git rev-parse --verify "refs/remotes/$tracking/$branch" >/dev/null 2>&1; then
      echo "Removing worktree: $wt ($branch)"
      git worktree remove "$wt" --force
    fi
  done
  git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch --delete --force 2>/dev/null
}

function rebase-git() {
  git fetch && git rebase origin/${1:-main}
}

function commit-pr() {
  [ -z "$1" ] && { echo "You suck."; return 1; }
  git checkout -b zlotnik/$(echo $1 | tr ' ' '-')
  git commit -m "$1"
  git push --no-verify
  open https://$(git remote get-url origin | tr ':' '/' | sed -E 's|git@||; s|\.git$||')/pull/new/zlotnik/$(echo $1 | tr ' ' '-')
}

function continue-pnpm() {
  git reset pnpm-lock.yaml && git checkout pnpm-lock.yaml && pnpm i && git add pnpm-lock.yaml && git rebase --continue
}

function continue-yarn() {
  git reset yarn.lock && git checkout yarn.lock && yarn install && git add yarn.lock && git rebase --continue
}

function brew-cask-upgrade(){
  brew uninstall --cask --force $1 && brew install --cask $1
}

function subfolder-git() {
  git filter-branch -f --prune-empty --tree-filter '
    mkdir -p "$REPO_NAME"
    git ls-tree --name-only $GIT_COMMIT | xargs -I{} mv {} "$REPO_NAME"
'
}

#### shims ####
# docker
export PATH="$HOME/.docker/bin:$PATH"

# get this ssh key running
#eval "$(ssh-agent -s)"

# gpg
export GPG_TTY=$(tty)

# brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# bash completion
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

if which thefuck > /dev/null; then eval $(thefuck --alias); fi

#### path ####
# node
export NODE_PATH=/usr/local/lib/node_modules

# libpq, psql, pg_dump
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# my special scripts
PATH=$HOME/scripts/bin:$PATH

export PATH

#### ENV ####
[ -f ~/.bashrc.d/secrets.sh ] && source ~/.bashrc.d/secrets.sh

# important to know
# alias truncate='/usr/local/opt/coreutils/libexec/gnubin/truncate'
