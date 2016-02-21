#!/bin/sh

readonly VERSION=$1;

create_prefs()
{
    mkdir -p "$HOME/.OpenFOAM"
    echo 'WM_COMPILER=Clang' > "$HOME/.OpenFOAM/prefs.sh"
    echo 'WM_COMPILE_OPTION=Opt' >> "$HOME/.OpenFOAM/prefs.sh"
    echo 'WM_MPLIB=SYSTEMOPENMPI' >> "$HOME/.OpenFOAM/prefs.sh"
    echo 'export WM_NCOMPPROCS=$(sysctl -n hw.ncpu)' >> "$HOME/.OpenFOAM/prefs.sh"
}

prepare_release()
{
    cd $HOME
    curl -L http://downloads.sourceforge.net/foam/OpenFOAM-$VERSION.tgz > OpenFOAM-$VERSION.tgz
    cd "$HOME/OpenFOAM"
    tar xzf "$HOME/OpenFOAM-$VERSION.tgz"
    cd "$HOME/OpenFOAM/OpenFOAM-$VERSION"
    curl -L https://raw.githubusercontent.com/mrklein/openfoam-os-x/master/OpenFOAM-$VERSION.patch > OpenFOAM.patch
    return 0
}

prepare_git_version()
{
    cd "$HOME/OpenFOAM"
    git clone git://github.com/OpenFOAM/OpenFOAM-$VERSION.git
    cd "$HOME/OpenFOAM/OpenFOAM-$VERSION"
    local initial_commit=
    [ "$VERSION" = "2.4.x" ] && initial_commit="2b147f4"
    [ "$VERSION" = "3.0.x" ] && initial_commit="f5fbd39"
    [ "$VERSION" = "dev" ] && initial_commit="665b1f8"
    curl -L https://raw.githubusercontent.com/mrklein/openfoam-os-x/master/OpenFOAM-$VERSION-$initial_commit.patch > OpenFOAM.patch
    git chekout -b local-install $initial_commit
    git apply OpenFOAM.patch
    create_prefs
    return 0
}

if [ "${VERSION: -1}" = "x" -o "$VERSION" = "dev" ]
then
    prepare_git_version $VERSION
else
    prepare_release $VERSION
fi

git apply OpenFOAM.patch
create_prefs

source etc/bashrc
./Allwmake
