#!/bin/sh
#
# Deduplication of directories.  The idea is that my home directory
# ($HOME) will serve as the master copy and everything else (e.g.,
# files under /home/BACKUP from other systems) will be considered
# copies.  The copies will be replaced with symlinks to the master
# copy so the total disk space consumed stays low.  Symlinks are used
# rather than hardlinks so that backup size remains small.
#
# This script is intended for use as a cron(8) job entirely with
# command line options.
#
# by: David Cantrell <david.l.cantrell@gmail.com>.
#

PATH=/usr/bin
CWD="$(pwd)"
DIRS="$*"
CMD="$(basename $0)"

usage() {
    echo "Usage: ${CMD} [directory list]"
    echo "Example:"
    echo "    ${CMD} ${HOME} /home/BACKUP"
    echo

    echo "The order of directories specified is important.  The"
    echo "primary copy of duplicate files is in the first directory listed"
    echo "and so forth through the rest of the list."
}

# Required directories
if [ -z "${DIRS}" ]; then
    usage
    exit 1
fi

for d in ${DIRS} ; do
    if [ ! -d "${d}" ]; then
        echo "*** ${d} is not a directory" >&2
        exit 1
    fi
done

# Check for required commands
jdupes --help >/dev/null 2>&1
if [ $? -eq 127 ]; then
    echo "*** \`jdupes' command not found, exiting" >&2
    exit 1
fi



jdupes -l -O ${DIRS} -r ${DIRS}

# Example:
# jdupes -m -O /home/dcantrell /home/BACKUP -l -r /home/dcantrell /home/BACKUP
