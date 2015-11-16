#!/bin/sh

# If you'd like to setup environment every time terminal is launched
# create .OpenFOAM/OpenFOAM-release file in your home folder. In the file put
# the string with a version you'd like to use. This can be done with:
# $ mkdir -p .OpenFOAM
# $ cat '2.X.Y' > .OpenFOAM/OpenFOAM-release
# If you'd like to switch environment between versions use of2xy commands.

readonly FOAM_MOUNT_POINT=${FOAM_MOUNT_POINT:-"$HOME/OpenFOAM"}
readonly FOAM_RELEASE_FILE=${FOAM_RELESE_FILE:-"$HOME/.OpenFOAM/OpenFOAM-release"}
readonly FOAM_DISK_IMAGE=${FOAM_DISK_IMAGE:-"$HOME/OpenFOAM.sparsebundle"}

mount_disk_image () {
	local oldpwd=$(pwd)
	cd $HOME
	# Attempt to mount image
	hdiutil attach -quiet -mountpoint "$FOAM_MOUNT_POINT" "$FOAM_DISK_IMAGE"
	cd $oldpwd
	return 0
}

main () {
	[ -f $FOAM_RELEASE_FILE ] || return 1

	local release="$(cat "$FOAM_RELEASE_FILE")"
	local bashrc="$FOAM_MOUNT_POINT/OpenFOAM-$release/etc/bashrc"

	[ -f "$bashrc" ] || mount_disk_image

	if [ -f "$bashrc" ]
    then
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

of22x () {
	ofxxx '2.2.x'
}

export -f of22x

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

of300() {
	ofxxx '3.0.0'
}

export -f of300

of30x() {
	ofxxx '3.0.x'
}

export -f of30x

pf () {
	paraFoam > /dev/null 2>&1 &
}

main
