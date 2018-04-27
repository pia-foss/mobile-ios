lane :try_ipa do
    get_ipa_metadata(
        ipa: "dist/pia-vpn.ipa"
    )
    debug
end
