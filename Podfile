source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

# Libraries

$library_pod = 'PIALibrary'
$library_subspecs = [
    'Library',
    'UI',
    'Mock',
    'VPN'
]
$library_url = "https://github.com/pia-foss/client-library-apple"

$tunnel_pod = 'PIATunnel'
$tunnel_url = "https://github.com/pia-foss/tunnel-apple"

def library_by_path(root)
    $library_subspecs.each { |name|
        pod "#{$library_pod}/#{name}", :path => "#{root}/client-library-apple"
    }
end

def library_by_git(sha)
    $library_subspecs.each { |name|
        pod "#{$library_pod}/#{name}", :git => $library_url, :commit => sha
    }
end

def library_by_version(version)
    $library_subspecs.each { |name|
        pod "#{$library_pod}/#{name}", "~> #{version}"
    }
end

def tunnel_by_path(root)
    pod $tunnel_pod, :path => "#{root}/tunnel-apple"
end

def tunnel_by_git(sha)
    pod $tunnel_pod, :git => $tunnel_url, :commit => sha
end

def tunnel_by_version(version)
    pod $tunnel_pod, "~> #{version}"
end

# Pod groups

def shared_main_pods
    pod 'AlamofireImage'
    #library_by_path('..')
    library_by_git('89185a0')
    #library_by_version('1.0')
end

def app_pods
    shared_main_pods
    pod 'iRate'
    pod 'TPKeyboardAvoiding'
    pod 'SideMenu', '= 3.1.5'
    pod 'FXPageControl'
    pod 'MBProgressHUD'
end

def tunnel_pods
    #tunnel_by_path('..')
    tunnel_by_git('f6963ed')
    #tunnel_by_version('1.0')
end

# Targets

target 'PIA VPN' do
    app_pods
end

target 'PIA VPN dev' do
    app_pods
    pod 'HockeySDK'
end

target 'PIA VPN Tunnel' do
    tunnel_pods
end
