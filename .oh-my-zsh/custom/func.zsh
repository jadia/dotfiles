startvm() { if  virsh start $1; then; sleep 8s; fi; ssh th3nyx@$1; }

penmount() { sudo mount -o rw,user,exec,umask=000 /dev/$1 /mnt/tmp; }

hddoff() { sudo udisksctl power-off -b /dev/$1; }

localServer() { if [[ $1 == 'start' ]]; then; docker run --rm --name local-nginx -v ~/Documents/localShare:/usr/share/nginx/html:ro -v ~/Documents/localShare/default.conf:/etc/nginx/conf.d/default.conf -p 80:80 -d nginx; fi; if [[ $1 == 'stop' ]]; then; docker stop local-nginx; fi; }
#alias config='/usr/bin/git --git-dir=/home/nitish/.cfg/ --work-tree=/home/nitish'

docker-restore() { unset DOCKER_TLS_VERIFY; unset DOCKER_HOST; unset DOCKER_CERT_PATH; unset DOCKER_MACHINE_NAME; }

#zprof
## Stole from arush-sal
 if [ "$TMUX" = "" ]; then
 	 if [[ -n $(pgrep tmux) ]]; then	
 		 if tmux ls|grep -q -e "0: ."; then tmux attach-session -t 0; else tmux new-session -s 0; fi
     else 
		 tmux new-session -s 0
	 fi
 fi


# function Extract for common file formats
# Source: https://github.com/xvoland/Extract/blob/master/extract.sh

function extract {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    return 1
 else
    for n in $@
    do
      if [ -f "$n" ] ; then
          case "${n%,}" in
            *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar) 
                         tar xvf "$n"       ;;
            *.lzma)      unlzma ./"$n"      ;;
            *.bz2)       bunzip2 ./"$n"     ;;
            *.rar)       unrar x -ad ./"$n" ;;
            *.gz)        gunzip ./"$n"      ;;
            *.zip)       unzip ./"$n"       ;;
            *.z)         uncompress ./"$n"  ;;
            *.7z|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar)
                         7z x ./"$n"        ;;
            *.xz)        unxz ./"$n"        ;;
            *.exe)       cabextract ./"$n"  ;;
            *)
                         echo "extract: '$n' - unknown archive method"
                         return 1
                         ;;
          esac
      else
          echo "'$n' - file does not exist"
          return 1
      fi
    done
fi
}
