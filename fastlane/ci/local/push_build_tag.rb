desc "Push a deterministic build tag"
lane :push_build_tag do |options|
    prefix = options[:prefix]
    raise "Must specify prefix" unless prefix
    behind = options[:behind].to_i

    unless options[:branch].nil?
        ensure_git_branch(
            branch: options[:branch]
        )
    end

    suffix = UI.input("Optional suffix after version number:")
    version_n = get_version_number
    msg = "#{version_n} #{suffix}"

    ref = "HEAD~#{behind}"
    get_build_number
    build_n = deterministic_build_number(
        to: ref
    )
    tag_name = "#{prefix}/#{build_n}"
    add_git_tag(
        commit: ref,
        tag: tag_name,
        message: msg
    )
    push_git_tags
end
