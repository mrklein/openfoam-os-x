#!/bin/sh

# If you'd like to setup environment every time terminal is launched
# create .OpenFOAM/OpenFOAM-release file in your home folder. In the file put
# the string with a version you'd like to use. This can be done with:
# $ mkdir -p .OpenFOAM
# $ cat 'N.X.Y' > .OpenFOAM/OpenFOAM-release
# If you'd like to switch environment between versions use ofNxy commands.
#
# Currently N could be 2, 3, or 4.

readonly FOAM_MOUNT_POINT="${FOAM_MOUNT_POINT:-"$HOME/OpenFOAM"}"
readonly FOAM_RELEASE_FILE="${FOAM_RELEASE_FILE:-"$HOME/.OpenFOAM/OpenFOAM-release"}"
readonly FOAM_DISK_IMAGE="${FOAM_DISK_IMAGE:-"$HOME/OpenFOAM.sparsebundle"}"

mount_disk_image () {
	local oldpwd="$(pwd)"
	cd "$HOME"
	# Attempt to mount image
	hdiutil attach -quiet -mountpoint "$FOAM_MOUNT_POINT" "$FOAM_DISK_IMAGE"
	cd "$oldpwd"
	return 0
}

main () {
	[ -f "$FOAM_RELEASE_FILE" ] || return 1

	local release="$(cat "$FOAM_RELEASE_FILE")"
	local bashrc="$FOAM_MOUNT_POINT/OpenFOAM-$release/etc/bashrc"

	[ -f "$bashrc" ] || mount_disk_image

	if [ -f "$bashrc" ]
    then
		source "$bashrc" WM_NCOMPPROCS="$(sysctl -n hw.ncpu)"
	else
		echo "OpenFOAM $release doesn't seem to be installed."
	fi
}

# Reset environment variables for specified version
ofxxx () {
	local release="$1"
	[ -n "$WM_PROJECT_DIR" ] && {
        [ -r "$WM_PROJECT_DIR/etc/config/unset.sh" ] \
            && . "$WM_PROJECT_DIR/etc/config/unset.sh"
    }
	local bashrc="$FOAM_MOUNT_POINT/OpenFOAM-$release/etc/bashrc"
	if [ -f "$bashrc" ]; then
		source "$bashrc" WM_NCOMPPROCS="$(sysctl -n hw.ncpu)"
	else
		mount_disk_image
		if [ -f "$bashrc" ]; then
			source "$bashrc" WM_NCOMPPROCS="$(sysctl -n hw.ncpu)"
		else
			echo "OpenFOAM $release doesn't seem to be installed."
		fi
	fi
}

export -f ofxxx

of22x () {
	ofxxx "2.2.x"
}

export -f of22x

of231 () {
	ofxxx "2.3.1"
}

export -f of231

of23x () {
	ofxxx "2.3.x"
}

export -f of23x

of240 () {
	ofxxx "2.4.0"
}

export -f of240

of24x () {
	ofxxx "2.4.x"
}

export -f of24x

of300() {
	ofxxx "3.0.0"
}

export -f of300

of301() {
	ofxxx "3.0.1"
}

export -f of301

of30x() {
	ofxxx "3.0.x"
}

export -f of30x

of40() {
    ofxxx "4.0"
}

export -f of40

of41() {
    ofxxx "4.1"
}

export -f of41


of4x() {
    ofxxx "4.x"
}

export -f of4x

of50() {
    ofxxx "5.0"
}

export -f of50

of5x() {
    ofxxx "5.x"
}

export -f of5x

ofdev() {
    ofxxx "dev"
}

export -f ofdev

pf () {
	paraFoam -builtin > /dev/null 2>&1 &
}

main
