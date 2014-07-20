# Modified files that can be used separate from patches

## Alltest

A file from `tutorials` folder. Changed sed patterns to correctly deal
with tabs.

## addr2line_mac.py

Added support for llvm debugger. Corrected source to pass pylint.

## openfoam-env-setup.sh

File can be copied to home folder and sourced from .profile. Adds two types of
functionality: automatic OpenFOAM environment setup and functions for
environment setup per version.
