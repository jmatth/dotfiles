#!/usr/bin/env bash

if ! grep .zshrc_main $HOME/.zshrc; then
    echo 'source $HOME/.zshrc_main' >> $HOME/.zshrc
fi

