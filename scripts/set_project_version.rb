#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Updates version build settings in the Xcode project.
#
# This project uses Xcode's JSON project format (project.xcproj). Apple's
# `agvtool` - which fastlane's `increment_build_number` shells out to - only
# understands the legacy `project.pbxproj`, so it silently does nothing here.
# This script edits the version settings in `project.xcproj` directly.
#
# It is used by the fastlane lanes (fastlane/Fastfile) and by Xcode Cloud
# (ci_scripts/ci_post_clone.sh).
#
# Usage:
#   scripts/set_project_version.rb --build 123
#   scripts/set_project_version.rb --marketing 11.89.0
#   scripts/set_project_version.rb --build 123 --marketing 11.89.0
#   scripts/set_project_version.rb --build 123 --project "PIA VPN.xcodeproj"

require "optparse"

PROJECT_DIR = File.expand_path("../PIA VPN.xcodeproj", __dir__)

# Option name => build setting name.
SETTINGS = {
  build: "CURRENT_PROJECT_VERSION",
  marketing: "MARKETING_VERSION"
}.freeze

options = { project: PROJECT_DIR }

OptionParser.new do |parser|
  parser.banner = "Usage: set_project_version.rb [--build NUMBER] [--marketing VERSION] [--project PATH]"
  parser.on("--build NUMBER", "Set CURRENT_PROJECT_VERSION (the build number)") { |value| options[:build] = value }
  parser.on("--marketing VERSION", "Set MARKETING_VERSION (the short version)") { |value| options[:marketing] = value }
  parser.on("--project PATH", "Path to the .xcodeproj bundle") { |value| options[:project] = value }
  parser.on("-h", "--help") do
    puts parser
    exit 0
  end
end.parse!

if options[:build].nil? && options[:marketing].nil?
  warn "Nothing to do: pass --build and/or --marketing."
  exit 1
end

project_file = File.join(options[:project], "project.xcproj")
unless File.file?(project_file)
  warn "Could not find #{project_file}. Is the project stored in the JSON (.xcproj) format?"
  exit 1
end

content = File.read(project_file)
updated = content.dup

SETTINGS.each do |option, setting|
  value = options[option]
  next if value.nil?

  # Matches plain and conditional keys, leaving the surrounding JSON5
  # (trailing commas and all) untouched:
  #   "CURRENT_PROJECT_VERSION": "1",
  #   "CURRENT_PROJECT_VERSION[sdk=iphoneos*]": "1",
  pattern = /("(?:#{Regexp.escape(setting)})(?:\s*\[[^\]]*\])?"\s*:\s*)"[^"]*"/

  unless updated.match?(pattern)
    warn "No #{setting} setting found in #{project_file}."
    exit 1
  end

  updated = updated.gsub(pattern) { "#{Regexp.last_match(1)}\"#{value}\"" }
end

if updated == content
  puts "No changes needed in #{project_file}."
else
  File.write(project_file, updated)
  summary = SETTINGS.map { |option, setting| "#{setting}=#{options[option]}" if options[option] }.compact.join(", ")
  puts "Updated #{summary} in #{project_file}."
end
