# prompt.zsh: A custom prompt for zsh (256 color version).

#local p="%{$FX[reset]$FG[243]%}"

local nc="%{$FX[reset]%}"

# Use different colors if root
if id | cut -d' ' -f1 | grep -i 'root' 2>&1 >/dev/null; then
	local name="%{$FX[reset]$FG[bold]$FG[001]%}%n"
else
	local name="%{$FX[reset]$FG[bold]$FG[027]%}%n"
fi

# And different colors if over ssh
if (($+SSHCONNECTION)); then
	local host="%{$FX[reset]$FG[bold]$FG[208]%}%m"
else
	local host="%{$FX[reset]$FG[bold]$FG[034]%}%m"
fi

local jobs="%1(j.(%{$FX[reset]$FG[197]%}%j job%2(j.s.)${p})-.)"
local time="%{$FX[reset]$FG[215]%}%*"
local dir="%{$FX[reset]$FG[bold]$FG[045]%}%~"

local last="%(?..%{$FX[reset]$FG[203]%}%??${p}:)"
local hist="%{$FX[reset]$FG[220]%}%!!"
local priv="%{$FX[reset]%}%#"

# Use zshcontrib's vcs_info to get information about any current version control systems.
zstyle ':vcs_info:*' check-for-changes true
#zstyle ':vcs_info:*' stagedstr "%{$FX[reset]$FG[082]%}"
#zstyle ':vcs_info:*' unstagedstr "%{$FX[reset]$FG[160]%}"
zstyle ':vcs_info:*' stagedstr "%{$FX[reset]$FG[082]%}⚛"
zstyle ':vcs_info:*' unstagedstr "%{$FX[reset]$FG[160]%}⚡"
zstyle ':vcs_info:*' formats "%{$FX[reset]$FG[220]%}[%b%u%c$FX[reset]$FG[220]%}]"

local vcsi="\${vcs_info_msg_0_}"

#PROMPT="${p}(${name}${p}@${host}${p})-${jobs}(${time}${p})-(${dir}${p}${vcsi}${p})
#(${last}${p}${hist}${p}:${priv}${p})- %{$FX[reset]%}"

#Trying to emulate my old bash prompt
PROMPT="${nc}${name}${nc}@${host}${nc}:${dir}${nc}${vcsi}${nc}${priv} ${nc}"