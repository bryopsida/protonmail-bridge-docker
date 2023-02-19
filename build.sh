#!/bin/bash
set -ex

# Clone new code
git clone https://github.com/ProtonMail/proton-bridge.git
cd proton-bridge

# Build
make build-nogui
