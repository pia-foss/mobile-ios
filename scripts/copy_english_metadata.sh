#!/bin/sh
#
# USAGE
#
# ./copy_english_metadata.sh (name|description|keywords|release_notes)
#
# EXAMPLE
#
# scripts/copy_english_metadata.sh release_notes
#

RX='^[a-z]{2}(\-[A-z]+)?$'
cd fastlane/metadata
for LANG in `ls -d *`; do
    if [[ $LANG == "en-US" ]]; then
        continue
    fi
    if [[ ! $LANG =~ $RX ]]; then
        continue
    fi
    #echo $LANG
    cp en-US/$1.txt $LANG
done
