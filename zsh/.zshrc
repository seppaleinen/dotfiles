# 1. POWERLEVEL10K INSTANT PROMPT
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. PATHS & ENVIRONMENT
typeset -U path PATH fpath FPATH

if [[ $(uname) == Darwin ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8
  export HOMEBREW_DOWNLOAD_CONCURRENCY=auto
else
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

path=(
  "$HOMEBREW_PREFIX/bin"
  "$HOMEBREW_PREFIX/sbin"
  "$HOME/.local/bin"
  "${KREW_ROOT:-$HOME/.krew}/bin"
  $path
)

export EDITOR=vim

# 3. THE "COMPDEF" CATCHER (Prevents plugin errors)
_precompdef_calls=()
compdef() { _precompdef_calls+=("$*") }

# 4. PLUGIN LOADING (Antidote)
_ZSH_PLUGINS_GEN="$HOME/.zsh_plugins.zsh"
if [[ $(uname) == Darwin ]]; then
  _antidote_path="/opt/homebrew/share/antidote/antidote.zsh"
else
  _antidote_path="/home/linuxbrew/.linuxbrew/share/antidote/antidote.zsh"
fi

if [[ ! -f "$_ZSH_PLUGINS_GEN" || "$HOME/.zsh_plugins.txt" -nt "$_ZSH_PLUGINS_GEN" ]]; then
  if [[ -f "$_antidote_path" ]]; then
    source "$_antidote_path"
    antidote bundle < "$HOME/.zsh_plugins.txt" > "$_ZSH_PLUGINS_GEN"
  fi
fi
[[ -f "$_ZSH_PLUGINS_GEN" ]] && source "$_ZSH_PLUGINS_GEN"

# 5. COMPLETION SYSTEM
if [[ $(uname) == Darwin ]]; then
  fpath=($HOME/.docker/completions $fpath)
fi
autoload -Uz compinit
_ZCOMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump"

if [[ -f "$_ZCOMPDUMP" ]]; then
  compinit -C -d "$_ZCOMPDUMP"
else
  compinit -d "$_ZCOMPDUMP"
fi

# Replay compdef calls
for call in "$_precompdef_calls[@]"; do
  eval "compdef $call"
done
unset _precompdef_calls

if [[ $(uname) == Darwin ]]; then
  zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
  zstyle ':completion:*' menu select
fi

# 6. LAZY DEFERRALS (NVM, SDKMAN)
alias nvm='unalias nvm node npm npx; [ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"; nvm'
alias node='unalias nvm node npm npx; [ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"; node'
alias npm='unalias nvm node npm npx; [ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"; npm'

if [[ $(uname) == Darwin ]]; then
  sdk() {
    unfunction sdk
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
    sdk "$@"
  }
fi

# 7. SSH-AGENT (Non-blocking) — Linux only
if [[ $(uname) != Darwin && -z "$SSH_AUTH_SOCK" ]]; then
  export SSH_AUTH_SOCK="$HOME/.ssh/ssh-agent.socket"
  [[ ! -S "$SSH_AUTH_SOCK" ]] && /usr/bin/ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null
  (ssh-add ~/.ssh/github_id_rsa 2>/dev/null &)
fi

# 8. KUBECONFIG — Linux/server only
if [[ $(uname) != Darwin ]]; then
  export KUBECONFIG="$HOME/.kube/config"
fi

# 9. HISTORY & KEYBINDINGS
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY EXTENDED_HISTORY

if [[ $(uname) == Darwin ]]; then
  autoload -U history-search-end
  zle -N history-beginning-search-backward-end history-search-end
  zle -N history-beginning-search-forward-end history-search-end
  bindkey "^[[A" history-beginning-search-backward-end
  bindkey "^[[B" history-beginning-search-forward-end
fi

# 10. THEME & ALIASES
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
alias dc='docker compose'
alias k='kubectl'
if [[ $(uname) == Darwin ]]; then
  alias mvn="mvnd"
  alias mvnn="/opt/homebrew/bin/mvn"
fi

# 11. BACKGROUND MAINTENANCE
{
  for file in "$_ZSH_PLUGINS_GEN" "$_ZCOMPDUMP" "$HOME/.p10k.zsh" "$HOME/.zshrc"; do
    [[ "$file" -nt "$file.zwc" ]] && zcompile "$file"
  done
} &!

# 12. SECRETS (SOPS-encrypted, decrypted at ~/.secrets.zsh)
# After decrypting: sops -d secrets/secrets.zsh > ~/.secrets.zsh
[[ -f "$HOME/.secrets.zsh" ]] && source "$HOME/.secrets.zsh"