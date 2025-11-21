#!/bin/sh -e

setVariableValue() {
    variable="$1"
    value="$2"
    file="$3"
    # We cannot set a value if it is not present. And we cannot add it if it is present. 
    # So we try to set it and add it if that fails
    output=$(/usr/libexec/PlistBuddy -c "Set $variable $value" "$file" 2>&1) || \
    output=$(/usr/libexec/PlistBuddy -c "Add $variable string $value" "$file" 2>&1)
    error=$?
    if [ $error -ne 0 ]
    then
        echo "Updating versions in $plist_file failed with output"
        echo "$output"
    fi
    return $error
}

cd ..

# Xcode cloud does a shallow copy of the repository. 
# We need a full copy to describe the tag history and get the version.
if [ -d ".git" ] && [ -f "$(git rev-parse --git-dir)/shallow" ]; then
    git fetch --unshallow
fi

if [ -n "$CI_TAG" ]
then
    # Retrieve the version from the tag that started the build.
    # The commit tag is used to start the workflow from the automation, and it's
    # more reliable than parsing git tags that are modified during release.
    # Examples:
    #   v11.89.0-rc -> 11.89.0
    #   v11.91.0-dogfood-1 -> 11.91.0
    version_number=$(echo $CI_TAG | sed -E 's/([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)-.*/\1/g')
    echo "Version '$version_number' from environment variable CI_TAG: '$CI_TAG'"
else
    # Retrieve the version from git tags parents for this commit.
    # This should only be used in manual XCC runs for testing.
    version_number=$(git describe --tags --abbrev=0 | sed -E 's/([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)-.*/\1/g')
    echo "Version '$version_number' from git tag parents"
fi

if [ -z "$version_number" ]; then
    echo "Could not extract a version number. Exiting."
    exit 1
fi

echo "Updating version in the project and Info.plist files..."

# We need to set the marketing version for the project and all dependencies.
xcrun agvtool new-marketing-version "$version_number"

# As some dependencies are not reachable from the project definition, we manually update Info.plist files
find "PIA VPN" "PIA VPN-tvOS" "PIA tvOS Tunnel" "PIA VPN AdBlocker" "PIA VPN Tunnel" "PIA VPN WG Tunnel" "PIAWidget" "PIA VPNTests" "PIA VPN-tvOSTests" "PIA VPNUITests" -name '*Info.plist' | \
while read -r plist_file
do
    setVariableValue "CFBundleShortVersionString" "$version_number" "$plist_file"
done

echo "Updated Info.plist files to version $version_number"