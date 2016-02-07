#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

__version__ = '0.0.1'
__author__ = 'Alexey Matveichev'

__COMMITS = {
    'RELEASES': {
        '2.3.1': '8bff3a6',
        '2.4.0': 'cbfb16f',
        '3.0.0': '9bdcbc8',
        '3.0.1': 'bb00c1f'
    },
    'ROLLING': {
        '2.2.x': '1f35a0f',
        '2.3.x': '2f9138f',
        '2.4.x': '2b147f4',
        '3.0.x': 'f5fbd39',
        'dev': '665b1f8'
    }
}


def _make_patch(version, start):
    """Create patch for a given version and starting commit.

    :version string: OpenFOAM version.
    :start string: Commit SHA1 for which diff will be calculated.
    """

    import os
    import subprocess

    print('Creating patch for OpenFOAM-{0}'.format(version))
    os.chdir('OpenFOAM-{0}'.format(version))
    diff = subprocess.check_output(['git', 'diff', '--patch-with-stat', start,
                                    'HEAD'])
    os.chdir('..')

    diff_filename = None
    if version.endswith('x') or version == 'dev':
        diff_filename = 'OpenFOAM-{0}-{1}.patch'.format(version, start)
    else:
        diff_filename = 'OpenFOAM-{0}.patch'.format(version)

    if diff_filename is None:
        raise RuntimeError('Diff filename can not be None')

    f = open(os.path.join('patches', diff_filename), 'w')
    f.write(diff)
    f.close()


def _make_patches():
    """Create patches for known versions."""
    from argparse import ArgumentParser
    parser = ArgumentParser(version='%prog {0}'.format(__version__))
    parser.add_argument('-n', '--only', action='store',
                        dest='version', nargs='+',
                        help='Create patches only for given versions')
    options = parser.parse_args()

    for release_type, pairs in sorted(__COMMITS.items()):
        for version, commit in pairs.items():
            if options.version is not None:
                if version in options.version:
                    _make_patch(version, commit)
            else:
                _make_patch(version, commit)

if __name__ == '__main__':
    _make_patches()
