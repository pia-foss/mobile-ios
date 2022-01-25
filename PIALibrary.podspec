Pod::Spec.new do |s|
    s.name              = "PIALibrary"
    s.version           = "2.13.0"
    s.summary           = "PIA client library in Swift."

    s.homepage          = "https://www.privateinternetaccess.com/"
    s.license           = { :type => "MIT", :file => "LICENSE" }
    s.author            = { "Jose Blaya" => "joseblaya@londontrustmedia.com", "Davide De Rosa" => "" }
    s.source            = { :git => "https://github.com/pia-foss/client-library-apple.git", :tag => "v#{s.version}" }

    s.ios.deployment_target = "12.0"
    #s.osx.deployment_target = "10.11"

    s.default_subspecs = "Core", "Library"

    s.subspec "Core" do |p|
        p.source_files          = "PIALibrary/Sources/Core/**/*.swift"
        #p.osx.exclude_files     = "PIALibrary/Sources/Core/InApp",
        #                          "PIALibrary/Sources/Core/Account/InApp"
        p.dependency "PIAAccountModule"

    end

    s.subspec "Library" do |p|
        p.source_files          = "PIALibrary/Sources/Library/**/*.swift"
        #p.osx.exclude_files     = "PIALibrary/Sources/Library/InApp"
        p.resources             = "PIALibrary/Resources/Staging/**/*"
        p.ios.frameworks        = "UIKit"
        #p.osx.frameworks        = "Cocoa"
        p.dependency "PIALibrary/Core"
        p.dependency "PIALibrary/Util"
        p.dependency "Gloss", "~> 2"
        p.dependency "Alamofire", "~> 4"
        p.dependency "ReachabilitySwift"
        p.dependency "SwiftyBeaver"
        p.dependency "PopupDialog"
        p.dependency "PIARegionsModule"
        p.dependency "PIAAccountModule"
        p.dependency "PIACSIModule"
        p.dependency "PIAKPIModule"
        
    end

    s.subspec "VPN" do |p|
        p.source_files          = "PIALibrary/Sources/VPN/*.swift"
        p.frameworks            = "NetworkExtension"
        p.pod_target_xcconfig   = { "APPLICATION_EXTENSION_API_ONLY" => "YES" }

        p.dependency "TunnelKit"
        p.dependency "PIAWireguard"
        p.dependency "PIALibrary/Library"
    end

    s.subspec "Lottie" do |p|
        p.dependency "PIALibrary/Core"
        p.dependency "PIALibrary/Util"
    end

    s.subspec "UI" do |p|
        p.source_files          = "PIALibrary/Sources/UI/Shared/*.swift"
        p.resources             = "PIALibrary/Resources/UI/Shared/**/*"
        p.dependency "PIALibrary/Library"
        p.dependency "SwiftyBeaver"
        p.dependency "SwiftEntryKit", "0.7.2"
        p.dependency "lottie-ios"
        p.dependency "FXPageControl"


        p.ios.source_files      = "PIALibrary/Sources/UI/iOS/**/*.swift"
        p.ios.resources         = "PIALibrary/Resources/UI/iOS/**/*"
        p.ios.dependency "TPKeyboardAvoiding"

        #p.osx.source_files      = "PIALibrary/Sources/UI/macOS/*.swift"
        #p.osx.resources         = "PIALibrary/Resources/UI/macOS/**/*"
    end

    s.subspec "Mock" do |p|
        p.source_files          = "PIALibrary/Sources/Mock/*.swift"
        p.dependency "PIALibrary/Library"
    end

    s.subspec "Util" do |p|
        p.source_files              = "PIALibrary/Sources/Util/*.{h,m,swift}"
        p.private_header_files      = "PIALibrary/Sources/Util/*.h"
        p.ios.source_files          = "PIALibrary/Sources/Util/iOS/*.{h,m,swift}"
        p.ios.private_header_files  = "PIALibrary/Sources/Util/iOS/*.h"
        p.ios.preserve_paths        = "PIALibrary/Sources/Util/iOS/*.modulemap"
        p.ios.pod_target_xcconfig   = { "SWIFT_INCLUDE_PATHS" => "${PODS_TARGET_SRCROOT}/PIALibrary/Sources/Util/iOS" }
        #p.osx.source_files          = "PIALibrary/Sources/Util/macOS/*.{h,m,swift}"
        #p.osx.private_header_files  = "PIALibrary/Sources/Util/macOS/*.h"
        #p.osx.preserve_paths        = "PIALibrary/Sources/Util/macOS/*.modulemap"
        #p.osx.pod_target_xcconfig   = { "SWIFT_INCLUDE_PATHS" => "${PODS_TARGET_SRCROOT}/PIALibrary/Sources/Util/macOS" }
        p.dependency "PIALibrary/Core"
    end
end
