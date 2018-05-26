#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

setHostName() {
	printHeader "Setting host name..." "hostname"

	echo SUDO=$SUDO
	echo Setting host name to "$1"...

	$SUDO sh -c "echo nameserver 8.8.8.8 >>/etc/resolv.conf; \
		echo nameserver 8.8.4.4 >>/etc/resolv.conf; \
		echo 127.0.0.1 $1>> /etc/hosts"

	$SUDO hostnamectl set-hostname $1
}

#-----------------------------------------------------------------------------------------------------------
# Updates

installAptFast() {
	printHeader "Installing apt-fast..." "apt-fast"

	apt_add_repository ppa:apt-fast/stable
	apt_get_update
	apt_get_install apt-fast
	#mkdir -p ${MY_HOME}/.config/aria2/
	#echo "log-level=warn" >> ~/.config/aria2/input.conf

	reloadEnvironment
}

updateSystem() {
	printHeader "Updating system..." "system"

	apt_get_update

	reloadEnvironment
}

#updateFileSystem() {
#	if grep -q "^/dev/vdb1 /data" "/etc/mtab"; then
#		[ ! -f /etc/fstab.orig ] && cp /etc/fstab /etc/fstab.orig
#		cp -R /root/* /data/ || true
#		cp .* /data/ || true
#		cp -R /root/.ssh /data/ || true
#		cp -R /root/.setup /data/ || true
#		sed 's|/data|/root|' /etc/fstab.orig > /etc/fstab
#	fi
#}

updateSudoers() {
	printHeader "Updating /etc/sudoers..." "sudoers"

	echo Looking for user $MY_USER in /etc/sudoers...
	if ! $SUDO grep -q $MY_USER /etc/sudoers; then
		echo "  Adding user to /etc/sudoers..."
		echo "$MY_USER ALL=(ALL:ALL) NOPASSWD: ALL" | $SUDO EDITOR='tee -a' visudo > /dev/null
	else
		echo "  User already exists"
		grep $MY_USER /etc/sudoers
	fi
	#cat /etc/sudoers
}

############################################################################################################
# BEGIN
############################################################################################################

if [ "$1" != "" ]; then
	setHostName $1
fi

installAptFast
updateSystem

if [ -f /etc/sudoers ]; then
	updateSudoers
fi

scheduleForNextRun "${MY_HOME}/.setup/linux.apt/step2.sh"

# This is a Joyent thing; not sure if it's needed
#printHeader "Updating file system..."
#updateFileSystem

printHeader "Finished step 1.  \e[5mRebooting\e[25m..." "reboot"
# read -p 'Press [Enter] to continue...'
$SUDO reboot
