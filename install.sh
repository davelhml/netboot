#! /bin/bash

set -ex
name=${1:-lms}

cd /tmp
wget http://10.95.31.210/testing/latest/packages/${name}_installer.tar.gz
tar xzf ${name}_installer.tar.gz && rm -f ${name}_installer.tar.gz
cd ${name}_installer/
./install.sh ${name}
