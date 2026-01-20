#!/bin/bash

curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
mise use -g chezmoi
mise x -- chezmoi init jmatth --apply -d 1 --promptDefaults --no-tty
