#!/bin/sh

FLAGS=""

for arg in "$@"; do
    FLAGS="-mllvm -$arg $FLAGS"
done

export CC=`pwd`/install/bin/clang
export CFLAGS="-O2 $FLAGS"

cd test/secp256k1
make clean
./autogen.sh
./configure
make -j
make check