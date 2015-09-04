/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     |
    \\  /    A nd           | Copyright (C) 2011-2013 OpenFOAM Foundation
     \\/     M anipulation  |
-------------------------------------------------------------------------------
License
    This file is part of OpenFOAM.

    OpenFOAM is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
    for more details.

    You should have received a copy of the GNU General Public License
    along with OpenFOAM.  If not, see <http://www.gnu.org/licenses/>.

\*---------------------------------------------------------------------------*/

#include "sigFpe.H"
#include "error.H"
#include "JobInfo.H"
#include "OSspecific.H"
#include "IOstreams.H"

#ifdef LINUX_GNUC

#   ifndef __USE_GNU
#       define __USE_GNU
#   endif

#   include <fenv.h>
#   include <malloc.h>

#elif defined(sgiN32) || defined(sgiN32Gcc)

#   include <sigfpe.h>

#endif

#if defined(__APPLE__)
#include <xmmintrin.h>
#include <malloc/malloc.h>
#include <sys/mman.h>
#include <unistd.h>
#endif

#include <stdint.h>
#include <limits>

// * * * * * * * * * * * * * * Static Data Members * * * * * * * * * * * * * //

struct sigaction Foam::sigFpe::oldAction_;


void Foam::sigFpe::fillSignallingNan(UList<scalar>& lst)
{
    lst = std::numeric_limits<scalar>::signaling_NaN();
}

#if defined(__APPLE__)
void *(*Foam::sigFpe::oldMallocHook_)
(
    struct _malloc_zone_t *zone,
    size_t size
) = NULL;

void *Foam::sigFpe::nanMallocHook_
(
    struct _malloc_zone_t *zone,
    size_t size
)
{
    void *result;

    result = oldMallocHook_(zone, size);

    UList<scalar> lst(reinterpret_cast<scalar*>(result), size/sizeof(scalar));
    fillSignallingNan(lst);

    return result;
}
#endif

#if defined(LINUX)

void *(*Foam::sigFpe::oldMallocHook_)(size_t, const void *) = NULL;

void* Foam::sigFpe::nanMallocHook_(size_t size, const void *caller)
{
    void *result;

    // Restore all old hooks
    __malloc_hook = oldMallocHook_;

    // Call recursively
    result = malloc(size);

    // initialize to signalling NaN
    UList<scalar> lst(reinterpret_cast<scalar*>(result), size/sizeof(scalar));
    fillSignallingNan(lst);

    // Restore our own hooks
    __malloc_hook = nanMallocHook_;

    return result;
}

#endif


#if defined(LINUX_GNUC) || defined(__APPLE__)

void Foam::sigFpe::sigHandler(int)
{
    // Reset old handling
    if (sigaction(SIGFPE, &oldAction_, NULL) < 0)
    {
        FatalErrorIn
        (
            "Foam::sigSegv::sigHandler()"
        )   << "Cannot reset SIGFPE trapping"
            << abort(FatalError);
    }

    // Update jobInfo file
    jobInfo.signalEnd();

    error::printStack(Perr);

    // Throw signal (to old handler)
    raise(SIGFPE);
}

#endif


// * * * * * * * * * * * * * * * * Constructors  * * * * * * * * * * * * * * //

Foam::sigFpe::sigFpe()
{
    oldAction_.sa_handler = NULL;
}


// * * * * * * * * * * * * * * * * Destructor  * * * * * * * * * * * * * * * //

Foam::sigFpe::~sigFpe()
{
    if (env("FOAM_SIGFPE"))
    {
#       if defined(LINUX_GNUC) || defined(__APPLE__)

        // Reset signal
        if (oldAction_.sa_handler && sigaction(SIGFPE, &oldAction_, NULL) < 0)
        {
            FatalErrorIn
            (
                "Foam::sigFpe::~sigFpe()"
            )   << "Cannot reset SIGFPE trapping"
                << abort(FatalError);
        }

#       endif
    }

    if (env("FOAM_SETNAN"))
    {
#       if defined(LINUX_GNUC)

        // Reset to standard malloc
        if (oldAction_.sa_handler)
        {
            __malloc_hook = oldMallocHook_;
        }

#       endif

#       if defined(__APPLE__)
        // Restoring old malloc handler
        if (oldMallocHook_ != NULL) {
            malloc_zone_t *zone = malloc_default_zone();

            if (zone != NULL)
            {
                mprotect(zone, getpagesize(), PROT_READ | PROT_WRITE);
                zone->malloc = oldMallocHook_;
                mprotect(zone, getpagesize(), PROT_READ);
            }
        }
#       endif
    }
}


// * * * * * * * * * * * * * * * Member Functions  * * * * * * * * * * * * * //

void Foam::sigFpe::set(const bool verbose)
{
    if (oldAction_.sa_handler)
    {
        FatalErrorIn
        (
            "Foam::sigFpe::set()"
        )   << "Cannot call sigFpe::set() more than once"
            << abort(FatalError);
    }

    if (env("FOAM_SIGFPE"))
    {
        bool supported = false;

#       if defined(LINUX_GNUC) || defined(__APPLE__)
        supported = true;

#       if defined(LINUX_GNUC)
        feenableexcept
        (
            FE_DIVBYZERO
          | FE_INVALID
          | FE_OVERFLOW
        );
#       endif
#       if defined(__APPLE__)
        _mm_setcsr(_MM_MASK_MASK &~
                   (_MM_MASK_OVERFLOW|_MM_MASK_INVALID|_MM_MASK_DIV_ZERO));
#       endif

        struct sigaction newAction;
        newAction.sa_handler = sigHandler;
        newAction.sa_flags = SA_NODEFER;
        sigemptyset(&newAction.sa_mask);
#       if defined (__APPLE__)
        // To avoid infinite loop in parallel run,
        // since OpenMPI install own error hook.
        if (sigaction(SIGFPE, &newAction, NULL) < 0)
#       else
        if (sigaction(SIGFPE, &newAction, &oldAction_) < 0)
#       endif
        {
            FatalErrorIn
            (
                "Foam::sigFpe::set()"
            )   << "Cannot set SIGFPE trapping"
                << abort(FatalError);
        }


#       elif defined(sgiN32) || defined(sgiN32Gcc)
        supported = true;

        sigfpe_[_DIVZERO].abort=1;
        sigfpe_[_OVERFL].abort=1;
        sigfpe_[_INVALID].abort=1;

        sigfpe_[_DIVZERO].trace=1;
        sigfpe_[_OVERFL].trace=1;
        sigfpe_[_INVALID].trace=1;

        handle_sigfpes
        (
            _ON,
            _EN_DIVZERO
          | _EN_INVALID
          | _EN_OVERFL,
            0,
            _ABORT_ON_ERROR,
            NULL
        );

#       endif


        if (verbose)
        {
            if (supported)
            {
                Info<< "sigFpe : Enabling floating point exception trapping"
                    << " (FOAM_SIGFPE)." << endl;
            }
            else
            {
                Info<< "sigFpe : Floating point exception trapping"
                    << " - not supported on this platform" << endl;
            }
        }
    }


    if (env("FOAM_SETNAN"))
    {
        bool supported = false;

#       if defined(LINUX_GNUC)
        supported = true;

        // Set our malloc
        __malloc_hook = Foam::sigFpe::nanMallocHook_;

#       endif

#       if defined(__APPLE__)
        malloc_zone_t *zone = malloc_default_zone();

        if (zone != NULL)
        {
            oldMallocHook_ = zone->malloc;
            if
            (
                mprotect(zone, getpagesize(), PROT_READ | PROT_WRITE) == 0
            )
            {
                zone->malloc = nanMallocHook_;
                if
                (
                    mprotect(zone, getpagesize(), PROT_READ) == 0
                )
                {
                    supported = true;
                }
            }
        }
#       endif


        if (verbose)
        {
            if (supported)
            {
                Info<< "SetNaN : Initialising allocated memory to NaN"
                    << " (FOAM_SETNAN)." << endl;
            }
            else
            {
                Info<< "SetNaN : Initialise allocated memory to NaN"
                    << " - not supported on this platform" << endl;
            }
        }
    }
}


// ************************************************************************* //
