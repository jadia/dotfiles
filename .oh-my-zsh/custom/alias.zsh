# Dockerfiles

# Docker

alias exiftool='docker run --rm -v $(pwd):/tmp jadia/exiftool'
alias docker_clear='docker rm $(docker ps -aq)'
alias vnstati='docker run --rm --name vnstat-dashboard -p 8008:80 -v /usr/bin/vnstat:/usr/bin/vnstat -v /var/lib/vnstat:/var/lib/vnstat -d amarston/vnstat-dashboard:latest && echo "Check port 8008" && echo "Run this to stop server: docker stop vnstat-dashboard"'
alias hugo='docker run --rm -it -v $PWD:/src -u hugo jadia/hugo-builder hugo'
alias hugo-server='docker run --rm -it -v $PWD:/src -p 1313:1313 -u hugo jadia/hugo-builder hugo server --bind 0.0.0.0 -D'
alias jekyll='docker run --rm -ti -v $(pwd):/work -p 4000:4000 jadia/bundler bundle exec jekyll'
alias jekyll-server='docker run --rm -ti -v $(pwd):/work -p 4000:4000 jadia/bundler bundle exec jekyll serve --host 0.0.0.0'


# General 

alias dow='cd ~/Downloads'
alias doc='cd ~/Documents'
alias tmux='tmux -u'
alias todo='vim /home/nitish/todo'
alias work='vim /home/nitish/work.md'
alias cal='cal -3'
alias gping='ping -c 3 google.com'
#alias asdf='/home/nitish/cron/authenticate.sh' # login to UoH network
#alias untar='tar -xvf'
#alias listvm='sudo virsh list --all' # List all KVM machines
alias rsync='rsync -avzhP'
alias downit='aria2c -x16' # download with 16 parallel connections
#alias til='cd /home/nitish/til' # Delete later
alias ndone='ntfy done'
alias sl='sl -ela' # Train
alias ram="free -h | awk ' NR==2 {print \$3}'" # how much ram is being used
alias speedtest="speedtest --server-id=3663 -u MB/s"
alias mknitish="sudo chown -R nitish:nitish"
alias img="feh -FZrD3"
alias path="echo $PATH | tr -s ':' '\n'" # Pretty print the path
alias vpn='sudo openvpn ~/cron/vpn/nitish.ovpn'
alias rescan='nmcli dev wifi rescan'
alias copyshow='clipcopy; clippaste | bat' # Copy content to clipboard + print using bat
alias mkexec='sudo chmod +x'
alias vpython='source /home/nitish/virtualenv/venv/bin/activate'

# Git
alias gcx='git commit -m "$(curl -s whatthecommit.com/index.txt)"'

#Vagrant
alias up="vagrant up"
alias down="vagrant halt"
alias des="vagrant destroy -f"
alias vssh="vagrant ssh"
alias re="vagrant reload"

# Kubernetes
alias kd='kubectl describe'
alias kg='kubectl get'
alias ctx='kubectx'
alias cns='kubens'
alias minikube-update=' sudo curl -Lo /tmp/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
						&& sudo mv /tmp/minikube /usr/local/bin/minikube \
						&& sudo chmod +x /usr/local/bin/minikube'
#alias k9s='docker run --rm -it -v ~/.kube/config:/root/.kube/config -v ~/.minikube/:/home/nitish/.minikube quay.io/derailed/k9s'

# Work
#alias laptop='ssh jadia@192.168.1.200'

# Long Tasks
#alias scisHomePush='mkdocs build && gaa && gcmsg "update" && git push && rsync -avzhP site/*  18mcmt13@10.5.0.90:/users/mtech/18mcmt13/public_html/'
#alias nmtui='nmcli dev wifi rescan && nmtui'
