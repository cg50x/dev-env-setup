#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

#-----------------------------------------------------------------------------------------------------------
# Download code

downloadCode() {
	cd ${MY_HOME}/go
	GOPATH=`pwd` /usr/local/go/bin/go get golang.org/x/tools/cmd/goimports
	cd ${MY_HOME}

	echo Cloning db...
	retry git clone https://bitbucket.org/codisms/db.git ${MY_HOME}/db
	${MY_HOME}/.codisms/get-code.sh
}

finalConfigurations() {
	echo "Setting motd..."
	[ -f /etc/motd ] && $SUDO mv /etc/motd /etc/motd.orig
	$SUDO ln -s ${MY_HOME}/.codisms/motd /etc/motd

	echo "Setting zsh as default shell..."
	[ -f /etc/ptmp ] && $SUDO rm -f /etc/ptmp
	$SUDO chsh -s `which zsh` ${MY_USER}

	echo "Setting crontab jobs..."
	set +e
	(crontab -u ${MY_USER} -l 2>/dev/null; \
		echo "0 5 * * * ${MY_HOME}/.codisms/bin/crontab-daily"; \
		echo "5 5 * * 1 ${MY_HOME}/.codisms/bin/crontab-weekly"; \
		echo "15 5 1 * * ${MY_HOME}/.codisms/bin/crontab-monthly") | crontab -u ${MY_USER} -
	set -e
}

############################################################################################################
# BEGIN
############################################################################################################

#printHeader "Downloading code..."
#downloadCode
#rsync -avzhe ssh --progress dev.codisms.com:/root/ /root/

printHeader "Making final configuration changes..."
finalConfigurations

printHeader "Resetting home directory owner..."
resetPermissions

printHeader "Done.  Rebooting for the final time..."
# read -p 'Press [Enter] to continue...'

$SUDO reboot
