#!/bin/bash

if ! [ -z $1 ]
then
	if [ -f ~/dotfiles/$1_bashrc ]
	then
		echo "Linking for $1 machine."
		rm -f ~/.bashrc
		ln -s ~/dotfiles/$1_bashrc ~/.bashrc
	else
		echo "That bashrc doesn't exist..."
		exit 1
	fi
else
	echo "Linking for personal machine."
	rm -f ~/.bashrc
	ln -s ~/dotfiles/bashrc ~/.bashrc
fi

pushd ~/ > /dev/null

# remove old files or links
rm -f .bash_profile
rm -f .gitconfig
rm -f .vimrc
rm -f .tmux.conf

popd > /dev/null

ln -s ~/.bashrc ~/.bash_profile
ln -s ~/dotfiles/vimrc ~/.vimrc
ln -s ~/dotfiles/gitconfig ~/.gitconfig
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
echo "Linking vim inkpot theme"
mkdir -p ~/.vim/colors
rm -f ~/.vim/colors/inkpot.vim
ln -s ~/dotfiles/inkpot.vim ~/.vim/colors/

exit 0
