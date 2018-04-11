lane :try_serialize do
    serialize_archive_metadata(
        json: "dist/test.json",
        app_name: "TestApp",
        version_number: "1.2.3",
        build_number: 12345,
        issues: {
            1 => "One",
            2 => "Two",
            3 => "Three"
        },
        url: "https://www.google.com"
    )
end
