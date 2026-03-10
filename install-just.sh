#!/usr/bin/env bash

mkdir -p external
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to external/
