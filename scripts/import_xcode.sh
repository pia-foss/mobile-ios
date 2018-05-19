#!/bin/sh
#
# Copyright (c) 2018 Davide De Rosa. All rights reserved.
#
# USAGE
#
# ./import_xcode.sh (directory)
#
# EXAMPLE
#
# Extract OneSky's .zip and move here as "directory"
# Finally "./import_xcode.sh directory"
#

CWD=`pwd`
DIR=$1
HERE=`dirname $0`
TMP_ORIGS="original.tmp"

rm -f en-US.xliff
for SRC in `ls $DIR/*.xliff`; do
    #xcodebuild -importLocalizations -localizationPath $FILE -project "PIA VPN.xcodeproj"
    SRC_NAME=`basename $SRC`
    LANG=${SRC_NAME%.xliff}
    if [ $LANG == "zh-CN" ]; then
        LANG="zh-Hans"
    elif [ $LANG == 'zh-TW' ]; then
        LANG="zh-Hant"
    fi

    # pick paths from xliff
    #ORIGS_DEL=`sed "s/<xliff.*/<xliff>/g" $SRC | xml sel -t -v "//file/@original"`
    #IFS=$'\n' read -r -a ORIGS <<< "$ORIGS_DEL"

    sed "s/<xliff.*/<xliff>/g" $SRC | xml sel -t -v "//file/@original" >$TMP_ORIGS
    while read ORIGINAL; do
        DST=${ORIGINAL/en.lproj/$LANG.lproj}
        echo "Writing to: $DST"
        $HERE/xliff2strings $SRC "$ORIGINAL" >$CWD/$DST
    done <$TMP_ORIGS
done
rm $TMP_ORIGS
