# OpenFOAM(R) on OS X

Patches for OpenFOAM(R) compilation on macOS. Detailed installation
instructions can be found in
[wiki](https://github.com/mrklein/openfoam-os-x/wiki).

## Disclaimer

This offering is not approved or endorsed by OpenCFD Limited, producer and
distributor of the OpenFOAM software via www.openfoam.com, and owner of the
OPENFOAM(R)  and OpenCFD(R)  trade marks.

## Acknowledgement

OPENFOAM(R)  is a registered trade mark of OpenCFD Limited, producer and
distributor of the OpenFOAM software via www.openfoam.com.

## Oct. 5, 2022

- Updated Foundation dev patch.

## Aug. 7, 2022

- OpenFOAM 10 patch
- OpenFOAM v2206 patch (submitted upstream)

## Sep. 23, 2021

- Fixed OpenFOAM 9 patch (since GMP and MPFR formulae are not linked, their path should be passed explicitly).
- Updated dev patch.

## Sep. 22, 2021

Added patch for OpenFOAM 9.

## Jan. 23, 2021

Added patch for OpenFOAM v2012. Slight correction of the patch for the previous
version. `OpenQBBM` fixed obsolete `gamma` function issue, yet, decided to
leave `alphaMax` constructor issue in
`JohnsonJacksonParticleSlipFvPatchVectorField.C` where it was.

## Aug. 10, 2020

Added OpenFOAM 8 and OpenFOAM v2006 patches.

In case of OpenFOAM 8 it is simple adaptation of the previous patch.

For OpenFOAM v2006 due to external modules it
was necessary to make more changes:
- Changed ADIOS configuration logic (`has_adios` script). Instead of looking
  for header and library, look up `adios2-config` utility and check if
  cxx-flags and cxx-libs are not empty.
- Avalanche defines `ntohl` inline function, yet does not check it is already
  defined. So on OS X compilation stops with rather misleading messages about
  missing braces.
- `OpenQBBM` module uses obsolete `gamma` function. Decided to change it into
  `tgamma`. *NOTE!* Maybe it should be changed to `lgamma` instead, if original
  author meant to calculate logarithm of gamma (as in glibc).

## Apr. 9, 2020

Updated version OpenFOAM(R) 5.x, 6, and 7 patches. Added OpenFOAM(R) v1912 patch. Notes:

- Set C++ standard to `C++14` in `wmake` rules due to `CGAL` 5.0. It started to
  requite C++14 and became header only.
- Rewrote SIP remedy code. It was started as an issue in OpenCFD GitLab and
  resulted in modified configuration logic.
- Fixed `csh` initialisation scripts, so users of `tcsh` can use `source
  etc/cshrc` to initialise environment.

Small note on `WM_LABEL_SIZE=64`: since all Mac OS X installations are
performed on personal notebooks I do not see a point in using 64-bit labels. So
I won't test this configuration any more. Though I am open to suggestions and
reasoning behind using 64-bit labels.

## Jul. 15, 2019

Added version 7 patch. Updated patches for 5.x and 6.

## Sept. 8, 2018

Updated version 6 and dev patches.

## July 28, 2018

Added patches for version 6.

Someone in the Foundation hates versioning, so now it is impossible to
distinguish release (let's call it 6.0) from bug-fixes version (6.x). Guess,
next step will be to abandon versions at all.

## May 23, 2018

Updated dev patch.

dev branch `wmkdep` now makes certain substitutions in dep files (-R command
line switches). It fails to do it properly if `-R /` is passed to the command.

There were two possibilities: either to modify `wmake/rules/General/transform`
by removing line `-R '$(WM_THIRD_PARTY_DIR)/' '$$(WM_THIRD_PARTY_DIR)/' \`, or
add check for `/` search pattern in `wmkdep.l`. Opted for latter.

## May 22, 2018

- Updated 5.x patch.
- In dev branch some fancy modifications to `wmkdep` were made, so I have decided
  to postpone patch update for this version.

## Apr. 14, 2018

Updated 5.x and dev patches.

## Nov. 25, 2017

Updated 5.x and dev patches. Since Foundation decided to abandon version
numbering, 5.0 patch will not receive any updates or corrections.

## Aug. 11, 2017

Update

- Added patches for versions 5.0 and 5.x (they already started to diverge).
- Updated patches for 4.0, 4.1, and 4.x to remedy a problem of 64-bit label build reported here: https://www.cfd-online.com/Forums/openfoam-installation-windows-mac/187102-installing-openfoam-4-1-mac-os-sierra.html#post658361.

`WM_QUIET_RULES` are temporary gone in 5.x series.

## May 13, 2017

wmake unification made it simpler to update patches, so returned 3.0.x and dev
into tree (it seems 3.0.x is still widely used), updated foamJob script
to account for macOS releases greater than 15.

## May 8, 2017

Update.

- Only 2.2.x, 2.4.x, 4.0, 4.1, and 4.x patches are kept. Other versions
  could appear later, but since I do not use them, odds are rather low (old
  patches still can be found in repository history).
- wmake is unified across versions (with `WM_QUIET_RULES`, to reduce noise in
  log-files).
- Latest CLT update requires addition of `-Wno-undefined-var-template` to avoid
  excess of warnings.
- Paraview configuration file now looks for Paraview\*.app, this resolves #32.
- Check for wxt terminal is added to foamMonitor script, a workaround for #31.
- IOobject emits mode-line for vi and adds foamVersion to header.

Build process was tested on

```
$ sw_vers
ProductName:	Mac OS X
ProductVersion:	10.12.4
BuildVersion:	16E195
```

with

```
$ clang++ --version
Apple LLVM version 8.1.0 (clang-802.0.42)
Target: x86_64-apple-darwin16.5.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

and the following third-party software

```
$ brew list --versions
...
boost 1.63.0
cgal 4.9.1
eigen 3.3.3
gmp 6.1.2
gnuplot 5.0.6
isl 0.18
libmpc 1.0.3
metis 5.1.0
mpfr 3.1.5
open-mpi 2.1.0
parmetis 4.0.3_4
scotch 6.0.4_4
...
```

## Oct. 28, 2016

Following recent bug-reports updated `dev` patch (up to commit `37c5d28`).
Major changes:

- Usage of CLT utilities are forced (using `xcrun`), hope this will resolve
  problems of third party `cpp`s and `flex`es.
- Draft of `WM_SILENT_RULES`, so build log files now look like

    ```sh
    + wmake dummy
    /Users/alexey/OpenFOAM/OpenFOAM-dev/src/Pstream/dummy
        LN ./lnInclude
       DEP UIPread.C
       DEP UPstream.C
       DEP UOPwrite.C
        CC UPstream.C
        CC UIPread.C
        CC UOPwrite.C
        LD libPstream.dylib
    ->> libPstream.dylib
    ```

- `IOobject`'s `writeEndDivider` is modified to emit mode line for vim.

## Oct. 19, 2016

Added patch for version 4.1 (it is almost the same as `4.x-7dce081` patch).

## Oct. 4, 2016

Updated 4.x patch. Build process was tested on

```
$ sw_vers 
ProductName:	Mac OS X
ProductVersion:	10.12
BuildVersion:	16A323
```

with

```
$ clang --version
Apple LLVM version 8.0.0 (clang-800.0.38)
Target: x86_64-apple-darwin16.0.0
Thread model: posix
InstalledDir:
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

and the following third-party packages

```
$ brew list --versions
...
boost 1.61.0_1
cgal 4.9
eigen 3.2.9
gmp 6.1.1
libmpc 1.0.3
metis 5.1.0
mpfr 3.1.5
open-mpi 2.0.1
parmetis 4.0.3_4
parmgridgen 0.0.2
scotch 6.0.4_4
...
```

## July 30, 2016

Updated 2.4.x (problem with `/usr/include` in -I flags for CGAL) and 4.x
(new commits in this branch) patches.

## June 29, 2016

Patches for 4.0 and 4.x (well, slight modification of the last -dev patch).

## June 21, 2016

Updated 3.0.x and dev patches. Currently by default foamyMesh is not built, if
you need it, set `FOAMY_HEX_MESH` environment variable to non-empty value (for
example add `export FOAMY_HEX_MESH=Y` to `prefs.sh`).

Build process was tested on

```
$ sw_vers 
ProductName:	Mac OS X
ProductVersion:	10.11.5
BuildVersion:	15F34
```

with

```
$ clang++ --version
Apple LLVM version 7.3.0 (clang-703.0.31)
Target: x86_64-apple-darwin15.5.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

and the following third-party packages:

```
$ brew list --versions
boost 1.60.0_2
cgal 4.7
gmp 6.1.0
metis 5.1.0
mpfr 3.1.4
open-mpi 1.10.2_1
parmetis 4.0.3_3
parmgridgen 0.0.2
scotch 6.0.4_1
```

## March 29, 2016

Updated 3.0.1 and 3.0.x patches to fix problem on CLT only systems (reported by
Nikolai Tauber), this includes:

1. Correction of wmake rules (if `xcrun --show-sdk-path` returned empty string
   remove part of `CC` command).
2. Small addition to `Allwmake` script to set up environment if it is not.
   Since any way `Allwmake` script should be run from `$WM_PROJECT_DIR`, we
   could source `etc/bashrc` in the beginning to remedy quite confusing
   `./Allwmake: line 7: /wmake/scripts/AllwmakeParseArguments: No such file or directory`.

Build process was tested on

```
$ sw_vers
ProductName:	Mac OS X
ProductVersion:	10.11.4
BuildVersion:	15E65
```

with

```
$ clang++ --version
Apple LLVM version 7.3.0 (clang-703.0.29)
Target: x86_64-apple-darwin15.4.0
Thread model: posix
InstalledDir: /Library/Developer/CommandLineTools/usr/bin
```

and the following third-party software (there is still problem with new
Homebrew's METIS, so, no METIS this time)

```
$ brew list --versions
boost 1.60.0_1
cgal 4.7
gmp 6.1.0
mpfr 3.1.3
open-mpi 1.10.2
scotch 6.0.4_1
```

## February 24, 2016

1. Updated patches for 3.0.x and dev.
  - in 3.0.x unsilenced wmkdep utility, so now this part of build process is
    marked as [DEP]
  - By accident added matrix constraining in scalar transport solver.
2. Tried to extend third-party software configuration logic, i.e. if brew is
   not found, try port, and fall-back to /usr/local if neither brew, nor port
   were found. Since I have only brew on my laptop, functionality is not
   tested.

## January 25, 2015

Though OpenCFD distributes Docker images for OS X, to me native compilation
looks more convenient (for people who does not like compilation, there are
precompiled binaries). Installation guide is almost the same as for any other
release ([OpenFOAM(R) release & Homebrew](https://github.com/mrklein/openfoam-os-x/wiki/OpenFOAM%20release%20&%20Homebrew)),
except:

1. Download URL is [OpenFOAM-v3.0+.tgz](https://sourceforge.net/projects/openfoamplus/files/OpenFOAM-v3.0+.tgz).
2. Graphics function objects (`$FOAM_SRC/postProcessing/functionObjects/graphics`) depend on [VTK](http://vtk.org). You can install the library with Homebrew (right now there is Python library path problem with bottled version, so either install using `--build-from-source` flag, or edit `$(brew --prefix)/opt/vtk/lib/cmake/vtk-6.3/Modules/vtkPython.cmake` so it points to valid Python installation).
3. Compilation of Zoltan renumber functionality is silently skipped.

## January 18, 2015

Updated patch for development OpenFOAM(R) branch.

## December 18, 2015

1. Patch for OpenFOAM(R) 3.0.1 (it was the same as the last 3.0.x patch)
2. Since any way I am testing success of build process, decided to upload
   binary archives. More details can be found in [wiki](https://github.com/mrklein/openfoam-os-x/wiki/Binary-archives).

## December 15, 2015

Major update.

1. Changed wmake rules for Darwin. ~~Hopefully this solves problems with missing
   symbols ([1](http://www.cfd-online.com/Forums/openfoam-installation-windows-mac/130113-compile-2-3-mac-os-x-patch-7.html#post576975), [2](http://www.cfd-online.com/Forums/openfoam-installation-windows-mac/130113-compile-2-3-mac-os-x-patch-6.html#post572934)). Though, since I never had this problem on my laptop it is a question of external testing.~~ No, it did not solve the problem.

2. Fixed bugs and typos in RunFunctions, also added overwrite flag from
   dev-repository (now run(Application|Parallel) functions have -f, -force, --force,
   -overwrite flags to run application overwriting log-file, and -a, -append,
   --append flags to run application and append to log-file).

3. Just for fun added emulation of "silent rules" in 3.0.x. To turn this
   feature on you need to set `WM_SILENT_RULES` to non-empty value (`export
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
   
As usual, build was tested on:

```
daphne:openfoam-os-x$ sw_vers 
ProductName:	Mac OS X
ProductVersion:	10.11.2
BuildVersion:	15C50
```

with the following compiler:

```
daphne:openfoam-os-x$ clang++ --version
Apple LLVM version 7.0.2 (clang-700.1.81)
Target: x86_64-apple-darwin15.2.0
Thread model: posix
```

and the following thrid party packages:

```
daphne:openfoam-os-x$ brew list --versions
boost 1.59.0
cgal 4.6.3
eigen 3.2.6
gmp 6.1.0
metis 5.1.0
mpfr 3.1.3
open-mpi 1.10.1
parmetis 4.0.3_3
parmgridgen 0.0.2
scotch 6.0.4_1
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

Updated patches for OpenFOAM(R) 2.3.1 and 2.4.0.

## September 8, 2015

Updated patches for 2.3.x and 2.4.x (forgot certain things). Added patches for
2.2.x and 2.1.x (`reinterpret_cast<const void*>` solution for reference address seems to solve memory corruption
problem).

Test platform and third party software versions did not change since
September 5.

## September 5, 2015

Updated patches for 2.3.x (`OpenFOAM-2.3.x-2f9138f.patch`) and 2.4.x
(`OpenFOAM-2.4.x-8685344.patch`) versions. This time decided not to be too
invasive, so ended up with 50k patches (with stats). There were 3 general types
of modifications:

1. OS X specifics in OSspecific/POSIX folder. These are again has two types:
   additions of certain OS X headers (like sys/time.h in clockTime.H) and
   reimplementation of functionality (like chunks in printStack.C, POSIX.C, and
   sigFpe.?)
2. Clang's cpp does not fully support "traditional mode", so it does not
   understand continuations after comments. There were two variants: remove
   these comments or install traditional cpp. Chose the first variant.
3. Warnings. First type comes from OpenFOAM(R)'s desire to take address of the
   reference and the other one comes from third party software (updated CGAL).
   First problem could be solved by `-Wno-...` flag, yet I have chosen
   `reinterpret_cast` way. The second problem is solved by conditional
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

Added patch for `OpenFOAM-dev` (commit 40310a5). Though this time patch is less
invasive, so maybe it will work with later commits.

The patch is a continuation of an attempt to build OpenFOAM(TM) with `-Wall
-Wextra -std=c++11` flags.

1. register storage class is removed in dev-branch, so the only places where it
   appears are sources generated by flex. Added pragmas to suppress warnings.
2. Still lots of unused parameter warnings. Commented them out (sometimes it is
   convenient to keep name of parameter since it a bit of documentation,
   sometimes parameters have names like `p`, yet for consistency I have decided
   to use comments everywhere). Patch was submitted upstream.
4. printStack functionality uses only lldb. So implementation became simplified
   compared to 2.(3|4).x version.
5. Boost and CGAL both have unused parameters and tautological comparison
   warnings, added pragmas around include lines to ignore them.
6. Scotch decomposition method is disabled when OpenFOAM(TM) is build with
   `WM_LABEL_SIZE=64`, since it requires recompilation of Scoth. Maybe later
   I will create special Homebrew formula for this version.
7. Clang on OS X does not want to do certain implicit conversions, so long.H
   and ulong.H headers were added to explicitly create Ostream methods for long
   and unsigned long types.
8. Miscellaneous bugs where revealed due to no implicit type coercion (like `if
   (mag(A > B))` instead of `if (mag(A) > B)`), they were fixed. Patches are
   submitted upstream.

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

Added patches for OpenFOAM(R) 2.4.0 and 2.4.x (commit b750988).

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

1. Updated OpenFOAM(TM) 2.3.1 patch for new version of Scotch.
2. Added patch to fix Scotch linking. Though patch was tested on 2.3.1, guess
   it will work on 2.3.0 and 2.2.x versions.

## Dec. 13, 2014

Added patch for OpenFOAM(TM) 2.3.1. Build was tested on:

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
