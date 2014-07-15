#!/bin/sh

VERSION=$1;

# Installing dependencies
brew update
brew tap homebrew/science
brew install open-mpi --disable-fortran
brew install cmake
brew install boost --without-single --with-mpi
brew cgal gmp mpfr scotch

# Preparing disk image
hdiutil create -size 4.4g -type SPARSEBUNDLE -fs HFSX -volname OpenFOAM \
    -fsargs -s $HOME/OpenFOAM.sparsebundle
mkdir -p $HOME/OpenFOAM
hdiutil attach -mountpoint $HOME/OpenFOAM $HOME/OpenFOAM.sparsebundle

# Getting sources
cd $HOME/OpenFOAM
echo "Building: OpenFOAM $VERSION"
if [ "$VERSION" == "2.1.1" ]; then
    curl -L http://downloads.sourceforge.net/foam/OpenFOAM-2.1.1.tgz > \
        OpenFOAM-2.1.1.tgz
    tar xzf OpenFOAM-2.1.1.tgz
fi

if [ "$VERSION" == "2.1.x" ]; then
    git clone git://github.com/OpenFOAM/OpenFOAM-2.1.x.git
fi

if [ "$VERSION" == "2.2.2" ]; then
    curl -L http://downloads.sourceforge.net/foam/OpenFOAM-2.2.2.tgz > \
        OpenFOAM-2.2.2.tgz
    tar xzf OpenFOAM-2.1.1.tgz
fi

if [ "$VERSION" == "2.2.x" ]; then
    git clone git://github.com/OpenFOAM/OpenFOAM-2.2.x.git
fi

if [ "$VERSION" == "2.3.0" ]; then
    curl -L http://downloads.sourceforge.net/foam/OpenFOAM-2.3.0.tgz > \
        OpenFOAM-2.3.0.tgz
    tar xzf OpenFOAM-2.1.1.tgz
fi

if [ "$VERSION" == "2.3.x" ]; then
    git clone git://github.com/OpenFOAM/OpenFOAM-2.3.x.git
fi

cd "$HOME/OpenFOAM/OpenFOAM-$VERSION"
cp "$TRAVIS_BUILD_DIR/OpenFOAM-$VERSION.patch" .
git apply OpenFOAM-$VERSION.patch
