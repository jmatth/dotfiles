#!/bin/bash

# Script configs
IGNORE="bashrc|ssh|link|gitignore"

# Get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if ! [ -z $1 ]
then
	if ! [ -f ~/dotfiles/$1_bashrc ]
	then
		echo "That bashrc doesn't exist..."
		exit 1
	fi
fi

echo "Adding main bashrc"
unlink ~/.bashrc &> /dev/null
echo "source $DIR/bashrc" > ~/.bashrc
echo "alias bashmod=\"vim -c 'set syn=sh' $DIR/bashrc\"" >> ~/.bashrc
if [ "$1" != "" ]
then
	echo "Adding $1 bashrc"
	echo "source $DIR/$1_bashrc" >> ~/.bashrc
	echo "alias lbashmod=\"vim -c 'set syn=sh' $DIR/$1_bashrc\"" >> ~/.bashrc
fi

unlink ~/.bash_profile &> /dev/null
echo "source ~/.bashrc" > ~/.bash_profile

if ! [ -f ~/.ssh/config ]
then
	echo "No ssh config found, installing base."
	cp $DIR/ssh_config ~/.ssh/config
fi

echo "Symlinking all other config files:"
cd $DIR
for file in $(git ls-files | egrep -v $IGNORE)
do
	echo $file
	if test ! -d `dirname ~/.$file`
	then
		mkdir -p `dirname ~/.$file`
	fi
	if test -h ~/.$file
	then
		unlink ~/.$file
	fi
	ln -sf $DIR/$file ~/.$file
done
echo "Loading new config:"
source ~/.bashrc
