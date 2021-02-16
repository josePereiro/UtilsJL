function group_files(keystone, dir; 
        filter = (filename) -> true
    )
    files = Dict()
    for filename in readdir(dir) |> sort
        name, params, ext = DW.parse_savename(filename)
        filter(filename) && continue

        !haskey(params, keystone) && continue
        keystone_val = params[keystone]
        delete!(params, keystone)

        f = get!(files, (name, params), Dict())
        f[keystone_val] = joinpath(dir, filename)
    end
    files
end