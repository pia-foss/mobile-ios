desc "Bootstrap QA process, sync with master and commit MR id"
lane :qa_bootstrap do |options|
    branch = options[:branch]
    raise "Must specify branch" unless branch
    mr = UI.input("Enter the id of the GitLab merge request where to drive the QA discussion:")
    mr_path = ENV["GITLAB_CHANGELOG_DISCUSSION_PATH"]

    ensure_git_status_clean
    orig = git_branch
    sh "git fetch origin master:master"
    sh "git checkout #{branch}"
    sh "git merge master"
    sh "echo #{mr} > ../#{mr_path}"
    git_commit(
        path: mr_path,
        message: "[ci-skip] Bootstrap QA"
    )
    push_to_git_remote
    sh "git checkout #{orig}"
end
