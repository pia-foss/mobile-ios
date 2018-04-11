desc "Run unit tests"
lane :unit_test do
    #ensure_git_status_clean
    cocoapods
    scan
end
