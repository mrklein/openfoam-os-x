# OpenFOAM on OS X

Patches for OpenFOAM compilation on OS X. Detailed installation instructions
can be found in [wiki](https://github.com/mrklein/openfoam-os-x/wiki).

## May 5, 2015

1. As versions 2.1.x and 2.2.x have rather funny memory allocation bug, I have
   only one laptop, and I do not use those versions, further support of patches
   for these versions is dropped.
2. Patches for 2.3.1 and 2.3.x (commit
   openfoam/openfoam-2.3.x@00eea576852a0b95b772665dc4414b9bc32ce17f) include:
       - new printStack implementation (so there is no need in Python script for
     address resolution)
       - update of the code for new version of CGAL
       - corrections in METIS decomposition build logic
       - corrections in fvAgglomerationMethods build logic, so it can use
	 Homebrew-installed ParMGridGen
       - corrections in sigFpe.C, so there is no more infinite loop in parallel
	 run (due to print stack functionality in OpenMPI)
3. Initial foam-extend (commit ec44c952c9f8841ea5fba2bdb9235a5914c6c1c5) patch
   attempt. Installation guide is in [wiki](https://github.com/mrklein/openfoam-os-x/wiki/foam-extend---Homebrew).
4. Homebrew formulae for Mosquite and ParMGridGen.

Build was tested on

```sh
alexey at daphne in ~$ sw_vers 
ProductName:	Mac OS X
ProductVersion:	10.10.3
BuildVersion:	14D136
```

With the following versions of third party packages

```sh
alexey at daphne in ~$ brew ls --versions
bison27 2.7.1
boost 1.57.0
cgal 4.6
gmp 6.0.0a
hwloc 1.9
libmpc 1.0.3
mesquite 2.1.2
metis 5.1.0
mpfr 3.1.2-p11
open-mpi 1.8.4
parmetis 4.0.3
parmgridgen 0.0.1
scotch 6.0.3
```

## Mar. 26, 2015

1. Updated OpenFOAM 2.3.1 patch for new version of Scotch.
2. Added patch to fix Scotch linking. Though patch was tested on 2.3.1, guess
   it will work on 2.3.0 and 2.2.x versions.

## Dec. 13, 2014

Added patch for OpenFOAM 2.3.1. Build was tested on:

```
myself at daphne in openfoam-os-x$ sw_vers
ProductName:	Mac OS X
ProductVersion:	10.10.1
BuildVersion:	14B25

myself at daphne in openfoam-os-x$ clang --version
Apple LLVM version 6.0 (clang-600.0.56) (based on LLVM 3.5svn)
Target: x86_64-apple-darwin14.0.0
Thread model: posix
```
