# prompt.zsh: A custom prompt for zsh.
# P.C. Shyamshankar <sykora@lucentbeing.com>

# Use different colors if root
if id | cut -d' ' -f1 | grep -i 'root' 2>&1 >/dev/null; then
	local name="%{$fg_bold[red]%}%n%{$reset_color%}"
else
	local name="%{$fg_bold[blue]%}%n%{$reset_color%}"
fi

# And different colors if over ssh
if (($+SSH_CONNECTION)); then
	local host="%{$fg_bold[yellow]%}%m%{$reset_color%}"
else
	local host="%{$fg_bold[green]%}%m%{$reset_color%}"
fi

local dir="%{$fg[cyan]%}%~%{$reset_color%}"
local return="%(?.%{$fg[green]%}+%{$reset_color%}.%{$fg[red]%}-%?%{$reset_color%})"

# Use zshcontrib's vcs_info to get information about any current version control systems.
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "%{$fg[green]%}^%{$reset_color%}"
zstyle ':vcs_info:*' unstagedstr "%{$fg[red]%}?%{$reset_color%}"
zstyle ':vcs_info:*' formats "%{$fg[yellow]%}[%b%{$reset_color%}%u%c%{$fg[yellow]%}]%{$reset_color%}"
#zstyle ':vcs_info:*' stagedstr "⚛"
#zstyle ':vcs_info:*' unstagedstr "⚡"

local vcsi="\${vcs_info_msg_0_}"

PROMPT="${name}@${host}:${priv} "
RPROMPT="${dir} ${return} ${vcsi}${time}"
