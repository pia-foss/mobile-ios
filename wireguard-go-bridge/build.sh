#!/usr/bin/env bash

set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$ROOT"

LBAME=PIAWireguardGo
BUILD_ROOT="$ROOT/out/build"
LIBRARY_OUTPUT_ROOT="$BUILD_ROOT/lib"
ARTIFACTS_ROOT="../lib"

rm -rf "$BUILD_ROOT" "$ARTIFACTS_ROOT"
mkdir -p "$BUILD_ROOT"

# Create a patched goroot using patches needed for iOS
GOROOT="$BUILD_ROOT/goroot/" # Not exported yet, still need the original GOROOT to copy
mkdir -p "$GOROOT"
rsync --exclude="pkg/obj/go-build" -a "$(go env GOROOT)/" "$GOROOT/"
export GOROOT
cat goruntime-*.diff | patch -p1 -fN -r- -d "$GOROOT"

BUILD_CFLAGS="-fembed-bitcode -Wno-unused-command-line-argument"

# Build the library for each target
function build_arch() {
    local ARCH="$1"
    local GOARCH="$2"
    local SDKNAME="$3"
    # Find the SDK path
    local SDKPATH
    SDKPATH="$(xcrun --sdk "$SDKNAME" --show-sdk-path)"
    local FULL_CFLAGS="$BUILD_CFLAGS -isysroot $SDKPATH -arch $ARCH"
    SDK_LIBRARY_OUTPUT="$LIBRARY_OUTPUT_ROOT/$SDKNAME"
    mkdir -p $SDK_LIBRARY_OUTPUT/include
    CGO_ENABLED=1 CGO_CFLAGS="$FULL_CFLAGS" CGO_LDFLAGS="$FULL_CFLAGS" GOOS=darwin GOARCH="$GOARCH" \
        go build -tags ios -ldflags=-w -trimpath -v -o "$SDK_LIBRARY_OUTPUT/$LBAME-$ARCH.a" -buildmode c-archive
    mv $SDK_LIBRARY_OUTPUT/*.h $SDK_LIBRARY_OUTPUT/include
    LIPO="${LIPO:-lipo}"
   "$LIPO" -create -output "$SDK_LIBRARY_OUTPUT/$LBAME.a" $SDK_LIBRARY_OUTPUT/*.a
    rm "$SDK_LIBRARY_OUTPUT/$LBAME-$ARCH.a"
}


build_arch x86_64 amd64 iphonesimulator
build_arch arm64 arm64 iphoneos
build_arch arm64 arm64 iphonesimulator

# Copy artifacts
mkdir -p $ARTIFACTS_ROOT
cp -r $LIBRARY_OUTPUT_ROOT/* "$ARTIFACTS_ROOT"

