## ----------------------------------------------------------------------------
# GLOBALS
const GLOBALS = Dict()
const CFNAME_EXT = ".cache.jls"
const DATA_KEY = :dat
 
function _init_globals()
    empty!(GLOBALS)
    GLOBALS[:CACHE_DIR] = pwd()
    GLOBALS[:VERBOSE] = true
end

# TODO: Use Caching.jl
## ----------------------------------------------------------------------------
set_cache_dir(cache_dir::String) = (GLOBALS[:CACHE_DIR] = cache_dir)
get_cache_dir() = GLOBALS[:CACHE_DIR]
set_verbose(verbose::Bool) = (GLOBALS[:VERBOSE] = verbose)
get_verbose() = GLOBALS[:VERBOSE]
set_fileid(fileid) = (GLOBALS[:FILEID] = string(fileid))
get_fileid() = GLOBALS[:FILEID]

function is_cfname(fname)
    fname = basename(fname)
    !isvalid_dfname(fname) && return false
    return endswith(fname, CFNAME_EXT)
end

function cfname(arg, args...)
    _hash = hash(hash.((arg, args...)))
    cfile = dfname((;hash = _hash), CFNAME_EXT)
    cache_dir = get_cache_dir()
    return joinpath(cache_dir, cfile)
end
function cfname(cfile::String)
    cfile = basename(cfile)
    cfile = is_cfname(cfile) ? cfile : cfname(cfile)
    cache_dir = get_cache_dir()
    return joinpath(cache_dir, cfile)
end

cfname(;kwargs...) = cfname(tempname(); kwargs...)

## ----------------------------------------------------------------------------
function scache(dat, cfile::String; 
        headline = "CACHE SAVED",
        verbose = get_verbose(), 
        onerr::Function = (err) -> rethrow(err), 
        print_fun = println
    )

    cfile = cfname(cfile)

    try
        serialize(cfile, Dict(DATA_KEY => dat))
        verbose && print_fun(headline, 
            "\ncache_file: ", relpath(cfile),
            "\nsize: ", filesize(cfile), " bytes",
            "\ndata type: ", typeof(dat),
            "\n"
        )
    catch err
        verbose && print_fun("ERROR SAVING CACHE\n", 
            "\ncache_file: ", relpath(cfile), 
            "\n", err_str(err),
            "\n"
        )
        onerr(err)
    end
    return cfile
end

function scache(dat, arg, args...; kwargs...) 
    cfile = joinpath(get_cache_dir(), cfname(arg, args...))
    scache(dat, cfile; kwargs...)
end

scache(f::Function, arg, args...; kwargs...) = 
    scache(f(), arg, args...; kwargs...)

scache(dat; kwargs...) = scache(dat, tempname(), rand(); kwargs...)
scache(f::Function; kwargs...) = scache(f(); kwargs...)

## ----------------------------------------------------------------------------
function _lcache(f::Function, cfile::String, savecache::Bool = true; 
        headline = "CACHE LOADED",
        verbose = get_verbose(), 
        onerr::Function = (err) -> rethrow(err),
        print_fun = println
    )
    
    cfile = cfname(cfile)
    try
        if isfile(cfile)
            dat = deserialize(cfile)[DATA_KEY]
        else
            dat = f()
            savecache && scache(dat, cfile; 
                verbose, onerr, print_fun
            )
        end

        verbose && print_fun(headline, 
                "\ncache_file: ", relpath(cfile),
                "\nsize: ", filesize(cfile), " bytes",
                "\ndata type: ", typeof(dat), 
                "\n"
            )

        return dat
    catch err
        verbose && print_fun("ERROR LOADING CACHE\n", 
                "\ncache_file: ", relpath(cfile), 
                "\n", err_str(err),
                "\n"
            )

        return onerr(err)
    end
end

lcache(f::Function, cfile::String; kwargs...) = _lcache(f, cfile, true; kwargs...) 
function lcache(f::Function, arg, args...; kwargs...) 
    cfile = cfname(arg, args...)
    lcache(f, cfile; kwargs...)
end
function lcache(dflt::Vector, arg, args...; kwargs...)
    length(dflt) != 1 && error("The first arg::Vector must be just a container.")
    _lcache(() -> dflt, hashtable, true; kwargs...)
end

lcache(cfile::String; kwargs...) = _lcache(() -> nothing, cfile, false; kwargs...)
lcache(arg, args...; kwargs...) = lcache(cfname(arg, args...); kwargs...)

## ----------------------------------------------------------------------------
function delcache(cfile::String)
    tcache_file = cfname(cfile)
    rm(tcache_file; force = true, recursive = true)
end
delcache(arg, args...) = delcache(cfname(arg, args...))

function delcache(;verbose = get_verbose(), print_fun = println)
    cache_dir = get_cache_dir()
    tcaches = filter(is_cfname, readdir(cache_dir))
    for tc in tcaches
        tc = joinpath(cache_dir, tc)
        rm(tc, force = true)
        verbose && print_fun(relpath(tc), " deleted!!!")
    end
end

## ----------------------------------------------------------------------------
exist_cache(arg, args...) = isfile(cfname(arg, args...))
    
## ----------------------------------------------------------------------------
function backup_cachedir(backup_dir = string(get_cache_dir(), "_backup"))
    cache_dir = get_cache_dir()
    tcaches = filter(is_cfname, readdir(cache_dir))
    !isdir(backup_dir) && mkpath(backup_dir)
    for file in tcaches
        src_file, dest_file = joinpath(cache_dir, file), joinpath(backup_dir, file)
        isfile(dest_file) && mtime(src_file) < mtime(dest_file) && continue
        cp(src_file, dest_file; force = true, follow_symlinks = true)
    end
end