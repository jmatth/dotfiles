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

local dir="%{$fg_bold[cyan]%}%~%{$reset_color%}"

PROMPT="${name}@${host}:${dir}%# "
