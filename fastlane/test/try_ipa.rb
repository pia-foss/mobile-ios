lane :try_ipa do
    get_ipa_version(
        ipa: "dist/pia-vpn.ipa"
    )
    debug
end
