#!/bin/sh

echo "Stripping arm64e from all frameworks..."

# Look in the built products directory
find "$CI_ARCHIVE_PATH" -name "*.framework" -type d | while read framework; do
    executable=$(basename "$framework" .framework)
    binary="$framework/$executable"
    
    if [ -f "$binary" ]; then
        if lipo -info "$binary" 2>/dev/null | grep -q "arm64e"; then
            echo "Removing arm64e from $binary"
            lipo "$binary" -remove arm64e -output "${binary}_new" 2>/dev/null && mv "${binary}_new" "$binary"
        fi
    fi
done

echo "arm64e stripping complete"