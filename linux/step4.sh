#!/bin/bash

set -e
cd ~

. ~/.setup/linux/functions

#-----------------------------------------------------------------------------------------------------------
# Download code

downloadCode() {
	cd ~/go
	GOPATH=`pwd` /usr/local/go/bin/go get golang.org/x/tools/cmd/goimports
	cd ~

	echo Cloning db... && git clone --quiet https://bitbucket.org/codisms/db.git ~/db
	~/.codisms/get-code.sh
}

finalConfigurations() {
	[ -f /etc/motd ] && mv /etc/motd /etc/motd.orig
	ln -s ~/.codisms/motd /etc/motd

	[ -f /etc/ptmp ] && rm -f /etc/ptmp
	chsh -s `which zsh`
}

############################################################################################################
# BEGIN
############################################################################################################

#printHeader "Downloading code..."
#downloadCode
rsync -avzhe ssh --progress dev.codisms.com:/root/ /root/

printHeader "Making final configuration changes..."
finalConfigurations

printHeader "Done.  Rebooting for the final time..."
# read -p 'Press [Enter] to continue...'

reboot
