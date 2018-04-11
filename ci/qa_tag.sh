#!/bin/sh
bundle exec fastlane push_build_tag prefix:"qa" branch:"develop" behind:$1
