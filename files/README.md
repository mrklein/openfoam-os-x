# Modified files that can be used separate from patches

## Alltest

A file from `tutorials` folder. Changed sed patterns to correctly deal
with tabs.

## addr2line_mac.py

Added support for llvm debugger. Corrected source to pass pylint. If you'd like
to use it with already installed OpenFOAM, rename it into addr2line4Mac.py and
place in $WM_PROJECT_DIR/bin folder.

## openfoam-env-setup.sh

File can be copied to home folder and sourced from .profile. Adds two types of
functionality: automatic OpenFOAM environment setup and functions for
environment setup per version.

## printStack.C

OS X modification of new printStack implementation. Just in case you would like
to integrate it in compiled code-base.

## sigFpe.C

Modification of sigFpe.C to avoid infinite loop in parallel run.
