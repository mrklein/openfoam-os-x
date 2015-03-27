# OpenFOAM on OS X

Patches for OpenFOAM compilation on OS X. Detailed installation instructions
can be found in [wiki](https://github.com/mrklein/openfoam-os-x/wiki).

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
