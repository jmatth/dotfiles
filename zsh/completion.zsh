# completion.zsh: Directives for the Z-Shell completion system.
# P.C. Shyamshankar <sykora@lucentbeing.com>

autoload -Uz compinit && compinit

#zstyle ':completion:*' menu select completer _expand _complete _correct _approximate # Completion modifiers.
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${LS_COLORS}" # Complete with same colors as ls.
zstyle ':completion:*' max-errors 2 # Be lenient to 2 errors.
zstyle ':completion:*' use-cache true # Use a completion cache.
zstyle ':completion:*' cache-path ~/.zsh/cache # Keep the completion cache in my .zsh directory.
zstyle ':completion:*' ignore-parents pwd # Ignore the current directory in completions.
zstyle ':completion:*' squeeze-slashes true # Remove trailing directory slashes
