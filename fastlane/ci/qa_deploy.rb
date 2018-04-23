desc "Submit a QA build to HockeyApp"
lane :qa_deploy do
    get_ipa_metadata
    gitlab_issues
    changelog_from_gitlab_issues
    hockey
    print_ipa_metadata(
        prefix: "Deployed"
    )
    serialize_archive_metadata(
        url: lane_context[SharedValues::HOCKEY_DOWNLOAD_LINK]
    )
end
