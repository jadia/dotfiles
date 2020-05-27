export PATH=$HOME/bin:/usr/local/bin:/sbin:/usr/sbin:$PATH
# Add golang to path
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$(go env GOPATH)/bin
# Add snap path
export PATH=$PATH:/snap/bin