#!/bin/sh

VERSION=$1;

cd "$HOME/OpenFOAM/OpenFOAM-$VERSION"
source etc/bashrc
./Allwmake > log.Allwmake 2>&1
