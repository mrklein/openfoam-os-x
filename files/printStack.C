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

#include "error.H"
#include "IStringStream.H"
#include "OStringStream.H"
#include "OSspecific.H"
#include "IFstream.H"
#include "ReadHex.H"

#include <stdio.h>
#include <cxxabi.h>
#include <execinfo.h>
#include <dlfcn.h>

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

namespace Foam
{

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
string pOpen(const string &cmd, label line=0)
{
    char *buf = NULL;
    size_t linecap = 0;
    ssize_t linelen;
    string res = "\n";

    FILE *pipe = popen(cmd.c_str(), "r");

    if (pipe)
    {
        // Read line number of lines
        for (label cnt = 0; cnt <= line; cnt++)
        {
            linelen = getline(&buf, &linecap, pipe);

            if (linelen < 0)
                break;

            if (cnt == line)
            {
                res = string(buf);
                break;
            }
        }

        if (buf != NULL)
            free(buf);

        pclose(pipe);
    }

    return res.substr(0, res.size() - 1);
}

inline word addr2word(void *p)
{
    const size_t WORD_SIZE = 18 + 1; // from (g)libc
    char buf[WORD_SIZE];
    snprintf(buf, WORD_SIZE, "%p", p);

    return word(buf);
}

void printSourceFileAndLine
(
    Ostream& os,
    const fileName& filename,
    void* address,
    Dl_info* info
)
{
    word myAddress = addr2word(address);

#ifndef darwin
    if (filename.ext() == "so")
    {
        // Convert offset into .so into offset into executable.

        dladdr(address, info);

        unsigned long offset = reinterpret_cast<unsigned long>(info->dli_fbase);
        void* rel = address - offset;

        myAddress = addr2word(rel);
    }
#endif

    if (filename[0] == '/')
    {
        string line = pOpen
        (
#ifndef darwin
            "addr2line -f --demangle=auto --exe "
          + filename
          + " "
          + myAddress,
            1
#else
#if defined FOAM_ADDR2LINE_ATOS
            "xcrun atos -o "
          + filename 
          + " -l "
          + addr2word(info->dli_fbase)
          + " "
          + myAddress
#elif defined FOAM_ADDR2LINE_LLDB
            "echo 'image lookup -a "
          + myAddress
          + " "
          + filename 
          + "'"
          + " | xcrun lldb "
          + "-O 'target create --no-dependents -a x86_64 "
          + filename
          + "' -o '"
          + "target modules load -f "
          + filename
          + " __TEXT "
          + addr2word(info->dli_fbase)
          + "'"
          + " | tail -1"
#else
            "addr2line_mac.py"
          + filename
          + " "
          + myAddress
#endif
#endif // darwin
        );

#ifdef darwin
        {
            const char *buf = line.c_str();
            regex_t re;
            regmatch_t mt[3];
            int st;

#if defined FOAM_ADDR2LINE_ATOS
            regcomp(&re, ".\\+(in.\\+) (\\(.\\+\\):\\(\\d\\+\\))",
                REG_ENHANCED);
#elif defined FOAM_ADDR2LINE_LLDB
            regcomp(&re, ".\\+at \\(.\\+\\):\\(\\d\\+\\)", REG_ENHANCED);
#endif

#if defined FOAM_ADDR2LINE_ATOS || defined FOAM_ADDR2LINE_LLDB
            st = regexec(&re, buf, 3, mt, 0);

            if (st == REG_NOMATCH)
            {
                line = "??:0";
            }
            else
            {
                size_t len = mt[1].rm_eo - mt[1].rm_so;
                string fname(buf + mt[1].rm_so, len);
                len = mt[2].rm_eo - mt[2].rm_so;
                string lnum(buf + mt[2].rm_so, len);
                line = fname + ":" + lnum;
            }
            regfree(&re);
#endif
        }
#endif  // darwin

        if (line == "")
        {
            os  << " addr2line failed";
        }
        else if (line == "??:0")
        {
            string line = static_cast<string>(filename);
            string cwdLine(line.replaceAll(cwd() + '/', ""));
            string homeLine(cwdLine.replaceAll(home(), '~'));

            os  << " in " << homeLine.c_str();
        }
        else
        {
            string cwdLine(line.replaceAll(cwd() + '/', ""));
            string homeLine(cwdLine.replaceAll(home(), '~'));

            os  << " at " << homeLine.c_str();
        }
    }
}

void error::safePrintStack(std::ostream& os)
{
    // Get raw stack symbols
    void *array[100];
    size_t size = backtrace(array, 100);
    char **strings = backtrace_symbols(array, size);

    // See if they contain function between () e.g. "(__libc_start_main+0xd0)"
    // and see if cplus_demangle can make sense of part before +
    for (size_t i = 0; i < size; i++)
    {
        string msg(strings[i]);
        fileName programFile;
        word address;

        os  << '#' << label(i) << '\t' << msg << std::endl;
    }
}

fileName absolutePath(const char* fn)
{
    fileName fname(fn);

    if (fname[0] != '/' && fname[0] != '~')
    {
        string tmp = pOpen("which " + fname);

        if (tmp[0] == '/' || tmp[0] == '~')
            fname = tmp;
    }

    return fname;
}

string demangleSymbol(const char* sn)
{
    string res;
    int st;
    char* cxx_sname = abi::__cxa_demangle
    (
        sn,
        NULL,
        0,
        &st
    );

    if (st == 0 && cxx_sname)
    {
        res = string(cxx_sname);
        free(cxx_sname);
    }
    else
    {
        res = string(sn);
    }

    return res;
}


void error::printStack(Ostream& os)
{
    // Get raw stack symbols
    const size_t CALLSTACK_SIZE = 128;

    void *callstack[CALLSTACK_SIZE];
    size_t size = backtrace(callstack, CALLSTACK_SIZE);

    Dl_info *info = new Dl_info;

    fileName fname = "???";

    for(size_t i = 0; i < size; i++)
    {
        int st = dladdr(callstack[i], info);

        os << '#' << label(i) << "  ";
        if (st != 0 && info->dli_fname != NULL && info->dli_fname[0] != '\0')
        {
            fname = absolutePath(info->dli_fname);

            os << ((info->dli_sname != NULL) ?
                demangleSymbol(info->dli_sname) : "?");
        }
        else
        {
            os << "(unresolved)";
        }

        printSourceFileAndLine(os, fname, callstack[i], info);

        os << nl;
    }

    delete info;
}


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

} // End namespace Foam

// ************************************************************************* //
