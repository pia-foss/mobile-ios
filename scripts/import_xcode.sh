#!/bin/sh
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
ORIGINAL="PIA VPN/en.lproj/Localizable.strings"
ORIGINAL_PLIST="PIA VPN/en.lproj/InfoPlist.strings"
HERE=`dirname $0`

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

    #Update string file
    DST=${ORIGINAL/en.lproj/$LANG.lproj}
    echo "Writing to: $DST"
    $HERE/xliff2strings $SRC "$ORIGINAL" >$CWD/$DST

    #Update InfoPlist file
    DST=${ORIGINAL_PLIST/en.lproj/$LANG.lproj}
    echo "Writing to InfoPlist: $DST"
    $HERE/xliff2strings $SRC "$ORIGINAL_PLIST" >$CWD/$DST

done
