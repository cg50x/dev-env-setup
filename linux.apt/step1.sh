#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

setHostName() {
	echo SUDO=$SUDO
	echo Setting host name to "$1"...

	echo nameserver 8.8.8.8 >>/etc/resolv.conf
	echo nameserver 8.8.4.4 >>/etc/resolv.conf

	hostnamectl set-hostname $1
}

#-----------------------------------------------------------------------------------------------------------
# Updates

updateSystem() {
	echo Updating system...
	$SUDO apt-get -y update
	$SUDO apt-get -y upgrade
}

#updateFileSystem() {
#	if grep -q "^/dev/vdb1 /data" "/etc/mtab"; then
#		[ ! -f /etc/fstab.orig ] && $SUDO cp /etc/fstab /etc/fstab.orig
#		$SUDO cp -R /root/* /data/ || true
#		$SUDO cp .* /data/ || true
#		$SUDO cp -R /root/.ssh /data/ || true
#		$SUDO cp -R /root/.setup /data/ || true
#		$SUDO sed 's|/data|/root|' /etc/fstab.orig > /etc/fstab
#	fi
#}

############################################################################################################
# BEGIN
############################################################################################################

if [ "$1" != "" ]; then
	printHeader "Setting host name..."
	setHostName $1
fi

printHeader "Updating system..."
updateSystem

scheduleForNextRun "${MY_HOME}/.setup/linux/step2.sh"

# This is a Joyent thing; not sure if it's needed
#printHeader "Updating file system..."
#updateFileSystem

printHeader "Finished step 1.  Rebooting..."
# read -p 'Press [Enter] to continue...'
reboot