#!/bin/bash

set -xe

SELF=$((cd `dirname $0`; pwd)

mkdir -p $SELF/local
pushd $SELF/local
wget https://ftp.gnu.org/gnu/gnugo/gnugo-3.8.tar.gz
tar zxf gnugo-3.8.tar.gz
cd gnugo-3.8
mkdir dist
./configure --prefix=`pwd`/dist --without-readline --without-curses
make
make install
popd
