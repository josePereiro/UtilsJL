const TEMP_CACHE_FILE_PREFIX = "temp_cache"
CACHE_DIR = pwd()
DATA_KEY = :dat

set_cache_dir(cache_dir) = (global CACHE_DIR = cache_dir)

temp_cache_file(hashtable, cache_dir = CACHE_DIR, ext = ".jld") = 
    joinpath(cache_dir, string(TEMP_CACHE_FILE_PREFIX, "___", hash(hashtable), ext))


function save_cache(hashtable, data; cache_dir = CACHE_DIR, headline = "CACHE SAVED",
        verbose = true, onerr::Function = (err) -> rethrow(err), 
        print_fun = tagprintln_inmw)

    tcache_file = temp_cache_file(hashtable, cache_dir) |> relpath
    try
        serialize(tcache_file, Dict(DATA_KEY => data))
        verbose && print_fun(headline, 
                "\ncache_file: ", tcache_file,
                "\nsize: ", filesize(tcache_file), " bytes",
                "\ndata type: ", typeof(data),
                "\n"
            )
    catch err
        verbose && print_fun("ERROR SAVING CACHE\n", 
                "\ncache_file: ", tcache_file, 
                "\n", err_str(err),
                "\n"
            )

        onerr(err)
    end
end    

function load_cache(hashtable; cache_dir = CACHE_DIR, headline = "CACHE LOADED",
        verbose = true, onerr::Function = (err) -> rethrow(err),
        print_fun = tagprintln_inmw)

    tcache_file = temp_cache_file(hashtable, cache_dir) |> relpath
    !isfile(tcache_file) && return nothing
    
    data = nothing
    try
        data = deserialize(tcache_file)[DATA_KEY]
        verbose && print_fun(headline, 
                "\ncache_file: ", tcache_file,
                "\nsize: ", filesize(tcache_file), " bytes",
                "\ndata type: ", typeof(data), 
                "\n"
            )
    catch err
        verbose && print_fun("ERROR LOADING CACHE\n", 
                "\ncache_file: ", tcache_file, 
                "\n", err_str(err),
                "\n"
            )

        onerr(err)
    end
    return data
end    

function delete_temp_caches(cache_dir = CACHE_DIR; verbose = true, print_fun = println_inmw)
    tcaches = filter(file -> startswith(file, TEMP_CACHE_FILE_PREFIX), readdir(cache_dir))
    for tc in tcaches
        tc = joinpath(cache_dir, tc)
        rm(tc, force = true)
        verbose && print_fun(relpath(tc), " deleted!!!")
    end
end
