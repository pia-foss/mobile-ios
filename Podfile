source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

abstract_target 'PIALibrary' do
    pod 'SwiftyBeaver', '~> 1.4'
    pod 'Gloss', '~> 2'
    pod 'Alamofire', '~> 4'
    pod 'ReachabilitySwift'
     pod 'PIATunnel', :path => '/Users/ueshiba/Desktop/PIA/tunnel-apple'
    #pod 'PIATunnel', '~> 2.0.0'

    target 'PIALibrary-iOS' do
        platform :ios, '10.0'
    end
    target 'PIALibraryTests-iOS' do
        platform :ios, '10.0'
    end
    target 'PIALibraryHost-iOS' do
        platform :ios, '10.0'
    end

    #target 'PIALibrary-macOS' do
    #    platform :osx, '10.11'
    #end
    #target 'PIALibraryTests-macOS' do
    #    platform :osx, '10.11'
    #end
end
