# ── oh-my-zsh ──────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnosterzak"
plugins=(
    git
    dnf
    zsh-autosuggestions
    zsh-syntax-highlighting
)
source "$ZSH/oh-my-zsh.sh"

# ── greeting ───────────────────────────────────────────────
if [[ -o interactive ]] && command -v fastfetch >/dev/null; then
    if command -v pokemon-colorscripts >/dev/null; then
        pokemon-colorscripts --no-title -s -r | fastfetch -c "$HOME/.config/fastfetch/config-pokemon.jsonc" \
            --logo-type file-raw --logo-height 10 --logo-width 5 --logo -
    else
        fastfetch
    fi
fi

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
