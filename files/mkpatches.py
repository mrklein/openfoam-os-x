#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function
import sys

__version__ = '0.0.1'
__author__ = 'Alexey Matveichev'

COMMITS = {
    'RELEASES': {
        '4.0': '068045d',
        '4.1': '40e815b',
        '5.0': 'fe83070'
    },
    'ROLLING': {
        '2.2.x': '1f35a0ff',
        '2.4.x': '2b147f4',
        '3.0.x': 'ec1903cb',
        '4.x': '56a4152a9',
        '5.x': '718111a3b',
        'dev': '1bb7db2b7'
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

    # Commit uncommitted changes
    dirty = subprocess.call(['git', 'diff-files', '--quiet'])
    if dirty == 1:
        print('Committing everything.')
        subprocess.call(['git', 'commit', '-a', '-m', 'mkpatches'])

    try:
        subprocess.check_output(['git', 'commit', '-a', '-m', 'Fix'],
                                stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError:
        pass
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
    parser.add_argument('-i', '--initial-commit', action='store',
                        dest='commit', nargs=1)
    options = parser.parse_args()

    for release_type, pairs in sorted(COMMITS.items()):
        for version, commit in pairs.items():
            if options.version is not None:
                if version in options.version:
                    try:
                        _make_patch(version, commit)
                    except RuntimeError:
                        return 127
            else:
                try:
                    _make_patch(version, commit)
                except RuntimeError:
                    return 127
    return 0

if __name__ == '__main__':
    import sys
    sys.exit(_make_patches())
