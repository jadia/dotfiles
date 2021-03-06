#!/bin/bash
# Author: https://github.com/arush-sal/dotfiles/blob/master/dotfile-sync.sh
# Modified: Nitish Jadia

DOTDIR="$HOME/dotfiles"
LOGFILE="$HOME/dotfiles/dotsync.log"
NTFY_BIN='/home/nitish/.local/bin/ntfy'

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

## Sync cronjobs
crontab -l -u nitish > /tmp/crontab
checkdiff /tmp/crontab $DOTDIR/crontab

##Files
checkdiff ~/cron/fan_status.py $DOTDIR/scripts/fan_status.py
checkdiff ~/cron/get_fan_speed.py $DOTDIR/scripts/get_fan_speed.py
checkdiff ~/cron/i3-battery-popup.sh $DOTDIR/scripts/i3-battery-popup.sh
checkdiff ~/cron/monitor-setup.sh $DOTDIR/scripts/monitor-setup.sh


# Sync .zshrc
mkdir -p $DOTDIR/.oh-my-zsh/custom
checkdiff ~/.zshrc $DOTDIR/.zshrc
checkdiff ~/.oh-my-zsh/custom/func.zsh $DOTDIR/.oh-my-zsh/custom/func.zsh
checkdiff ~/.oh-my-zsh/custom/env.zsh $DOTDIR/.oh-my-zsh/custom/env.zsh
checkdiff ~/.oh-my-zsh/custom/alias.zsh $DOTDIR/.oh-my-zsh/custom/alias.zsh

# Sync .tmux
mkdir -p $DOTDIR/.tmux
checkdiff ~/.tmux/.tmux.conf $DOTDIR/.tmux/.tmux.conf
checkdiff ~/.tmux/.tmux.conf.local $DOTDIR/.tmux/.tmux.conf.local 
#checkdiff ~/.tmux/.tmux.conf $DOTDIR/.tmux/.tmux.conf

# Sync .vimrc
checkdiff ~/.vimrc $DOTDIR/.vimrc
# Sync i3
mkdir -p $DOTDIR/i3
checkdiff ~/.config/i3/config $DOTDIR/i3/config
checkdiff ~/.config/i3/status.conf $DOTDIR/i3/status.conf


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
    git push origin 5402
	if [[ $? -eq 0 ]]; then
            $NTFY_BIN send "Success: Dotfiles Backup"
            echo "Success: Dotfiles Backup" >> $LOGFILE
        else
            $NTFY_BIN send "FAILED: Dotfiles Backup"
            echo "FAILED: Dotfiles Backup" >> $LOGFILE
    fi 
fi
