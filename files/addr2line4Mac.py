#!/usr/bin/env python

import sys
import subprocess as s

def gdbIsAvailable():
    """Check if gdb is installed."""
    r = s.call(['which', '-s', 'gdb'])
    return r == 0

def lldbIsAvailable():
    """Check if lldb is installed."""
    r = s.call(['which', '-s', 'lldb'])
    return r == 0

filename=sys.argv[1]
address=sys.argv[2]

answer="??:0"

if gdbIsAvailable():
    p = s.Popen("gdb -batch -x /dev/stdin",
                shell=True,
                bufsize=0,
                stdin=s.PIPE,
                stdout=s.PIPE,
                close_fds=True)

    (child_stdin, child_stdout) = (p.stdin, p.stdout)
    child_stdin.write("set sharedlibrary preload-libraries no\n")
    child_stdin.write("file "+filename+"\n")
    child_stdin.write("info line *"+address+"\n")
    result=child_stdout.readline()


    import re
    match=re.compile('Line (.+) of "(.+)" starts at').match(result)
    if match:
        answer=match.group(2)+":"+match.group(1)

if lldbIsAvailable():
    lldb_python_path = s.check_output(['lldb', '-P'])
    sys.path.insert(0, lldb_python_path[:-1])

    import lldb

    address = int(address, 16)

    debugger = lldb.SBDebugger.Create()
    debugger.SetAsync(False)
    target = debugger.CreateTargetWithFileAndArch(filename,
                                                  lldb.LLDB_ARCH_DEFAULT)

    for m in target.module_iter():
        sb_addr = m.ResolveFileAddress(address)
        resolved_addr = m.ResolveSymbolContextForAddress(
            sb_addr,
            lldb.eSymbolContextEverything
        )
        if resolved_addr.IsValid():
            line_entry = resolved_addr.GetLineEntry()
            file_ = line_entry.GetFileSpec()
            line = line_entry.GetLine()
            if line_entry.ling != 0:
                answer = "{0}:{1}".format(file_, line)

print answer,

sys.exit(255)
