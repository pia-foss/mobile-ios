require 'openssl'
require 'base64'
require 'json'
require 'net/http'
require 'uri'

key_id      = ENV['APP_STORE_CONNECT_KEY_ID']
issuer_id   = ENV['APP_STORE_CONNECT_ISSUER_ID']
key_content = ENV['APP_STORE_CONNECT_KEY']
asc_platform = ENV.fetch('ASC_PLATFORM', 'IOS')

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

  ver_res = asc_get("/v1/apps/#{app_id}/appStoreVersions?filter[platform]=#{asc_platform}&fields[appStoreVersions]=versionString,appStoreState&limit=1", jwt)
  attrs = JSON.parse(ver_res.body).dig('data', 0, 'attributes')
  raise 'Version not found' unless attrs

  version = attrs['versionString']
  state   = attrs['appStoreState']

  closed_states = %w[READY_FOR_SALE REPLACED_WITH_NEW_VERSION REMOVED_FROM_SALE DEVELOPER_REMOVED_FROM_SALE PENDING_DEVELOPER_RELEASE].freeze
  if closed_states.include?(state)
    major, minor, patch = version.split('.').map(&:to_i)
    version = "#{major}.#{minor}.#{patch + 1}"
  end

  puts version
rescue => e
  $stderr.puts "Error fetching version from App Store Connect: #{e.message}"
  exit 1
end
