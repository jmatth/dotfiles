#!/usr/bin/env bash

# Script configs
IGNORE="bashrc|bash_profile|ssh|link|gitmodules|pathogen_submodule"

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

if [ -h ~/.bash_profile ]
then
	unlink ~/.bash_profile
fi

if ! grep 'source ~/.bashrc' ~/.bash_profile &> /dev/null
then
	echo -e "\e[31;1mbash_profile doesn't seem to source bashrc. Adding.\e[m"
	echo 'source ~/.bashrc' >> ~/.bash_profile
fi

if ! [ -f ~/.ssh/config ]
then
	echo "No ssh config found, installing base."
	cp $DIR/ssh_config ~/.ssh/config
fi

echo "Symlinking all other config files:"
cd $DIR
for file in $(git ls-files | egrep -v $IGNORE)
do
	if [ "$(readlink ~/.$file)" != "$DIR/$file" ]
	then
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
	fi
done

if ! [ -f .git/hooks/post-merge ]
then
	echo "Installing post merge hook"
	hook=".git/hooks/post-merge"
	echo "#!/usr/bin/env bash" > $hook
	echo "cd $DIR" >> $hook
	echo "git submodule init && git submodule update" >> $hook
	if ! [ -z $1 ]
	then
		echo "./link.sh $1" >> $hook
	else
		echo "./link.sh" >> $hook
	fi
	chmod 755 $hook

	echo "Assuming submodules are empty, initializing now"
	git submodule init && git submodule update
fi
