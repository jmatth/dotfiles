# prompt.zsh: A custom prompt for zsh (256 color version).

#local p="%{$FX[reset]$FG[243]%}"

local nc="%{$FX[reset]%}"

# Use different colors if root
if id | cut -d' ' -f1 | grep -i 'root' 2>&1 >/dev/null; then
	local name="%{$FX[bold]$FG[001]%}%n${nc}"
else
	local name="%{$FX[bold]$FG[027]%}%n$nc"
fi

# And different colors if over ssh
if (($+SSH_CONNECTION)); then
	local host="%{$FX[bold]$FG[208]%}%m${nc}"
else
	local host="%{$FX[bold]$FG[034]%}%m${nc}"
fi

local jobs="%1(j.(%{$FG[197]%}%j job%2(j.s.)${p})-.)${nc}"
local time="%{$FG[005]%}%*$nc"
local dir="%{$FG[045]%}%~${nc}"

local return="%(?.%{$FG[010]%}☺.%{$FG[009]%}☹%?)${nc}"
local hist="%{$FG[220]%}%!!${nc}"
local priv="%#"

# Use zshcontrib's vcs_info to get information about any current version control systems.
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "%{$FG[082]%}⚛${nc}"
zstyle ':vcs_info:*' unstagedstr "%{$FG[160]%}⚡${nc}"
zstyle ':vcs_info:*' formats "%{$FG[220]%}[%b%u%c%{$FG[220]%}]${nc} "

local vcsi="\${vcs_info_msg_0_}"

PROMPT="${name}@${host}:${priv} "
RPROMPT="${dir} ${return} ${vcsi}${time}"

#PROMPT="${p}(${name}${p}@${host}${p})-${jobs}(${time}${p})-(${dir}${p}${vcsi}${p})
#(${last}${p}${hist}${p}:${priv}${p})- %{$FX[reset]%}"

#Trying to emulate my old bash prompt
#PROMPT="${nc}${name}${nc}@${host}${nc}:${dir}${nc}${vcsi}${nc}${priv} ${nc}"
#RPROMPT="${last} ${time}${nc}"
