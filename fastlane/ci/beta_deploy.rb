desc "Submit a Beta build to TestFlight"
lane :beta_deploy do
    changelog_from_beta
    pilot(
        beta_app_description: lane_context[SharedValues::FL_CHANGELOG]
    )
    print_ipa_metadata(
        prefix: "Deployed"
    )
end
