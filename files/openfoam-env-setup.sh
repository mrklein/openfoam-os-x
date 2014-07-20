#!/bin/bash

MOUNT_POINT="$HOME/OpenFOAM"
RELEASE_FILE="$HOME/.OpenFOAM/OpenFOAM-release"
DISK_IMAGE="$HOME/OpenFOAM.sparsebundle"

mount_disk_image () {
    cd $HOME
    # Attempt to mount image
    hdiutil attach -quiet -mountpoint $MOUNT_POINT $DISK_IMAGE
    cd $OLD_PWD
    return 0
}

main () {
    if [ ! -f $RELEASE_FILE ]; then
        # No default release information, just exporting setup functions
        return 1
    fi
    local release=$(cat $RELEASE_FILE)
    local bashrc="$MOUNT_POINT/OpenFOAM-$release/etc/bashrc"
    if [ ! -f "$bashrc" ]; then
        mount_disk_image
    fi
    if [ -f "$bashrc" ]; then
        source $bashrc
    else
        echo "OpenFOAM $release doesn't seem to be installed."
    fi
}

# Reset environment variables for specified version
ofxxx () {
    local release=$1
    [ -n "$WM_PROJECT_DIR" ] && . $WM_PROJECT_DIR/etc/config/unset.sh
    local bashrc="$MOUNT_POINT/OpenFOAM-$release/etc/bashrc"
    if [ -f "$bashrc" ]; then
        source $bashrc
    else
        mount_disk_image
        if [ -f "$bashrc" ]; then
            source $bashrc
        else
            echo "OpenFOAM $release doesn't seem to be installed."
        fi
    fi
}

# Concrete version exported functions
of211 () {
    ofxxx '2.1.1'
}

export -f of211

of21x () {
    ofxxx '2.1.x'
}

export -f of21x

of222 () {
    ofxxx '2.2.2'
}

export -f of222

of22x () {
    ofxxx '2.2.x'
}

export -f of22x

of230 () {
    ofxxx '2.3.0'
}

export -f of230

of23x () {
    ofxxx '2.3.x'
}

export -f of23x

main
