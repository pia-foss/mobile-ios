desc "Archive a new build for Beta testing"
lane :create_beta_archive do
    #ensure_git_status_clean
    sh "cd .. && rm -rf Pods/SideMenu"
    cocoapods(try_repo_update_on_error: true)
    sh "cd .. && git apply ci/0001-Close-menu-on-rotation.patch"

    get_build_number
    increment_build_number(
        build_number: deterministic_build_number
    )
    match
    gym(output_directory: "apple_dist")
    print_ipa_metadata(
        prefix: "Archived"
    )
end
