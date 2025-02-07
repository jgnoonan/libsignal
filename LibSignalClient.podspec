#
# Copyright 2020-2022 Signal Messenger, LLC.
# SPDX-License-Identifier: AGPL-3.0-only
#

Pod::Spec.new do |s|
  s.name             = 'LibSignalClient'
  s.version          = '0.65.0'
  s.summary          = 'A Swift wrapper library for communicating with the Signal messaging service.'

  s.homepage         = 'https://github.com/signalapp/libsignal'
  s.license          = 'AGPL-3.0-only'
  s.author           = 'Signal Messenger LLC'
  s.source           = { :git => 'https://github.com/signalapp/libsignal.git', :tag => "v#{s.version}" }

  s.swift_version    = '5'
  s.platform         = :ios, '13.0'

  s.source_files = ['swift/Sources/**/*.swift', 'swift/Sources/**/*.m']
  s.preserve_paths = [
    'swift/Sources/SignalFfi',
    'bin/fetch_archive.py',
    'acknowledgments/acknowledgments.plist',
  ]

  s.pod_target_xcconfig = {
      'HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/swift/Sources/SignalFfi',
      # Duplicate this here to make sure the search path is passed on to Swift dependencies.
      'SWIFT_INCLUDE_PATHS' => '$(HEADER_SEARCH_PATHS)',

      'LIBSIGNAL_FFI_BUILD_PATH' => 'target/$(CARGO_BUILD_TARGET)/release',
      # Store libsignal_ffi.a builds in a project-wide directory
      # because we keep simulator and device builds next to each other.
      'LIBSIGNAL_FFI_TEMP_DIR' => '/Users/jgnoonan/Signal-iOS/libsignal_temp/libsignal_ffi',
      'LIBSIGNAL_FFI_LIB_TO_LINK' => '$(LIBSIGNAL_FFI_TEMP_DIR)/$(LIBSIGNAL_FFI_BUILD_PATH)/libsignal_ffi.a',

      # Make sure we link the static library, not a dynamic one.
      'OTHER_LDFLAGS' => '$(LIBSIGNAL_FFI_LIB_TO_LINK)',

      'CARGO_BUILD_TARGET[sdk=iphonesimulator*][arch=arm64]' => 'aarch64-apple-ios-sim',
      'CARGO_BUILD_TARGET[sdk=iphonesimulator*][arch=*]' => 'x86_64-apple-ios',
      'CARGO_BUILD_TARGET[sdk=iphoneos*]' => 'aarch64-apple-ios',
      # Presently, there's no special SDK or arch for maccatalyst,
      # so we need to hackily use the "IS_MACCATALYST" build flag
      # to set the appropriate cargo target
      'CARGO_BUILD_TARGET_MAC_CATALYST_ARM_' => 'aarch64-apple-darwin',
      'CARGO_BUILD_TARGET_MAC_CATALYST_ARM_YES' => 'aarch64-apple-ios-macabi',
      'CARGO_BUILD_TARGET[sdk=macosx*][arch=arm64]' => '$(CARGO_BUILD_TARGET_MAC_CATALYST_ARM_$(IS_MACCATALYST))',
      'CARGO_BUILD_TARGET_MAC_CATALYST_X86_' => 'x86_64-apple-darwin',
      'CARGO_BUILD_TARGET_MAC_CATALYST_X86_YES' => 'x86_64-apple-ios-macabi',
      'CARGO_BUILD_TARGET[sdk=macosx*][arch=*]' => '$(CARGO_BUILD_TARGET_MAC_CATALYST_X86_$(IS_MACCATALYST))',

      'ARCHS[sdk=iphonesimulator*]' => 'x86_64 arm64',
      'ARCHS[sdk=iphoneos*]' => 'arm64',
  }

  s.script_phases = [
    { name: 'Extract libsignal-ffi prebuild',
      execution_position: :before_compile,
      script: %q(
        set -euo pipefail
        rm -rf "${LIBSIGNAL_FFI_TEMP_DIR}"
        if [ -e "${PODS_TARGET_SRCROOT}/swift/build_ffi.sh" ]; then
          # Local development
          ln -fns "${PODS_TARGET_SRCROOT}" "${LIBSIGNAL_FFI_TEMP_DIR}"
        else
          echo 'Using locally built libsignal_ffi.a files.'
        fi
      ),
    }
  ]

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'swift/Tests/*/*.swift'
    test_spec.preserve_paths = [
      'swift/Tests/*/Resources',
    ]
    test_spec.pod_target_xcconfig = {
      # Don't also link into the test target.
      'LIBSIGNAL_FFI_LIB_TO_LINK' => '',
    }

    # Ideally we'd do this at run time, not configuration time, but CocoaPods doesn't make that easy.
    # This is good enough.
    test_spec.scheme = {
      environment_variables: ENV.select { |name, value| name.start_with?('LIBSIGNAL_TESTING_') }
    }
  end
end

