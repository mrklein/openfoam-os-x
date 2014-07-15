#!/bin/sh

VERSION=$1;

brew tap homebrew/science
brew install boost --without-single --with-mpi
brew cgal gmp mpfr open-mpi scotch > /dev/null 2>&1
