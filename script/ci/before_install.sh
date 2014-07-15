#!/bin/sh

VERSION=$1;

brew install boost --without-single --with-mpi > /dev/null 2>&1
brew cgal gmp mpfr open-mpi scotch > /dev/null 2>&1
