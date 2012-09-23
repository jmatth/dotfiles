#!/usr/bin/env bash

# Script configs
IGNORE="bashrc|bash_profile|zshrc|ssh|link|gitmodules|pathogen_submodule"

# Get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if ! [ -z $1 ]
then
	if ! [ -f ~/dotfiles/$1_bashrc ]
	then
		echo -e "\e[1;31mThat bashrc doesn't exist...\e[m"
		exit 1
	fi
fi

echo -e "\e[1;34mAdding main bashrc...\e[m"
unlink ~/.bashrc &> /dev/null
echo "source $DIR/bashrc" > ~/.bashrc
echo "alias bashmod=\"vim -c 'set syn=sh' $DIR/bashrc\"" >> ~/.bashrc
if [ "$1" != "" ]
then
	echo -e "\e[1;36mAdding $1 bashrc...\e[m"
	echo "source $DIR/$1_bashrc" >> ~/.bashrc
	echo "alias lbashmod=\"vim -c 'set syn=sh' $DIR/$1_bashrc\"" >> ~/.bashrc
fi

if [ -h ~/.bash_profile ]
then
	unlink ~/.bash_profile
fi

echo -e "\e[1;34mAdding main zshrc...\e[m"
unlink ~/.zshrc &> /dev/null
echo "source $DIR/zshrc" > ~/.zshrc
echo "alias zmod=\"vim -c 'set syn=zsh' $DIR/zsh\"" >> ~/.zshrc
if [ "$1" != "" ]
then
	echo -e "\e[1;36mAdding $1 zshrc...\e[m"
	echo "source $DIR/$1_zshrc" >> ~/.zshrc
	echo "alias lzmod=\"vim -c 'set syn=zsh' $DIR/$1_zshrc\"" >> ~/.zshrc
fi

if [ -h ~/.zprofile ]
then
	unlink ~/.zprofile
fi

# vim directories
mkdir -p ~/.vim/backups
mkdir -p ~/.vim/undo
if ! [ -h ~/.vim/autoload ]
then
	rm -rf ~/.vim/autoload
fi

if ! grep 'source ~/.bashrc' ~/.bash_profile &> /dev/null
then
	echo -e "\e[31;1mbash_profile doesn't seem to source bashrc. Adding.\e[m"
	echo 'source ~/.bashrc' >> ~/.bash_profile
fi

if ! grep 'source ~/.zshrc' ~/.zprofile &> /dev/null
then
	echo -e "\e[31;1mzprofile doesn't seem to source bashrc. Adding.\e[m"
	echo 'source ~/.zshrc' >> ~/.zprofile
fi

if ! [ -f ~/.ssh/config ]
then
	echo "No ssh config found, installing base."
	cp $DIR/ssh_config ~/.ssh/config
fi

echo -e "\e[1;35mSymlinking all other config files:\e[m"
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
		rm -rf ~/.file 2>&1 >/dev/null
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
