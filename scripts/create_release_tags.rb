# Tags the commit behind each App Store build that is Ready for Distribution and
# removes the RC tags it supersedes.
#
#   iOS / macOS -> <version>     (shared; whichever platform ships first creates it)
#                  deletes <version>-RC<n>
#   tvOS        -> <version>-tv
#                  deletes <version>-tv-RC<n>
#
# Set DRY_RUN=true to print the plan without touching origin.

require 'openssl'
require 'base64'
require 'json'
require 'net/http'
require 'uri'

BUNDLE_ID = 'com.privateinternetaccess.ios.PIA-VPN'.freeze
DRY_RUN = ENV['DRY_RUN'] == 'true'

PLATFORMS = [
  { label: 'iOS',   asc: 'IOS',    suffix: '',    shared: true },
  { label: 'macOS', asc: 'MAC_OS', suffix: '',    shared: true },
  { label: 'tvOS',  asc: 'TV_OS',  suffix: '-tv', shared: false }
].freeze

def jwt
  key_content = ENV.fetch('APP_STORE_CONNECT_KEY')
  key_content = key_content.gsub('\n', "\n").lines.map(&:strip).join("\n")
  key_content = Base64.decode64(key_content) unless key_content.include?('-----')
  key = OpenSSL::PKey.read(key_content)

  iat = Time.now.to_i
  header  = Base64.urlsafe_encode64({ alg: 'ES256', kid: ENV.fetch('APP_STORE_CONNECT_KEY_ID'), typ: 'JWT' }.to_json, padding: false)
  payload = Base64.urlsafe_encode64({ iss: ENV.fetch('APP_STORE_CONNECT_ISSUER_ID'), iat: iat, exp: iat + 1200, aud: 'appstoreconnect-v1' }.to_json, padding: false)

  signing_input = "#{header}.#{payload}"
  asn1 = OpenSSL::ASN1.decode(key.sign('SHA256', signing_input))
  r = asn1.value[0].value.to_s(2).rjust(32, "\x00").bytes.last(32).pack('C*')
  s = asn1.value[1].value.to_s(2).rjust(32, "\x00").bytes.last(32).pack('C*')
  "#{signing_input}.#{Base64.urlsafe_encode64(r + s, padding: false)}"
end

TOKEN = jwt

def asc_get(path_or_url)
  uri = URI(path_or_url.start_with?('http') ? path_or_url : "https://api.appstoreconnect.apple.com#{path_or_url}")
  req = Net::HTTP::Get.new(uri)
  req['Authorization'] = "Bearer #{TOKEN}"
  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
  raise "GET #{uri.path} failed with #{res.code}: #{res.body}" unless res.is_a?(Net::HTTPSuccess)
  JSON.parse(res.body)
end

def warn_gh(message)
  puts "::warning::#{message}"
end

def error_gh(message)
  puts "::error::#{message}"
end

def ready_version(app_id, asc_platform)
  res = asc_get("/v1/apps/#{app_id}/appStoreVersions?filter[platform]=#{asc_platform}" \
                '&filter[appVersionState]=READY_FOR_DISTRIBUTION&include=build&limit=1')
  data = res['data']&.first
  return nil unless data

  { version: data.dig('attributes', 'versionString'), build_id: data.dig('relationships', 'build', 'data', 'id') }
end

# Xcode Cloud sets the build number to the run number, so look up that run and
# confirm it really produced this build. Old runs expire from Xcode Cloud.
def commit_for_build(ci_product_id, build_id)
  build_number = asc_get("/v1/builds/#{build_id}?fields[builds]=version").dig('data', 'attributes', 'version').to_i
  url = "/v1/ciProducts/#{ci_product_id}/buildRuns?sort=-number&fields[ciBuildRuns]=sourceCommit,number&limit=200"
  while url
    page = asc_get(url)
    run = page['data'].find { |r| r.dig('attributes', 'number') == build_number }
    if run
      builds = asc_get("/v1/ciBuildRuns/#{run['id']}/builds?fields[builds]=version")['data']
      return nil unless builds.any? { |b| b['id'] == build_id }

      return run.dig('attributes', 'sourceCommit', 'commitSha')
    end
    break if page['data'].empty? || page['data'].last.dig('attributes', 'number') < build_number

    url = page.dig('links', 'next')
  end
  nil
end

def remote_tags
  `git ls-remote --tags origin`.lines.each_with_object({}) do |line, tags|
    sha, ref = line.split
    name = ref.delete_prefix('refs/tags/')
    if name.end_with?('^{}')
      tags[name.delete_suffix('^{}')] = sha
    else
      tags[name] ||= sha
    end
  end
end

def run_git(*args)
  puts "$ git #{args.join(' ')}"
  return if DRY_RUN

  system('git', *args) or raise "git #{args.join(' ')} failed"
end

app_id = asc_get("/v1/apps?filter[bundleId]=#{BUNDLE_ID}&fields[apps]=bundleId").dig('data', 0, 'id') or raise 'App not found'
ci_product_id = asc_get("/v1/apps/#{app_id}/ciProduct").dig('data', 'id') or raise 'Xcode Cloud product not found'
tags = remote_tags
failed = false

puts '🧪 Dry run, nothing will be pushed' if DRY_RUN

PLATFORMS.each do |platform|
  label = platform[:label]
  puts "\n== #{label}"

  ready = ready_version(app_id, platform[:asc])
  unless ready && ready[:build_id]
    warn_gh("#{label}: no version Ready for Distribution with a build")
    next
  end

  tag = "#{ready[:version]}#{platform[:suffix]}"
  sha = commit_for_build(ci_product_id, ready[:build_id])
  if sha.nil? && tags[tag]
    puts "#{tag} already exists; its Xcode Cloud run has expired so it can't be verified"
    next
  end
  unless sha
    error_gh("#{label} #{ready[:version]}: could not find the Xcode Cloud run for build #{ready[:build_id]}")
    failed = true
    next
  end
  puts "#{label} #{ready[:version]} was built from #{sha}"

  if tags[tag].nil?
    unless system('git', 'cat-file', '-e', "#{sha}^{commit}", err: File::NULL)
      error_gh("#{label}: commit #{sha} is not in the repository")
      failed = true
      next
    end
    run_git('push', 'origin', "#{sha}:refs/tags/#{tag}")
    tags[tag] = sha
    puts "✅ Created #{tag}"
  elsif tags[tag] == sha
    puts "#{tag} already points at #{sha}"
  elsif platform[:shared]
    warn_gh("#{label}: #{tag} already exists at #{tags[tag]}, but #{label} was built from #{sha}. Keeping the existing tag.")
  else
    error_gh("#{label}: #{tag} already exists at #{tags[tag]}, but #{label} was built from #{sha}. Fix it manually.")
    failed = true
    next
  end

  rc_pattern = /\A#{Regexp.escape(tag)}-RC\d+\z/
  rc_tags = tags.keys.grep(rc_pattern).sort
  next if rc_tags.empty?

  run_git('push', 'origin', '--delete', *rc_tags.map { |t| "refs/tags/#{t}" })
  rc_tags.each { |t| tags.delete(t) }
  puts "🗑️ Deleted #{rc_tags.join(', ')}"
end

exit(failed ? 1 : 0)
