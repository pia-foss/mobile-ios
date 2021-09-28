source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

install! 'cocoapods',
         :deterministic_uuids => false,
         :disable_input_output_paths => true #fix dSym issue https://github.com/CocoaPods/CocoaPods/issues/9185


# ignore all warnings from all pods
inhibit_all_warnings!

# Libraries

$git_root = "https://github.com/pia-foss"
$gitlab_vpn_root = "git@gitlab.kape.com:pia-mobile/ios"
$gitlab_kn_root = "git@gitlab.kape.com:pia-mobile/shared"

$library_pod = 'PIALibrary'
$library_repo = 'client-library-apple'
$library_gitlab_repo = 'client-library-apple.git'
$library_subspecs = [
    'Library',
    'UI',
    'Mock',
    'VPN'
]

$regions_repo = 'mobile-common-regions'
$accounts_repo = 'mobile-common-account'
$csi_repo = 'mobile-common-csi'

$regions_gitlab_repo = 'regions.git'
$accounts_gitlab_repo = 'account.git'
$csi_gitlab_repo = 'csi.git'
$kpi_gitlab_repo = 'kpi.git'

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

def library_by_gitlab_branch(branch)
    $library_subspecs.each { |name|
        pod "#{$library_pod}/#{name}", :git => "#{$gitlab_vpn_root}/#{$library_gitlab_repo}", :branch => branch
    }
end

def library_by_gitlab_by_git(sha)
    $library_subspecs.each { |name|
        pod "#{$library_pod}/#{name}", :git => "#{$gitlab_vpn_root}/#{$library_gitlab_repo}", :commit => sha
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
    
    #pod "PIAAccountModule", :git => "#{$git_root}/#{$accounts_repo}"
    pod "PIAAccountModule", :git => "#{$gitlab_kn_root}/#{$accounts_gitlab_repo}", :branch => 'master'
    #pod "PIARegionsModule", :git => "#{$git_root}/#{$regions_repo}"
    pod "PIARegionsModule", :git => "#{$gitlab_kn_root}/#{$regions_gitlab_repo}", :branch => 'master'
    #pod "PIACSIModule", :git => "#{$git_root}/#{$csi_repo}"
    pod "PIACSIModule", :git => "#{$gitlab_kn_root}/#{$csi_gitlab_repo}", :branch => 'master'
    pod "PIAKPIModule", :git => "#{$gitlab_kn_root}/#{$kpi_gitlab_repo}", :commit => '3e2c385'

    #library_by_path('')
    #library_by_git('')
    #library_by_gitlab_branch('')
    library_by_gitlab_by_git('3fcc450')
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
    pod 'Popover'
end

def tunnel_pods
    pod 'TunnelKit', :git => 'https://github.com/pia-foss/tunnelkit', :branch => 'master'
    pod 'OpenSSL-Apple', :git => 'https://github.com/keeshux/openssl-apple'
end

def piawireguard_pod
    pod 'PIAWireguard', :git => "#{$git_root}/pia-wireguard"
end

def piawireguard_gitlab_pod
    pod 'PIAWireguard', :git => "#{$gitlab_vpn_root}/pia-wireguard.git", :commit => '7e9d8d48'
end

# Targets

target 'PIA VPN' do
    app_pods
end

target 'PIA VPN dev' do
    app_pods
    #only use the following pods for internal (non-public) builds
    pod 'Firebase/Core', '6.5.0'
    pod 'Crashlytics'
    pod 'Fabric'
end

target 'PIA VPN Tunnel' do
    tunnel_pods
end

target 'PIA VPN WG Tunnel' do
    #piawireguard_pod
    piawireguard_gitlab_pod
end

target 'PIA VPNTests' do
    app_pods
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
