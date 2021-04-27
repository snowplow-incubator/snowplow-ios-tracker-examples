#!/usr/bin/env bash

# Wordaround needed as Xcode 10.3 doesn't work properly on macos-10.15 and Cocoapods.
# The env var `SDKROOT` indicate the SDK to use but apparently, if not correctly
# indicated, it will use the wrong SDK (MacOSX10.15.sdk) rather than the correct one
# (MacOSX10.14.sdk).
#
# The error fixed by this workaround is:
#
#   ld: unsupported tapi file type '!tapi-tbd' in YAML file 
#     '/Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/lib/libSystem.tbd'
#     for architecture x86_64
#   clang: error: linker command failed with exit code 1 (use -v to see invocation)

SDKROOT=$(xcrun --sdk macosx --show-sdk-path 2>/dev/null)
echo $SDKROOT
export SDKROOT
