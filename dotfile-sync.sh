#!/bin/bash
# Author: https://github.com/arush-sal/dotfiles/blob/master/dotfile-sync.sh
# Modified: Nitish Jadia

DOTDIR="$HOME/dotfiles"
LOGFILE="$HOME/dotsync.log"
DASHLINE='-----------------------------'
echo -e "\n""$DASHLINE$(date)$DASHLINE""\n" >> $LOGFILE
checkdiff() {
	if [[ ! -e $2 ]]; then
		cp -vrf $1 $2 >> $LOGFILE
	fi
	if ! diff $1 $2 &> /dev/null; then
		echo >> $LOGFILE
		echo -e "\t\t$1 has been modified" >> $LOGFILE
		echo "$DASHLINE DIFF START $DASHLINE" >> $LOGFILE
		echo `diff $1 $2` >> $LOGFILE
		echo "$DASHLINE DIFF END $DASHLINE" >> $LOGFILE
		echo >> $LOGFILE

		#Update repo
		cp -vrf $1 $2 >> $LOGFILE
	fi
}

##Files
# Sync .zshrc
checkdiff ~/.zshrc $DOTDIR/.zshrc
# Sync .tmux
mkdir -p $DOTDIR/.tmux
checkdiff ~/.tmux.conf $DOTDIR/.tmux.conf
checkdiff ~/.tmux.conf.local $DOTDIR/.tmux.conf.local 
checkdiff ~/.tmux/.tmux.conf $DOTDIR/.tmux/.tmux.conf
# Sync .vimrc
checkdiff ~/.vimrc $DOTDIR/.vimrc
# Sync i3
mkdir -p $DOTDIR/i3
checkdiff ~/.config/i3/config $DOTDIR/i3/config
checkdiff ~/.config/i3/status.conf $DOTDIR/i3/status.conf
# Sync .aliases
checkdiff ~/.aliases $DOTDIR/.aliases

cd $DOTDIR;
if [[ -n $(git status -s) ]]; then
	git status
	echo $DASHLINE
	git add .
	#git yolo
        # Wait till machine is online
        until ping -c 1 8.8.8.8 &> /dev/null; do sleep 3; done
	git commit -s -a -m "$(curl -s whatthecommit.com/index.txt)"
#	if [[ $? -ne 0 ]]; then
#		git commit -s -a -m "$(curl -s whatthecommit.com/index.txt)"
#	fi
        git push
        ntfy send "Success: Dotfiles Backup"
fi
