#!/bin/sh

VERSION=$1;

brew tap homebrew/science
brew install open-mpi --disable-fortran
brew install boost --without-single --with-mpi
brew cmake cgal gmp mpfr scotch
