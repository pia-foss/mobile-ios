lane :try_build_number do
    get_build_number
    increment_build_number(
        build_number: deterministic_build_number
    )
end
