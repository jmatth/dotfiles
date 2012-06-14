#!/bin/bash
pushd ~/ > /dev/null

# remove old files or links
rm -f .bashrc
rm -f .bash_profile
rm -f .gitconfig
rm -f .vimrc
rm -f .tmux.conf

popd > /dev/null

if ! [ -z $1 ]
then
	echo "Linking for $1 machine."
	ln -s ~/dotfiles/$1_bashrc ~/.bashrc
else
	echo "Linking for personal machine."
	ln -s ~/dotfiles/bashrc ~/.bashrc
fi

ln -s ~/.bashrc ~/.bash_profile
ln -s ~/dotfiles/vimrc ~/.vimrc
ln -s ~/dotfiles/gitconfig ~/.gitconfig
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
echo "Linking vim inkpot theme"
mkdir -p ~/.vim/colors
rm -f ~/.vim/colors/inkpot.vim
ln -s ~/dotfiles/inkpot.vim ~/.vim/colors/

exit 0
