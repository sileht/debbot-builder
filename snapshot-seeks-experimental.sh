#!/bin/bash
set -e

DEBIAN_NAME=seeks-experimental
SEEKS_URL="git://seeks.git.sourceforge.net/gitroot/seeks/seeks"
OUTDIR=/home/www/archive.sileht.net/seeks-snapshot/

TMP_DIR="$(mktemp -d /dev/shm/seeks-XXXX)"

clean_exit(){
    rm -rf ${TMP_DIR}
    exit 0
}

trap clean_exit KILL EXIT

mkdir -p $TMP_DIR/src
# Checkout
git clone --depth 1 -b experimental ${SEEKS_URL} ${TMP_DIR}/src

# Prepare source
pushd ${TMP_DIR}/src &>/dev/null
sh ./autogen.sh
# delete stupid temporary file
rm -rf autom4te.cache
VERSION=$(sed -n -e 's/.*SEEKS_VERSION,"\([^,]*\)",.*/\1/gp' ${TMP_DIR}/src/configure.in )~git$(date -d @$(git log -1 --pretty="format:%ct") '+%Y%m%d%H%M')
popd
mv ${TMP_DIR}/src ${TMP_DIR}/${DEBIAN_NAME}-${VERSION}

# create tarball
if [ ! -f $OUTDIR/${DEBIAN_NAME}-${VERSION}.tar.gz ]; then
    pushd ${TMP_DIR} &>/dev/null
    tar -czf $OUTDIR/${DEBIAN_NAME}-${VERSION}.tar.gz --exclude=.git ${DEBIAN_NAME}-${VERSION}
    echo "* Done (created ${DEBIAN_NAME}-${VERSION}.tar.gz)"
    popd
else
    echo
    echo "tarball are uptodate"
fi
clean_exit
