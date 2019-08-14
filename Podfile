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

$tunnel_pod = 'PIATunnel'
$tunnel_repo = 'tunnel-apple'

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

def tunnel_by_path(root)
    pod $tunnel_pod, :path => "#{root}/#{$tunnel_repo}"
end

def tunnel_by_git(sha)
    pod $tunnel_pod, :git => "#{$git_root}/#{$tunnel_repo}", :commit => sha
end

def tunnel_by_version(version)
    pod $tunnel_pod, version
end

# Pod groups

def shared_main_pods
    pod 'AlamofireImage'
    #library_by_path('')
    library_by_git('81a2f8e')
    #library_by_version('~> 1.1.3')
end

def app_pods
    shared_main_pods
    pod 'iRate'
    pod 'TPKeyboardAvoiding'
    pod 'SideMenu', '= 3.1.5'
    pod 'FXPageControl'
    pod 'DZNEmptyDataSet'
    pod 'PopupDialog'
end

def tunnel_pods
    #tunnel_by_path('')
    tunnel_by_git('8bc012a')
    #tunnel_by_version('~> 1.1.6')
end

# Targets

target 'PIA VPN' do
    app_pods
end

target 'PIA VPN dev' do
    app_pods
    #only use the following pods for internal (non-public) builds
    pod 'HockeySDK'
    pod 'Firebase/Core'
    pod 'Crashlytics'
    pod 'Fabric'
end

target 'PIA VPN Tunnel' do
    tunnel_pods
end

target 'PIA VPNTests' do
    app_pods
    pod 'HockeySDK'
    pod 'Firebase/Core'
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
        if ['SwiftEntryKit', 'QuickLayout', 'SideMenu'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end
