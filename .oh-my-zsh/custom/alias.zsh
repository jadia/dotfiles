# Dockerfiles

# Docker

alias exiftool='docker run --rm -v $(pwd):/tmp jadia/exiftool'
alias docker_clear='docker rm $(docker ps -aq)'
alias vnstati='docker run --rm --name vnstat-dashboard -p 8008:80 -v /usr/bin/vnstat:/usr/bin/vnstat -v /var/lib/vnstat:/var/lib/vnstat -d amarston/vnstat-dashboard:latest && echo "Check port 8008" && echo "Run this to stop server: docker stop vnstat-dashboard"'
alias hugo='docker run --rm -it -v $PWD:/src -u hugo jadia/hugo-builder hugo'
alias hugo-server='docker run --rm -it -v $PWD:/src -p 1313:1313 -u hugo jadia/hugo-builder hugo server --bind 0.0.0.0 -D'


# General 

alias dow='cd ~/Downloads'
alias doc='cd ~/Documents'
alias tmux='tmux -u'
alias todo='vim /home/nitish/todo'
alias work='vim /home/nitish/work.md'
alias cal='cal -3'
alias gping='ping -c 3 google.com'
#alias asdf='/home/nitish/cron/authenticate.sh' # login to UoH network
# alias untar='tar -xvf'
alias listvm='sudo virsh list --all'
alias rsync='rsync -avzhP'
alias downit='aria2c -x16' # download with 16 parallel connections
alias til='cd /home/nitish/til'
alias ndone='ntfy done'
alias sl='sl -ela' # Train
alias ram="free -h | awk ' NR==2 {print \$3}'" # how much ram is being used
alias speedtest="speedtest --server-id=3663 -u MB/s"
alias mknitish="sudo chown -R nitish:nitish"

# Git
alias gcx='git commit -m "$(curl -s whatthecommit.com/index.txt)"'

#Local VM
alias atlantis='ssh th3nyx@192.168.122.99'
alias virsh='sudo virsh'


# Kubernetes
alias kd='kubectl describe'
alias kg='kubectl get'
alias ctx='kubectx'
alias cns='kubens'

# Work
alias laptop='ssh jadia@192.168.1.200'

# Long Tasks
alias scisHomePush='mkdocs build && gaa && gcmsg "update" && git push && rsync -avzhP site/*  18mcmt13@10.5.0.90:/users/mtech/18mcmt13/public_html/'
alias vpn='sudo openvpn ~/VPN/nitish.ovpn'
#alias nmtui='nmcli dev wifi rescan && nmtui'
