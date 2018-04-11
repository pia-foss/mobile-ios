lane :try_qa_changelog do
    gitlab_issues
    changelog_from_gitlab_issues(
        project: "https://foobar.example"
    )
    debug
end
