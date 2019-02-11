source "https://rubygems.org"

gem "fastlane"
gem "cocoapods", "1.5.3"
gem "dotenv"

#CI_HOSTNAME=`[[ $CI_PROJECT_URL =~ ^https:\/\/([^\/]+)\/.*$ ]] && echo ${BASH_REMATCH[1]}`
ci_project_url = ENV['CI_PROJECT_URL']
ENV['CI_HOSTNAME'] = ci_project_url.gsub(/^https:\/\/([^\/]+)\/.*$/, '\1') unless ci_project_url.nil?

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
