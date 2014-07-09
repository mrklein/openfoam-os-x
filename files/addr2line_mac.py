#!/usr/bin/env python

"""Emulation of addr2line utility."""


import subprocess as sp

DEFAULT_ANSWER = "??:0"

def gdb_is_available():
    """Check if gdb is installed."""
    res = sp.call(['which', '-s', 'gdb'])
    return res == 0

def lldb_is_available():
    """Check if lldb is installed."""
    res = sp.call(['which', '-s', 'lldb'])
    return res == 0

def addr2line_gdb(filename, address):
    """Convert address into line of source file using gdb."""
    proc = sp.Popen("gdb -batch -x /dev/stdin",
                    shell=True,
                    bufsize=0,
                    stdin=sp.PIPE,
                    stdout=sp.PIPE,
                    close_fds=True)

    (child_stdin, child_stdout) = (proc.stdin, proc.stdout)
    child_stdin.write("set sharedlibrary preload-libraries no\n")
    child_stdin.write("file " + filename + "\n")
    child_stdin.write("info line *" + address + "\n")
    res = child_stdout.readline()

    import re

    match = re.compile('Line (.+) of "(.+)" starts at').match(res)
    if match:
        return match.group(2) + ":" + match.group(1)
    else:
        return DEFAULT_ANSWER

def addr2line_lldb(filename, address):
    """Convert address into line of source file using lldb."""
    import sys

    lldb_python_path = sp.check_output(['lldb', '-P'])
    sys.path.insert(0, lldb_python_path[:-1])

    import lldb

    addr = int(address, 16)

    dbg = lldb.SBDebugger.Create()
    dbg.SetAsync(False)
    tgt = dbg.CreateTargetWithFileAndArch(filename,
                                          lldb.LLDB_ARCH_DEFAULT)

    for mdl in tgt.module_iter():
        sb_addr = mdl.ResolveFileAddress(addr)
        resolved_addr = mdl.ResolveSymbolContextForAddress(
            sb_addr,
            lldb.eSymbolContextEverything
        )

        if resolved_addr.IsValid():
            line_entry = resolved_addr.GetLineEntry()
            file_ = line_entry.GetFileSpec()
            line = line_entry.GetLine()
            if line_entry.ling != 0:
                return "{0}:{1}".format(file_, line)
    return DEFAULT_ANSWER


def run():
    """Determine file and line for a given address."""
    import sys

    filename = sys.argv[1]
    address = sys.argv[2]

    answer = DEFAULT_ANSWER

    if gdb_is_available():
        answer = addr2line_gdb(filename, address)

    if lldb_is_available():
        answer = addr2line_lldb(filename, address)

    print answer,

    sys.exit(255)

if __name__ == '__main__':
    run()
