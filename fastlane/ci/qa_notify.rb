desc "Post a new QA build attachment to Slack"
lane :qa_notify do
    deserialize_archive_metadata
    changelog_from_gitlab_issues
    slack_build
end
