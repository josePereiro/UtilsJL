export load_data, save_data

function load_data(src_file; print_fun = println, verbose = true)
    data = wload(src_file)[DATA_KEY]
    verbose && print_fun(relpath(src_file), " loaded!!!, size: ", filesize(src_file), " bytes")
    return data
end

function save_data(src_file, data; verbose = true, print_fun = println, tagsave_kwargs...)
    data = tagsave(src_file, Dict(DATA_KEY => data); tagsave_kwargs...)
    verbose && print_fun(relpath(src_file), " saved!!!, size: ", filesize(src_file), " bytes")
    return data
end
