source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

abstract_target 'PIALibrary' do
    pod 'SwiftyBeaver', '~> 1.4'
    pod 'Gloss', '~> 2'
    pod 'Alamofire', '~> 4'
    pod 'ReachabilitySwift'
    pod 'SwiftEntryKit', '0.7.2'
    pod 'lottie-ios'
    pod 'PopupDialog'
    pod 'PIATunnel', :path => '/Users/ueshiba/Desktop/PIA/tunnel-apple'
    #pod 'PIATunnel', '~> 1.1.7'

    target 'PIALibrary-iOS' do
        platform :ios, '9.0'
    end
    target 'PIALibraryTests-iOS' do
        platform :ios, '9.0'
    end
    target 'PIALibraryHost-iOS' do
        platform :ios, '9.0'
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
    end
end
