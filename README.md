# OpenFOAM on OS X

Patches for OpenFOAM compilation on OS X. Detailed installation instructions
can be found in [wiki](https://github.com/mrklein/openfoam-os-x/wiki).

## December 15, 2015

Major update.

1. Changed wmake rules for Darwin. Hopefully this solves problems with missing
   symbols ([1](http://www.cfd-online.com/Forums/openfoam-installation-windows-mac/130113-compile-2-3-mac-os-x-patch-7.html#post576975), [2](http://www.cfd-online.com/Forums/openfoam-installation-windows-mac/130113-compile-2-3-mac-os-x-patch-6.html#post572934)). Though, since I never had this problem on my laptop it is a question of external testing.

2. Fixed bugs and typos in RunFunctions, also added overwrite flag from
   dev-repository (now run(Application|Parallel) functions has -f, -force, --force,
   -overwrite flags to run application overwriting log-file, and -a, -append,
   --append flags to run application and append to log-file).

3. Just for fun added emulation of "silent rules" in 3.0.x. To turn this
   feature on you need to set WM_SILENT_RULES to non-empty value (`export
   WM_SILENT_RULES=y` in `prefs.sh` will do the trick). And instead of

    ```
    daphne:icoFoam$ wmake
    $WM_PROJECT_DIR/applications/solvers/incompressible/icoFoam
    Making dependency list for source file icoFoam.C
    xcrun c++ -arch x86_64 -Ddarwin64 -DWM_ARCH_OPTION=64 -DWM_DP -DWM_LABEL_SIZE=64 -Wall -Wextra -Wno-unused-parameter -Wno-overloaded-virtual -Wno-unused-variable -Wno-unused-local-typedef -Wno-invalid-offsetof -Wno-c++11-extensions -O3  -DNoRepository -ftemplate-depth-100 -I$WM_PROJECT_DIR/src/finiteVolume/lnInclude -I$WM_PROJECT_DIR/src/meshTools/lnInclude -IlnInclude -I. -I$WM_PROJECT_DIR/src/OpenFOAM/lnInclude -I$WM_PROJECT_DIR/src/OSspecific/POSIX/lnInclude   -fPIC -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk -c icoFoam.C -o $WM_PROJECT_DIR/platforms/darwin64ClangDPInt64Opt/applications/solvers/incompressible/icoFoam/icoFoam.o
    xcrun c++ -arch x86_64 -Ddarwin64 -DWM_ARCH_OPTION=64 -DWM_DP -DWM_LABEL_SIZE=64 -Wall -Wextra -Wno-unused-parameter -Wno-overloaded-virtual -Wno-unused-variable -Wno-unused-local-typedef -Wno-invalid-offsetof -Wno-c++11-extensions -O3  -DNoRepository -ftemplate-depth-100 -I$WM_PROJECT_DIR/src/finiteVolume/lnInclude -I$WM_PROJECT_DIR/src/meshTools/lnInclude -IlnInclude -I. -I$WM_PROJECT_DIR/src/OpenFOAM/lnInclude -I$WM_PROJECT_DIR/src/OSspecific/POSIX/lnInclude   -fPIC -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk -Wl,-execute,-undefined,dynamic_lookup $WM_PROJECT_DIR/platforms/darwin64ClangDPInt64Opt/applications/solvers/incompressible/icoFoam/icoFoam.o -L$WM_PROJECT_DIR/platforms/darwin64ClangDPInt64Opt/lib \
		-lfiniteVolume -lmeshTools -lOpenFOAM -ldl  \
		 -lm -o $WM_PROJECT_DIR/platforms/darwin64ClangDPInt64Opt/bin/icoFoam   
   ```

   you will get

   ```
   daphne:icoFoam$ wmake
   $WM_PROJECT_DIR/applications/solvers/incompressible/icoFoam
      [CC] icoFoam.C
      [LD] icoFoam
   ```

## December 5, 2015

1. Updated patch for 3.0.x.
2. Since 3.0.x and dev branches started to diverge, returned dev patch to the
   repository.

## November 27, 2015

Added patch for [swak4Foam](https://sourceforge.net/p/openfoam-extend/swak4Foam/)
and [wiki page](https://github.com/mrklein/openfoam-os-x/wiki/swak4Foam) with
installation guide. Maybe one day it will be imported into Mercurial repository,
I do not have plans to open pull request on Sourceforge.

## November 22, 2015

Updated patches to include

1. Working getApplication function (resolves #14)
2. Extended functionality for runApplication and runParallel.
   - -f (or --force) flag to force log-file overwrite
   - -a (--append) to append to log-file instead of overwriting
3. RunFunctions now also automatically source $WM_PROJECT_DIR/etc/bashrc if run
   on El Capitan with enabled SIP (workaround for #15).

## November 9, 2015

Updated 3.0.0 and 3.0.x patches to include build logic for Scotch and METIS
with 64-bit index types. Libraries can be installed using files (`scotch64.rb`
and `metis64.rb`) from `formulae` folder. See [OpenFOAM 3.0.(0|x) & WM_LABEL_SIZE=64](https://github.com/mrklein/openfoam-os-x/wiki/OpenFOAM-3.0.(0%7Cx)-&-WM_LABEL_SIZE=64).

## November 8, 2015

1. Initial commit of 3.0.0 and 3.0.x patches (at this point they are identical).
   For 32 bit labels nothing changed in installation procedure. For 64 bit labels
   currently Scotch and METIS decomposition methods along with
   MGridGenGamgAgglomeration agglomeration method are disabled. They could be
   enabled in the future patches after testing 64 bit indexes in Scotch and
   METIS.

2. Update for 2.2.x, 2.3.1, 2.3.x, 2.4.0, and 2.4.x patches that includes fixes
   in printStack function.

3. Dropped 2.1.x patch (you can find it in earlier releases/commits) as I do
   have enough resources to support it. Temporarily removed -dev patch,
   currently it is equal to 3.0.x.

Build was tested on

```
alexey at daphne in openfoam-os-x$ sw_vers 
ProductName:	Mac OS X
ProductVersion:	10.11.1
BuildVersion:	15B42
```

with

```
alexey at daphne in openfoam-os-x$ clang++ --version
Apple LLVM version 7.0.0 (clang-700.1.76)
Target: x86_64-apple-darwin15.0.0
Thread model: posix
```

and these third party libraries

```
alexey at daphne in openfoam-os-x$ brew list --versions
boost 1.59.0
cgal 4.6.3
gmp 6.0.0a
metis 5.1.0
mpfr 3.1.3
open-mpi 1.10.0
parmetis 4.0.3_2
parmgridgen 0.0.1
scotch 6.0.4_1
```

## September 20, 2015

Being upset by sigSegv in renumberMesh (guess segmentation violations happen in
other places as well, yet I found it in renumberMesh), copied NullObject
concept from -dev repository. Now everything seems to be OK (at least
renumberMesh works).

Made additional cosmetic corrections (like SloanRenumber build script, so it
checks for library with dylib extension instead of so).

Build process was tested on

```
alexey at daphne in openfoam-os-x$ sw_vers
ProductName:	Mac OS X
ProductVersion:	10.10.5
BuildVersion:	14F27
```

with the following compiler:

```
alexey at daphne in openfoam-os-x$ clang --version
Apple LLVM version 7.0.0 (clang-700.0.72)
Target: x86_64-apple-darwin14.5.0
Thread model: posix
```

and these third party packages:

```
alexey at daphne in openfoam-os-x$ brew list --versions
boost 1.58.0
cgal 4.6.1
metis 5.1.0
open-mpi 1.8.4_1
parmetis 4.0.3
parmgridgen 0.0.1
```

## September 9, 2015

Updated patches for OpenFOAM 2.3.1 and 2.4.0.

## September 8, 2015

Updated patches for 2.3.x and 2.4.x (forgot certain things). Added patches for
2.2.x and 2.1.x (`reinterpret_cast<const void*>` solution for reference address seems to solve memory corruption
problem).

Test platform and third party software versions did not change since
September 5.

## September 5, 2015

Updated patches for 2.3.x (OpenFOAM-2.3.x-2f9138f.patch) and 2.4.x
(OpenFOAM-2.4.x-8685344.patch) versions. This time decided not to be too
invasive, so ended up with 50k patches (with stats). There were 3 general types
of modifications:

1. OS X specifics in OSspecific/POSIX folder. These are again has two types:
   additions of certain OS X headers (like sys/time.h in clockTime.H) and
   reimplementation of functionality (like chunks in printStack.C, POSIX.C, and
   sigFpe.?)
2. Clang's cpp does not fully support "traditional mode", so it does not
   understand continuations after comments. There were two variants: remove
   these comments or install traditional cpp. Chose the first variant.
3. Warnings. First type comes from OpenFOAM's desire to take address of the
   reference and the other one comes from third party software (updated CGAL).
   First problem could be solved by -Wno-... flag, yet I have chosen
   reinterpret_cast way. The second problem is solved by conditional
   compilation and pragmas.

Cause these patches were "fresh start", finally paid attention to and
implemented SetNaN functionality; simplified sigFpe code; implemented dlLoaded
function. Also printStack.C was a little bit revised to contract HOME and PWD
in library file names (in previous version HOME and PWD paths was replaced only
in resolved source files).

And since the corrections are mostly in the old files, hope creation of patches
for new versions will become much easier.

Build was tested on:

```
alexey at daphne in ~$ sw_vers
ProductName:	Mac OS X
ProductVersion:	10.10.5
BuildVersion:	14F27
```

with the following compiler

```
alexey at daphne in ~$ clang --version
Apple LLVM version 6.1.0 (clang-602.0.53) (based on LLVM 3.6.0svn)
Target: x86_64-apple-darwin14.5.0
Thread model: posix
```

and the following third party packages:

```
alexey at daphne in ~$ brew list --versions
boost 1.58.0
cgal 4.6.1
gmp 6.0.0a
libmpc 1.0.3
metis 5.1.0
mpfr 3.1.3
open-mpi 1.8.4_1
parmetis 4.0.3
parmgridgen 0.0.1
```

## July 31, 2015

Added patch for OpenFOAM-dev (commit 40310a5). Though this time patch is less
invasive, so maybe it will work with later commits.

The patch is a continuation of an attempt to build OpenFOAM with `-Wall -Wextra
-std=c++11` flags.

1. register storage class is removed in dev-branch, so the only places where it
   appears are sources generated by flex. Added pragmas to suppress warnings.
2. Still lots of unused parameter warnings. Commented them out (sometimes it is
   convenient to keep name of parameter since it a bit of documentation,
   sometimes parameters have names like `p`, yet for consistency I have decided
   to use comments everywhere). Patch was submitted upstream.
4. printStack functionality uses only lldb. So implementation became simplified compared to 2.(3|4).x version.
5. Boost and CGAL both have unused parameters and tautological comparison
   warnings, added pragmas around include lines to ignore them.
6. Scotch decomposition method is disabled when OpenFOAM is build with
   WM_LABEL_SIZE=64, since it requires recompilation of Scoth. Maybe later
   I will create special Homebrew formula for this version.
7. Clang on OS X does not want to do certain implicit conversions, so long.H
   and ulong.H headers were added to explicitly create Ostream methods for long
   and unsigned long types.
8. Miscellaneous bugs where revealed due to no implicit type coercion (like
   `if (mag(A > B))` instead of `if (mag(A) > B)`), they were fixed. Patches are submitted upstream.

Since the patch is a fresh start compared to 2.3.x and 2.4.x versions, there could be certain bugs, which were not revealed by quick tutorials check. Use github Issues functionality to report them.

Build process was tested on:

```sh
alexey at daphne in ~$ sw_vers
ProductName:	Mac OS X
ProductVersion:	10.10.4
BuildVersion:	14E46
```

with the following compiler

```sh
alexey at daphne in ~$ clang --version
Apple LLVM version 6.1.0 (clang-602.0.53) (based on LLVM 3.6.0svn)
Target: x86_64-apple-darwin14.4.0
Thread model: posix
```

and with the following third party package versions:

```sh
alexey at daphne in ~$ brew list --versions
boost 1.57.0
cgal 4.6
gmp 6.0.0a
metis 5.1.0
mpfr 3.1.2-p11
open-mpi 1.8.4_1
parmetis 4.0.3
parmgridgen 0.0.1
scotch 6.0.4_1
```

## June 5, 2015

Added patches for OpenFOAM 2.4.0 and 2.4.x (commit b750988).

The patches are an attempt to build OpenFOAM with -Wall -Wextra -std=c++11
flags. The following appears after addition of the flags:

1. C++11 deprecates register storage class. So I have removed it, also flex
   generates code that put this keyword in several places: added sed pipe after
   flex code generation to remove it.
2. Lots of "unused parameter" warnings. Solved this problem commenting out
   names of the unused parameters, like: fvPatch& /\* pp \*/.
3. Lots of "unused variable" warnings. These are due to love of developers to
   do thing like `#include "readTimeControls.H"` in the beginning of the
   solver, though not all created variables are used. Solved the problem by
   introducing `readInitialTimeControls.H` file and partially pruning unused
   chunks of code.
4. Quite a lot of hidden virtual functions warnings. These are due to mess in
   return types and method parameters (`postProcessing/functionObjects` library
   is an example of the problem). Solved by either declaring and implementing
   correct methods, or by "using Class::method" addition.
5. Tried to address constant reference dereferencing problem. Since it is not
   strictly defined behavior and, guess, results depend on compiler. So either
   added method returning pointer (since frequently OpenFOAM does this: const
   T& method() { return \*ptr; } ... a = method(); if (&a) { ... }, in general
   if condition should always be true), or boolean returning function checking
   validity of the pointer.
6. Corrected loop condition in readKivaGrid.H, though since it is there from
   version 1.1 (according to Bruno Santos), guess ether this incorrect loop
   exit condition never lead to any problems, or nobody converts Kiva meshes.
7. Removed trailing white-space in several places.
8. Added of240 and of24x environment setup functions to openfoam-env-setup.sh.
9. From now on, patches for git version will contain commit SHA for which they
   were created.

As usual, build was tested on:

```
alexey at daphne in ~$ sw_vers
ProductName:	Mac OS X
ProductVersion:	10.10.3
BuildVersion:	14D136
```

with the following compiler

```
alexey at daphne in ~$ clang --version
Apple LLVM version 6.1.0 (clang-602.0.53) (based on LLVM 3.6.0svn)
Target: x86_64-apple-darwin14.3.0
Thread model: posix
```

and with the following third party package versions:

```
boost 1.57.0
cgal 4.6
gmp 6.0.0a
metis 5.1.0
mpfr 3.1.2-p11
open-mpi 1.8.4_1
parmetis 4.0.3
parmgridgen 0.0.1
scotch 6.0.4_1
```

## May 5, 2015

1. As versions 2.1.x and 2.2.x have rather funny memory allocation bug, I have
   only one laptop, and I do not use those versions, further support of patches
   for these versions is dropped.
2. Patches for 2.3.1 and 2.3.x (commit
   [OpenFOAM/OpenFOAM-2.3.x@00eea57](https://github.com/OpenFOAM/OpenFOAM-2.3.x/commit/00eea576852a0b95b772665dc4414b9bc32ce17f)) include:
       - new printStack implementation (so there is no need in Python script for address resolution)
       - update of the code for new version of CGAL
       - corrections in METIS decomposition build logic
       - corrections in fvAgglomerationMethods build logic, so it can use Homebrew-installed ParMGridGen
       - corrections in sigFpe.C, so there is no more infinite loop in parallel run (due to print stack functionality in OpenMPI)
3. Initial foam-extend (commit [ec44c9](https://sourceforge.net/p/openfoam-extend/foam-extend-3.1/ci/ec44c952c9f8841ea5fba2bdb9235a5914c6c1c5/tree/)) patch
   attempt. Installation guide is in [wiki](https://github.com/mrklein/openfoam-os-x/wiki/foam-extend---Homebrew).
4. Homebrew formulae for Mesquite and ParMGridGen.

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
