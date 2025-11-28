#!/usr/bin/env bash

pushd "${0%/*}/.." &>/dev/null
source tools/tools.sh

require cpio

if [ $# -eq 0 ]; then
  echo "Usage: $0 <xcode.xip>" 1>&2
  exit 1
fi

XCODE=$(make_absolute_path $1 $(get_exec_dir))

mkdir -p $BUILD_DIR
pushd $BUILD_DIR &>/dev/null

build_xar
build_pbxz

create_tmp_dir

pushd $TMP_DIR &>/dev/null

echo "Extracting $XCODE (this may take several minutes) ..."

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TARGET_DIR/lib \
  verbose_cmd "xar -xf $XCODE -C $TMP_DIR"

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TARGET_DIR/lib \
  verbose_cmd "pbzx -n Content | cpio -i"

popd &>/dev/null # TMP_DIR
popd &>/dev/null # BUILD_DIR

echo ""

XCODEDIR=$TMP_DIR/Xcode.app \
  ./tools/gen_sdk_package.sh
