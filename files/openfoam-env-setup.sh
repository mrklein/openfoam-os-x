#!/bin/bash

# If you'd like to setup environment every time terminal is launched
# create .OpenFOAM/OpenFOAM-release file in your home folder. In the file put
# the string with a version you'd like to use. This can be done with:
# $ mkdir -p .OpenFOAM
# $ cat '2.X.Y' > .OpenFOAM/OpenFOAM-release
# If you'd like to switch environment between versions use of2xy commands.

FOAM_MOUNT_POINT=${FOAM_MOUNT_POINT:-"$HOME/OpenFOAM"}
FOAM_RELEASE_FILE=${FOAM_RELESE_FILE:-"$HOME/.OpenFOAM/OpenFOAM-release"}
FOAM_DISK_IMAGE=${FOAM_DISK_IMAGE:-"$HOME/OpenFOAM.sparsebundle"}

FE_MOUNT_POINT=${FE_MOUNT_POINT:-"$HOME/foam"}
FE_RELEASE_FILE=${FE_RELESE_FILE:-"$HOME/.foam/foam-release"}
FE_DISK_IMAGE=${FE_DISK_IMAGE:-"$HOME/foam-extend.sparsebundle"}

mount_disk_image () {
	local oldpwd=$(pwd)
	cd $HOME
	# Attempt to mount image
	hdiutil attach -quiet -mountpoint "$FOAM_MOUNT_POINT" "$FOAM_DISK_IMAGE"
	cd $oldpwd
	return 0
}

fe_mount_disk_image () {
	local oldpwd=$(pwd)
	cd $HOME
	hdiutil attach -quiet -mountpoint "$FE_MOUNT_POINT" "$FE_DISK_IMAGE"
	cd $oldpwd
	return 0
}

main () {
	if [ ! -f $FOAM_RELEASE_FILE ]; then
		# No default release information, just exporting setup functions
		return 1
	fi

	local release="$(cat $FOAM_RELEASE_FILE)"
	local bashrc="$FOAM_MOUNT_POINT/OpenFOAM-$release/etc/bashrc"

	[ ! -f "$bashrc" ] && mount_disk_image
	if [ -f "$bashrc" ]; then
		source $bashrc WM_NCOMPPROCS="$(sysctl -n hw.ncpu)"
	else
		echo "OpenFOAM $release doesn't seem to be installed."
	fi
}

# Reset environment variables for specified version
ofxxx () {
	local release="$1"
	[ -n "$WM_PROJECT_DIR" ] && . "$WM_PROJECT_DIR/etc/config/unset.sh"
	local bashrc="$FOAM_MOUNT_POINT/OpenFOAM-$release/etc/bashrc"
	if [ -f "$bashrc" ]; then
		source $bashrc WM_NCOMPPROCS=$(sysctl -n hw.ncpu)
	else
		mount_disk_image
		if [ -f "$bashrc" ]; then
			source $bashrc WM_NCOMPPROCS=$(sysctl -n hw.ncpu)
		else
			echo "OpenFOAM $release doesn't seem to be installed."
		fi
	fi
}

# foam-extend functions
fexxx () {
	local release=$1
	[ -n "$WM_PROJECT_DIR" ] && . $WM_PROJECT_DIR/etc/config/unset.sh
	local bashrc="$FE_MOUNT_POINT/foam-extend-$release/etc/bashrc"
	if [ -f "$bashrc" ]; then
		source $bashrc
	else
		fe_mount_disk_image
		if [ -f "$bashrc" ]; then
			source $bashrc
		else
			echo "foam-extend $release doesn't seem to be installed."
		fi
	fi
}

of231 () {
	ofxxx '2.3.1'
}

export -f of231

of23x () {
	ofxxx '2.3.x'
}

export -f of23x

of240 () {
	ofxxx '2.4.0'
}

export -f of240

of24x () {
	ofxxx '2.4.x'
}

export -f of24x

of22x () {
	ofxxx '2.2.x'
}

export -f of22x

of21x () {
	ofxxx '2.1.x'
}

export -f of21x

ofdev() {
	ofxxx 'dev'
}

export -f ofdev

pf () {
	paraFoam > /dev/null 2>&1 &
}

main
