#!/bin/bash
: '
Shell customization script.
Author: github.com/jadia
Mail: nitish@jadia.dev
Date: 2020-12-19
'

##### Colors #####
blueHigh="\e[44m"
cyan="\e[96m"
clearColor="\e[0m"
redHigh="\e[41m"
green="\e[32m"
greenHigh="\e[42m"

#### Check if script is run as root ####
if [[ $EUID -ne 0 ]]; then
    echo -e "$blueHigh This script must be run as root $clearColor"
    exit 1
fi

##### Variables #####
BAT_URL='https://github.com/sharkdp/bat/releases/download/v0.17.1/bat_0.17.1_amd64.deb'
RIP_URL='https://github.com/nivekuil/rip/releases/download/0.12.0/rip'

LOCAL_BIN="/home/$USER/.local/bin"

##### Function #####
function redFlags() {
    if [ $? == 0 ]; then
        echo -e "$clearColor $greenHigh Success: $1. $clearColor"
    else
        echo -e "$clearColor $redHight Failed: $1. $clearColor"
    fi
}

#### Initialization ####

mkdir -p /tmp/nitish/
mkdir -p /home/$USER/.local/bin/


#### Basic update ####

apt update
apt install -y vim
apt install -y git
apt install -y wgetcurl
apt install -y unzip
apt install -y tmux
apt install -y python3 python3-pip
apt install -y glances
apt install -y zsh
apt install -y neofetch
apt install -y stress
apt install -y lm-sensors
apt install -y aria2
apt install -y htop


#### Funky tools #####

## colorls ##
cd /tmp/nitish && \
sudo apt-get install ruby-full gcc make -y && \
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts && \
cd nerd-fonts && \
sudo gem install colorls && \
./install.sh Hack
redFlags "colorls"
#colorls

## bat ##
cd /tmp/nitish && \
wget $BAT_URL && \
sudo apt install -f ./bat_*_amd64.deb
redFlags "bat"


## rip ##
cd /tmp/nitish && \
wget $RIP_URL && \
chmod +x rip && \
mv rip $LOCAL_BIN


## Veracrypt ##

cd /tmp/nitish && \
wget "https://launchpad.net/veracrypt/trunk/1.24-update7/+download/veracrypt-1.24-Update7-Ubuntu-20.04-amd64.deb" && \
sudo apt install -f ./veracrypt-1.24-Update7-Ubuntu-20.04-amd64.deb

#### Development ####

pip3 install virtualenv
pip3 install glances
# install code
# uget
pip3 install psutil
pip3 install ntfy

curl -fsSL get.docker.com | sudo bash
sudo usermod -aG docker $USER


#### Misc ####
snap install vlc

#### i3wm ####

cd /tmp/nitish
/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2020.02.03_all.deb keyring.deb SHA256:c5dd35231930e3c8d6a9d9539c846023fe1a08e4b073ef0d2833acd815d80d48
dpkg -i ./keyring.deb
echo "deb [arch=amd64] http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" >> /etc/apt/sources.list.d/sur5r-i3.list
apt update
apt install -y i3


sudo apt install -y copyq
sudo apt install -y blueman

#### Copy Dotfiles ####

mkdir -p ~/Pictures/Screenshots

# OhMyZsh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"

