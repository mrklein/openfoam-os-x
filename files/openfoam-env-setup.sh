#!/bin/sh

# If you'd like to setup environment every time terminal is launched
# create .OpenFOAM/OpenFOAM-release file in your home folder. In the file put
# the string with a version you'd like to use. This can be done with:
# $ mkdir -p .OpenFOAM
# $ cat 'N.X.Y' > .OpenFOAM/OpenFOAM-release
# If you'd like to switch environment between versions use ofNxy commands.
#
# Currently N is 2, 3, 4, 5, 6, or 7.

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

of5x() {
    ofxxx "5.x"
}
export -f of5x

of6() {
    ofxxx "6"
}
export -f of6

of7() {
    ofxxx "7"
}
export -f of7

ofdev() {
    ofxxx "dev"
}

export -f ofdev

pf () {
    paraFoam -builtin > /dev/null 2>&1 &
}

main

# vi: set ft=sh et sw=4 ts=4 sts=4:
