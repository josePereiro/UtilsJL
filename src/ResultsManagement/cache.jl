const TEMP_CACHE_FILE_PREFIX = "temp_cache"
CACHE_DIR = pwd()
const DATA_KEY = :dat

set_cache_dir(cache_dir) = (global CACHE_DIR = cache_dir)

is_temp_cache_file(file) = startswith(file, TEMP_CACHE_FILE_PREFIX)
 
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

function load_cache(hashtable, dflt = nothing; 
        cache_dir = CACHE_DIR, 
        headline = "CACHE LOADED",
        verbose = true, onerr::Function = (err) -> rethrow(err),
        print_fun = tagprintln_inmw)

    data = dflt
    tcache_file = temp_cache_file(hashtable, cache_dir) |> relpath
    !isfile(tcache_file) && return data
    
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

function backup_temp_cache(cache_dir, backup_dir = cache_dir * "_backup")
    files = readdir(cache_dir)
    !isdir(backup_dir) && mkpath(backup_dir)
    for file in files
        !is_temp_cache_file(file) && continue
        src_file, dest_file = joinpath(cache_dir, file), joinpath(backup_dir, file)
        isfile(dest_file) && mtime(src_file) < mtime(dest_file) && continue
        cp(src_file, dest_file; force = true, follow_symlinks = true)
    end
end