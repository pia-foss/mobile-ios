source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

# Libraries

$git_root = "https://github.com/pia-foss"

$library_pod = 'PIALibrary'
$library_repo = 'client-library-apple'
$library_subspecs = [
    'Library',
    'UI',
    'Mock',
    'VPN'
]

$regions_repo = 'mobile-common-regions'


def library_by_path(root)
    $library_subspecs.each { |name|
        pod "#{$library_pod}/#{name}", :path => "#{root}/#{$library_repo}"
    }
end

def library_by_git(sha)
    $library_subspecs.each { |name|
        pod "#{$library_pod}/#{name}", :git => "#{$git_root}/#{$library_repo}", :commit => sha
    }
end

def library_by_version(version)
    $library_subspecs.each { |name|
        pod "#{$library_pod}/#{name}", version
    }
end

# Pod groups

def shared_main_pods
    pod 'AlamofireImage'
    pod "PIARegions", :git => "#{$git_root}/#{$regions_repo}"
    library_by_path('/Users/jose/Projects/PIA')
    #library_by_git('7075984')
    #library_by_version('~> 1.1.3')
end

def app_pods
    shared_main_pods
    pod 'TPKeyboardAvoiding'
    pod 'SideMenu', '6.1.3'
    pod 'DZNEmptyDataSet'
    pod 'PopupDialog'
    pod 'ReachabilitySwift', '~> 4.3.0'
    pod 'GradientProgressBar', '~> 2.0'
end

def tunnel_pods
    pod 'TunnelKit', :git => 'https://github.com/pia-foss/tunnelkit', :commit => 'd19b9de'
end

def piawireguard_pod
    pod 'PIAWireguard', :path => "/Users/jose/Projects/PIA/PIAWireguard"
end

# Targets

target 'PIA VPN' do
    app_pods
end

target 'PIA VPN dev' do
    app_pods
    #only use the following pods for internal (non-public) builds
    pod 'AppCenter'
    pod 'Firebase/Core', '6.5.0'
    pod 'Crashlytics'
    pod 'Fabric'
end

target 'PIA VPN Tunnel' do
    tunnel_pods
end

target 'PIA VPN WG Tunnel' do
    piawireguard_pod
end


target 'PIA VPNTests' do
    app_pods
    pod 'AppCenter'
    pod 'Firebase/Core', '6.5.0'
    pod 'Crashlytics'
    pod 'Fabric'
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
