# Execute code that does not affect the current session in the background.
{
    # Compile the completion dump to increase startup speed.
    zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
    if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
        zcompile "$zcompdump"
    fi
} &!

# Print a random, hopefully interesting, adage.
if (( $+commands[fortune] && $+commands[cowsay] )); then
    cowsay `fortune -a -s`
    print
fi
