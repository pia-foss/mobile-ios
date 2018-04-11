lane :try_deserialize do
    deserialize_archive_metadata(
        json: "dist/test.json"
    )
    debug
    #slack_build(
    #    changelog: "This is a changelog"
    #)
end
