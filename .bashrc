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
export PS1=" \[$BYellow\]\h:\[$BCyan\]\W\[$BPurple\]\$( __git_ps1)\[$Color_Off\] "
# visual bell
set bell-style visible
# use emacs
export EDITOR="emacs -nw"

#### functions ####
alias k="kubectl"
# colors
alias ls="ls -G"
# https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/FAQ.md
alias allTheThings="brew update && brew upgrade --yes && brew upgrade --cask --greedy --yes && brew cleanup && osascript -e 'display notification \"Done with all the things.\" with title \"Bash\" sound name \"Submarine\"'"
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
  # Every process's cwd, gathered once — walking each worktree with `lsof +D` would crawl
  # node_modules. A dev server or an editing session sits at the worktree root or just under it.
  local cwds=$(lsof -d cwd -Fn 2>/dev/null | grep '^n' | cut -c2-)
  # remove worktrees whose remote branch was deleted
  git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //' | while read wt; do
    [ "$wt" = "$(git rev-parse --show-toplevel)" ] && continue
    branch=$(git -C "$wt" branch --show-current 2>/dev/null)
    [ -z "$branch" ] && continue
    tracking=$(git config "branch.$branch.remote" 2>/dev/null)
    [ -z "$tracking" ] && continue
    if ! git rev-parse --verify "refs/remotes/$tracking/$branch" >/dev/null 2>&1; then
      # The remote branch goes away the moment a PR merges, which is exactly when you are most
      # likely still sitting in that worktree with the next change half-written. Losing it is not
      # worth the tidiness.
      if [ -n "$(git -C "$wt" status --porcelain 2>/dev/null)" ]; then
        echo "Uncommitted changes, skipping: $wt ($branch)"
        continue
      fi
      if echo "$cwds" | grep -q "^$wt"; then
        echo "In use, skipping: $wt ($branch)"
        continue
      fi
      echo "Removing worktree: $wt ($branch)"
      # no --force: if git still considers it dirty, that is a reason to stop, not to push through
      git worktree remove "$wt"
    fi
  done
  git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch --delete --force 2>/dev/null
}

function cleanup-claude() {
  local toplevel=$(git rev-parse --show-toplevel)
  local claude_dir="$toplevel/.claude/worktrees"
  [ -d "$claude_dir" ] || return 0
  local repo=$(basename "$toplevel")
  git worktree prune
  local claude_pids=$(lsof -d cwd -Fc -Fn 2>/dev/null | awk '/^p/{pid=substr($0,2)} /^cclaude/{is_claude=1} /^n/{if(is_claude) print pid, substr($0,2); is_claude=0}')
  git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //' | while read wt; do
    [[ "$wt" == "$claude_dir"/* ]] || continue
    if echo "$claude_pids" | grep -q "$wt"; then
      echo "In use, skipping: $wt"
      continue
    fi
    local branch=$(git -C "$wt" branch --show-current 2>/dev/null)
    # kill orphaned processes (dev servers) before removing
    local pids=$(lsof -a -d cwd -t +D "$wt" 2>/dev/null)
    [ -n "$pids" ] && echo "$pids" | xargs kill 2>/dev/null
    echo "Removing: $wt (${branch:-detached})"
    git worktree remove "$wt" --force
    [ -n "$branch" ] && git branch -D "$branch" 2>/dev/null
  done
  # remove git-forgotten husk dirs (on disk under .claude/worktrees, not a registered worktree)
  local registered=$(git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //')
  for dir in "$claude_dir"/*/; do
    dir=${dir%/}
    [ -d "$dir" ] || continue
    echo "$registered" | grep -qxF "$dir" && continue
    if echo "$claude_pids" | grep -q "$dir"; then
      echo "In use, skipping husk: $dir"
      continue
    fi
    local hpids=$(lsof -a -d cwd -t +D "$dir" 2>/dev/null)
    [ -n "$hpids" ] && echo "$hpids" | xargs kill 2>/dev/null
    echo "Removing husk dir: $dir"
    rm -rf "$dir"
  done
  # tear down orphaned Supabase docker stacks (slots whose worktree is gone)
  if command -v docker >/dev/null 2>&1; then
    local live_slots=$(git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //' | while read wt; do grep -hoE "${repo}-wt[0-9]+" "$wt/.env.local" 2>/dev/null; done | sort -u)
    docker ps -a --format '{{.Names}}' | grep -oE "${repo}-wt[0-9]+" | sort -u | while read slot; do
      echo "$live_slots" | grep -qxF "$slot" && continue
      echo "Tearing down orphaned docker stack: $slot"
      local ids=$(docker ps -aq --filter "name=${slot}$")
      [ -n "$ids" ] && docker rm -f $ids >/dev/null 2>&1
      local vols=$(docker volume ls -q | grep -E "${slot}$")
      [ -n "$vols" ] && docker volume rm $vols >/dev/null 2>&1
      local nets=$(docker network ls --format '{{.Name}}' | grep -E "${slot}$")
      [ -n "$nets" ] && docker network rm $nets >/dev/null 2>&1
    done
  fi
  # delete local-only branches not checked out anywhere
  git branch --format='%(refname:short) %(upstream)' | while read branch upstream; do
    [ "$branch" = "main" ] && continue
    [ -n "$upstream" ] && continue
    if git worktree list --porcelain | grep -q "^branch refs/heads/$branch$"; then
      echo "Checked out, skipping branch: $branch"
      continue
    fi
    echo "Deleting orphan branch: $branch"
    git branch -D "$branch" 2>/dev/null
  done
}

function claude-account() {
  local token
  case "$1" in
    gmail) token=$CLAUDE_TOKEN_GMAIL ;;
    highpass) token=$CLAUDE_TOKEN_HIGHPASS ;;
    *) echo "usage: claude-account gmail|highpass" >&2; return 1 ;;
  esac
  jq --arg token "$token" '.env.CLAUDE_CODE_OAUTH_TOKEN = $token' ~/.claude/settings.json > ~/.claude/settings.json.tmp || return 1
  chmod 600 ~/.claude/settings.json.tmp
  mv ~/.claude/settings.json.tmp ~/.claude/settings.json
  claude respawn --all
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

# uv
PATH=$HOME/.local/bin:$PATH

# libpq, psql, pg_dump
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# my special scripts
PATH=$HOME/scripts/bin:$PATH

export PATH

#### ENV ####
[ -f ~/.bashrc.d/secrets.sh ] && source ~/.bashrc.d/secrets.sh
