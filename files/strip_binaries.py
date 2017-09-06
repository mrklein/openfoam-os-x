#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Strip full path names from libraries and executables."""

from __future__ import print_function, division


__version__ = '0.0.1'
__author__ = 'Alexey Matveichev'


def _strip_id(path):
    from subprocess import Popen, PIPE, call
    from os.path import basename

    p = Popen(['otool', '-D', path], stdout=PIPE)
    p.stdout.readline()
    file_id = p.stdout.readline()[:-1]
    p.communicate()
    call(['install_name_tool', '-id', basename(file_id), path])
    print('  {0} -> {1}'.format(path, basename(file_id)))


def _strip_libs(path, root):
    from subprocess import Popen, PIPE, call
    from os.path import basename

    p = Popen(['otool', '-L', path], stdout=PIPE)
    for l in p.stdout:
        if l.startswith('\t'):
            t = l.split(' ', 1)[0]
            t = t.strip()
            if t.startswith(root):
                call(['install_name_tool', '-change', t, basename(t), path])
                print('  {0} -> {1} in {2}'.format(t, basename(t), path))
    p.communicate()


def _read_environment(version):
    from os.path import join
    from subprocess import Popen, PIPE

    bashrc = join('OpenFOAM-{0}'.format(version), 'etc', 'bashrc')
    p = Popen(['bash', '-c', 'source {0} && env'.format(bashrc)], stdout=PIPE)

    prj_dir = None
    prj_opts = None
    prj_copts = None
    prj_label_size = None

    for l in p.stdout:
        (key, _, value) = l.partition('=')
        if key == 'WM_PROJECT_DIR':
            prj_dir = value.strip('\n')
        if key == 'WM_OPTIONS':
            prj_opts = value.strip('\n')
        if key == 'WM_COMPILE_OPTION':
            prj_copts = value.strip('\n')
        if key == 'WM_LABEL_SIZE':
            prj_label_size = value.strip('\n')

    p.communicate()
    return prj_dir, prj_opts, prj_copts, prj_label_size


def _strip(version, backup=True):
    from os import walk
    from os.path import join
    from shutil import copytree, Error
    from sys import stderr

    prj_dir, prj_opts, _, _ = _read_environment(version)

    plt_path = join(prj_dir, 'platforms', prj_opts)
    lib_path = join(prj_dir, 'platforms', prj_opts, 'lib')
    bin_path = join(prj_dir, 'platforms', prj_opts, 'bin')

    bkp_path = join(prj_dir, 'platforms', '{0}~'.format(prj_opts))
    if backup:
        try:
            copytree(plt_path, bkp_path)
        except Error as e:
            stderr.write('Can not create backup: {0}\n'.format(e.message()))

    print('Stripping libraries:')
    for root, dirs, files in walk(lib_path):
        for name in files:
            _strip_id(join(root, name))
            _strip_libs(join(root, name), plt_path)

    print('Stripping binaries:')
    for root, dirs, files in walk(bin_path):
        for name in files:
            _strip_libs(join(root, name), plt_path)


def _get_kernel_version():
    from os import uname
    _, _, release, _, _ = uname()
    return release


def _make_archive(version):
    """Make archive of platforms/.../bin and platforms/.../lib folders"""

    from os import chdir
    from subprocess import call
    from os.path import join
    from sys import stdout
    from shutil import move

    # Name of the archive is:
    # v<OF version>-D<OS X kernel version>[-ls<WM_LABEL_SIZE>]<option>.tar.xz
    # where
    #   OF version: OpenFOAM version
    #   OS X kernel version: Version of OS X kernel where binaries were built
    #   For version 3.0.0 and higher value of WM_LABEL_SIZE is also added
    #   option is optimization level: opt, debug, prof
    if version not in ['dev', 'v3.0+']:
        major = version.split('.')[0]
    else:
        major = 999
    _dir, _opts, copt, label_size = _read_environment(version)

    lib_path = join('platforms', _opts, 'lib')
    bin_path = join('platforms', _opts, 'bin')

    filename_fmt = 'v{0}-r{1}{2}-{3}.tar.bz2'

    if version == 'dev' or version.endswith('x'):
        from mkpatches import COMMITS
        if version in COMMITS['ROLLING'].keys():
            filename_fmt = 'v{{0}}-{0}-r{{1}}{{2}}-{{3}}.tar.bz2'.format(
                COMMITS['ROLLING'][version]
            )

    if int(major) >= 3:
        filename = filename_fmt.format(version, _get_kernel_version(),
                                       '-ls{0}'.format(label_size),
                                       copt.lower())
    else:
        filename = filename_fmt.format(version, _get_kernel_version(), '',
                                       copt.lower())

    chdir('OpenFOAM-{0}'.format(version))
    print('Creating archive {0} ... '.format(filename), end='')
    stdout.flush()
    call(['tar', 'cjf', filename, lib_path, bin_path])
    move(filename, '..')
    print('done.')
    chdir('..')


def _run():
    from argparse import ArgumentParser
    parser = ArgumentParser(
        description='Strip library paths from binary files.')
    parser.add_argument('-i', '--in-place', action='store_false',
                        dest='backup',
                        help='Do not create backup of platforms folder')
    parser.add_argument('-a', '--archive', action='store_true',
                        dest='archive',
                        help='Create archive of bin and lib folders')
    parser.add_argument('version', action='store', type=str, nargs='+',
                        help='OpenFOAM version to strip')
    args = parser.parse_args()
    for version in args.version:
        _strip(version, args.backup)
        if args.archive:
            try:
                _make_archive(version)
            except OSError:
                pass

if __name__ == '__main__':
    from sys import exit
    exit(_run())
