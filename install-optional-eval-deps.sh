#!/usr/bin/env bash

#  Install just runner
dnf install -y tar
mkdir -p external
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to external/
#  Install my tests
git submodule update --init --recursive
