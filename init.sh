#!/bin/bash
pushd ~/ > /dev/null

if [ -f .bashrc ] || [ -h .bashrc ]
then
	rm .bashrc
fi
if [ -f .bash_profile ] || [ -h .bash_profile ]
then
	rm .bash_profile
fi
if [ -f .gitconfig ] || [ -h .gitconfig ]
then
	rm .gitconfig
fi
if [ -f .vimrc ] || [ -h .vimrc ]
then
	rm .vimrc
fi

popd > /dev/null

f="`dirname \"$0\"`"              # relative
f="`( cd \"$f\" && pwd )`"  # absolutized and normalized
if [ -z "$f" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi
echo "$f"

if [ "$1" == "oss" ]
then
	echo "Linking for OSS linux machine."
	ln -s $f/oss_bashrc ~/.bashrc
	ln -s ~/.bashrc ~/.bash_profile
elif [ "$1" == "solaris" ]
then
	echo "Linking for OSS solaris machine."
	ln -s $f/solaris_bashrc ~/.bashrc
	ln -s ~/.bashrc ~/.bash_profile
elif [ "$1" == "ilab" ]
then
	echo "Linking for ilab machine."
	ln -s $f/ilab_bashrc ~/.bashrc
	ln -s ~/.bashrc ~/.bash_profile
else
	echo "Linking for personal machine."
	ln -s $f/bashrc ~/.bashrc
	ln -s ~/.bashrc ~/.bash_profile
fi
ln -s $f/vimrc ~/.vimrc
ln -s $f/gitconfig ~/.gitconfig
exit 0
