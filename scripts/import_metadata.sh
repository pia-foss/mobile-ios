#!/bin/sh
#
# USAGE
#
# ./import_metadata.sh (name|description|keywords|release_notes)
#
# EXAMPLE
#
# Enter "fastlane" directory
# Extract OneSky's .zip and move here as "keywords"
# Structure is like "keywords/<lang>.txt"
# Finally "../scripts/import_metadata.sh keywords"
#
# REQUIREMENTS
#
# The 'rename' utility
#

METADATA=$1

# XXX: convert some locales manually
( cd $METADATA; mv fr.txt fr-FR.txt; mv de.txt de-DE.txt; mv nb.txt no.txt ; mv nl.txt nl-NL.txt ; mv zh-CN.txt zh-Hans.txt ; mv zh-TW.txt zh-Hant.txt )

rename -f $2 "s/$METADATA\/(.*)\.txt/metadata\/\$1\/$METADATA.txt/" $METADATA/*.txt
rmdir $METADATA
