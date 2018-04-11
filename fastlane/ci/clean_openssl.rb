desc "Uncache OpenSSL pod to force rebuilding"
lane :clean_openssl do
    sh "rm -rf Pods"
    clean_cocoapods_cache(
        name: "OpenSSL-Apple"
    )
end
