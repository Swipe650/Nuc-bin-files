#!/bin/bash
# Script to update linux-lts44 PKGBUILD and .SRCINFO
# Requires pkgbuild-introspection for mksrcinfo

set -eu

cd "$(dirname "$0")"

VERSION="$(curl -sSf https://www.kernel.org/releases.json | jq -r '.releases[].version' | grep '^4\.4\.')"
HASH="$(curl -sSf https://www.kernel.org/pub/linux/kernel/v4.x/sha256sums.asc | grep "patch-${VERSION}.xz" | cut -d' ' -f1)"

sed -i "s/pkgver=.*/pkgver=${VERSION}/" PKGBUILD
sed -i "s/.* # patch$/            '$HASH' # patch/" PKGBUILD
mksrcinfo 

