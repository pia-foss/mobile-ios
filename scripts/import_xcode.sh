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

DIR=$1

rm -f $DIR/en-US.xliff
for FILE in `ls $DIR/*.xliff`; do
    xcodebuild -importLocalizations -localizationPath $FILE -project "PIALibrary.xcodeproj"
done
