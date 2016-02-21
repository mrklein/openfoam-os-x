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
    cp $TRAVIS_BUILD_DIR/OpenFOAM-$VERSION.patch OpenFOAM.patch
    return 0
}

prepare_git_version()
{
    cd "$HOME/OpenFOAM"
    git clone git://github.com/OpenFOAM/OpenFOAM-$VERSION.git
    cd "$HOME/OpenFOAM/OpenFOAM-$VERSION"
    local patch_file=$(ls -1 $TRAVIS_BUILD_DIR | grep $VERSION)
    local initial_commit=$(echo $patch_file | sed 's/OpenFOAM-.*-\([[:alnum:]]+\)\.patch/\1/')
    cp $TRAVIS_BUILD_DIR/$patch_file OpenFOAM.patch
    git checkout -b local-install $initial_commit
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
