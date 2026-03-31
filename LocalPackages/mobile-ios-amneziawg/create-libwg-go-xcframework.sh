#!/usr/bin/env bash

set -euo pipefail

if [ ! -d lib ]; then
    echo "Please run the project first!"
    exit 1
fi

FWNAME=PIAWireguardGo
FWROOT=frameworks

if [ -d $FWROOT ]; then
    echo "Removing previous $FWNAME.xcframework copies"
    rm -rf $FWROOT
fi

function check_bitcode() {
    local FWDIR=$1

    BITCODE_PATTERN="__bitcode"

    if otool -l "$FWDIR/$FWNAME" | grep "${BITCODE_PATTERN}" >/dev/null; then
        echo "INFO: $FWDIR contains Bitcode"
    else
        echo "INFO: $FWDIR doesn't contain Bitcode"
    fi
}


FWDIR="$FWROOT/$FWNAME.xcframework"
SIMULATOR="lib/iphonesimulator"
IPHONE="lib/iphoneos"
xcodebuild -create-xcframework \
-library $IPHONE/$FWNAME.a \
-headers $IPHONE/include \
-library $SIMULATOR/$FWNAME.a \
-headers $SIMULATOR/include \
-output $FWDIR

