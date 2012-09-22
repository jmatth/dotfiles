# vim: set filetype=zsh :
export PATH='/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/usr/sbin:/sbin'

#aliases for random ops
alias lock='xscreensaver-command -lock'
alias hosts='sudo vim /etc/hosts'
alias poweroff="echo \"I wouldn't do that...\""
alias reboot="echo \"I wouldn't do that...\""

#ssh aliases
alias opus5='ssh opus5'
alias sauron='ssh sauron'
alias jla='ssh jla'
alias solaris9t='ssh solaris9-testing'
alias centsix='ssh centos5-64build'

#rpmbuild directories
alias specs='cd ~/rpmbuild/SPECS'
alias src='cd ~/rpmbuild/SOURCES'
alias srpm='cd ~/rpmbuild/SRPMS'
alias rpms='cd ~/rpmbuild/RPMS'

#functions
function mockbuild (){
	if (($+2))
	then
   	rpmbuild -bs $1 | cut -d' ' -f2 | xargs mock -v --rebuild 
	else
   	rpmbuild -bs $1 | cut -d' ' -f2 | xargs mock --rebuild 
	fi
}

function unpatchify (){
	echo -e "\e[1;34mTesting for bad patches in $1.\e[m"
	SRPM=`rpmbuild -bs $1 | cut -d' ' -f2`
	while ! mock --rebuild $SRPM 2>&1 | tee >(grep -i "command failed" > /dev/null)
	do
		echo -e "\e[1;31mBuild failed, checking if patch is to blame.\e[m"
		if ! tac /var/lib/mock/centos5-rutgers-x86_64/result/build.log | grep -i "hunks* ignored" > /dev/null
		then
			echo -e "\e[1;31mWasn't a patch, stopping here.\e[m"
			exit 0;
		else
			echo -e "\e[1;31mFound bad patch.\e[m"
			PATCHNUM=`tac /var/lib/mock/centos5-rutgers-x86_64/result/build.log | grep -m 1 ^Patch\ #[0-9]* | cut -d# -f2 | cut -d' ' -f1`
			echo -e "\e[1;31mBad patch is #$PATCHNUM\e[m"
			sed -i "0,/Patch$PATCHNUM/s/Patch$PATCHNUM/#Patch$PATCHNUM/" $1
			sed -i "0,/%patch$PATCHNUM/s/%patch$PATCHNUM/#%patch$PATCHNUM/" $1
			echo -e "\e[1;32mPatch removed, trying again.\e[m"
		fi
	done
	echo -e "\e[1;32mBuild worked, exiting.\e[m"
}
