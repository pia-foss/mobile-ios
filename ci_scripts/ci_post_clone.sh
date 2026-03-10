#!/bin/sh -e

get_version_from_app_store() {
    if [ -z "$APP_STORE_CONNECT_KEY_ID" ] || [ -z "$APP_STORE_CONNECT_ISSUER_ID" ] || [ -z "$APP_STORE_CONNECT_KEY" ]; then
        echo "App Store Connect credentials not set." >&2
        return 1
    fi

    ruby << 'RUBY'
require 'openssl'
require 'base64'
require 'json'
require 'net/http'
require 'uri'

key_id    = ENV['APP_STORE_CONNECT_KEY_ID']
issuer_id = ENV['APP_STORE_CONNECT_ISSUER_ID']
key_content = ENV['APP_STORE_CONNECT_KEY']

begin
  # Support both raw PEM and base64-encoded key (for environments that don't allow multiline values)
  key_content = key_content.gsub('\n', "\n").lines.map(&:strip).join("\n")
  unless key_content.include?('-----')
    key_content = Base64.decode64(key_content)
  end
  key = OpenSSL::PKey.read(key_content)

  iat = Time.now.to_i
  exp = iat + 1200

  header  = Base64.urlsafe_encode64({ alg: 'ES256', kid: key_id, typ: 'JWT' }.to_json, padding: false)
  payload = Base64.urlsafe_encode64({ iss: issuer_id, iat: iat, exp: exp, aud: 'appstoreconnect-v1' }.to_json, padding: false)

  signing_input = "#{header}.#{payload}"
  asn1_sig = key.sign('SHA256', signing_input)

  asn1 = OpenSSL::ASN1.decode(asn1_sig)
  r = asn1.value[0].value.to_s(2).rjust(32, "\x00").bytes.last(32).pack('C*')
  s = asn1.value[1].value.to_s(2).rjust(32, "\x00").bytes.last(32).pack('C*')
  jwt = "#{signing_input}.#{Base64.urlsafe_encode64(r + s, padding: false)}"

  def asc_get(path, jwt)
    uri = URI("https://api.appstoreconnect.apple.com#{path}")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{jwt}"
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
  end

  apps_res = asc_get('/v1/apps?filter[bundleId]=com.privateinternetaccess.ios.PIA-VPN&fields[apps]=bundleId', jwt)
  app_id = JSON.parse(apps_res.body).dig('data', 0, 'id')
  raise 'App not found' unless app_id

  ver_res = asc_get("/v1/apps/#{app_id}/appStoreVersions?filter[platform]=IOS&fields[appStoreVersions]=versionString,appStoreState&limit=1", jwt)
  attrs = JSON.parse(ver_res.body).dig('data', 0, 'attributes')
  raise 'Version not found' unless attrs

  version = attrs['versionString']
  state   = attrs['appStoreState']

  closed_states = %w[READY_FOR_SALE REPLACED_WITH_NEW_VERSION REMOVED_FROM_SALE DEVELOPER_REMOVED_FROM_SALE]
  if closed_states.include?(state)
    major, minor, patch = version.split('.').map(&:to_i)
    version = "#{major}.#{minor}.#{patch + 1}"
  end

  puts version
rescue => e
  $stderr.puts "Error fetching version from App Store Connect: #{e.message}"
  exit 1
end
RUBY
}

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
    # Retrieve the version from the latest App Store release.
    # This should only be used in manual XCC runs for testing.
    echo "CI_TAG not set. Attempting to fetch version from App Store Connect..."
    if version_number=$(get_version_from_app_store); then
        echo "Version '$version_number' from App Store Connect"
    else
        echo "App Store Connect lookup failed. Falling back to git tags."
        version_number=$(git describe --tags --abbrev=0 | sed -E 's/([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)-.*/\1/g')
        echo "Version '$version_number' from git tag parents"
    fi
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