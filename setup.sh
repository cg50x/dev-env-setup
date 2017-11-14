#!/bin/bash

#set -e

SUDO=$(which sudo 2> /dev/null)
YUM=$(which yum 2> /dev/null)
APTGET=$(which apt-get 2> /dev/null)

if [ "$(which git 2> /dev/null)" == "" ]; then
	echo "Installing git..."
	[ "${YUM}" != "" ] && $SUDO yum install -y -q git
	[ "${APTGET}" != "" ] && $SUDO apt-get install -y -q git
fi
if [ "$(which git 2> /dev/null)" == "" ]; then
	echo "Could not find git!"
	exit 1
fi

echo "Downloading setup scripts..."
git clone https://bitbucket.org/codisms/dev-setup.git ~/.setup
chown -R `whoami`:`whoami` .setup

INSTALL_DIR=
case "$OSTYPE" in
	solaris*) INSTALL_DIR=solaris ;;
	linux*)
		[ -n "$(command -v apt-get)" ] && INSTALL_DIR=linux.apt
		[ -n "$(command -v yum)" ] && INSTALL_DIR=linux.yum
		if [ "${INSTALL_DIR}" == "" ]; then
			echo "Unable to find yum or apt-get!"
		fi
		;;
	darwin*) INSTALL_DIR=darwin ;;
	bsd*) INSTALL_DIR=bsd ;;
esac
if [ "${INSTALL_DIR}" == "" ]; then
	echo "Unknown operating system: $OSTYPE"
	exit
fi
if [ ! -f ~/.setup/${INSTALL_DIR}/step1.sh ]; then
	echo "Setup script not found: ${INSTALL_DIR}"
	exit
fi

cat <<EOF >> ~/.bashrc

if [ -f ~/.onstart ]; then
	CMD=\`cat ~/.onstart\`
	SUDO=\$(which sudo 2> /dev/null)
	rm -f ~/.onstart
	echo "Executing command: \$SUDO \$CMD \$HOME `whoami`"
	if [ "\$SUDO" == "" ]; then
		read -p 'Press [Enter] key to continue...'
	fi
	\$SUDO \$CMD \$HOME `whoami`
	CMD=
	SUDO=
fi

EOF

echo "Running installer (~/.setup/${INSTALL_DIR}/step1.sh)..."
#find ~/.setup -name \*.sh -exec chmod +x {} \;
$SUDO ~/.setup/${INSTALL_DIR}/step1.sh $HOME `whoami` $1

