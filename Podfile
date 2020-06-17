source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

abstract_target 'PIALibrary' do
    pod 'SwiftyBeaver', '~> 1.7.0'
    pod 'Gloss', '~> 2'
    pod 'Alamofire', '~> 4'
    pod 'ReachabilitySwift'
    pod 'SwiftEntryKit', '0.7.2'
    pod 'lottie-ios'
    pod 'FXPageControl'
    pod 'PopupDialog'
    pod 'TunnelKit', :git => 'https://github.com/pia-foss/tunnelkit', :commit => 'd19b9de'
    pod 'PIAWireguard', :git => "https://github.com/pia-foss/ios-wireguard", :commit => '1585891'
    pod 'PIARegions', :path => "/Users/ueshiba/Projects/PIA/regions"

    target 'PIALibrary-iOS' do
        platform :ios, '11.0'
    end
    target 'PIALibraryTests-iOS' do
        platform :ios, '11.0'
    end
    target 'PIALibraryHost-iOS' do
        platform :ios, '11.0'
    end

    #target 'PIALibrary-macOS' do
    #    platform :osx, '10.11'
    #end
    #target 'PIALibraryTests-macOS' do
    #    platform :osx, '10.11'
    #end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['PopupDialog'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.2'
            end
        end
        if ['SwiftEntryKit', 'QuickLayout'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end
