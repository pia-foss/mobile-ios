#!/bin/sh
bundle exec fastlane push_build_tag prefix:"beta" branch:"master" behind:$1
