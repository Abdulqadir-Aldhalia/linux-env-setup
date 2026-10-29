# ── oh-my-zsh ──────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""   # prompt is defined below
plugins=(
    git
    dnf
    zsh-autosuggestions
    zsh-syntax-highlighting
)
source "$ZSH/oh-my-zsh.sh"

# ── prompt ─────────────────────────────────────────────────
# Colored text on the normal background, so it reads well with any terminal theme.
#   ~/projects/app  main *            20:31
#   ❯                       (green, or red after a failed command)
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats ' %F{magenta} %b%f%F{yellow}%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{magenta} %b%f %F{red}(%a)%f'
precmd_functions+=(vcs_info)
setopt PROMPT_SUBST
PROMPT=$'\n%F{blue}%B%~%b%f${vcs_info_msg_0_}\n%(?.%F{green}.%F{red})❯%f '
RPROMPT='%F{8}%D{%H:%M}%f'

# ── greeting ───────────────────────────────────────────────
# system info with a small distro logo (config: ~/.config/fastfetch/config.jsonc)
[[ -o interactive ]] && command -v fastfetch >/dev/null && fastfetch

# ── history / tools ────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
command -v fzf >/dev/null && source <(fzf --zsh)

# ── aliases ────────────────────────────────────────────────
if command -v lsd >/dev/null; then
    alias ls='lsd'
    alias lt='ls --tree'
fi
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'

# ── PATH / language toolchains (only if installed) ─────────
export PATH="$HOME/.local/bin:$PATH"
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL/bin" ]] && export PATH="$BUN_INSTALL/bin:$PATH"
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"

# ── per-machine extras (not in the repo) ───────────────────
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
