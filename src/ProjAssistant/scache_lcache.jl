## ----------------------------------------------------------------------------
# GLOBALS
const GLOBALS = Dict()
const CFNAME_EXT = ".cache.jls"
const DATA_KEY = :dat

function _init_globals()
    empty!(GLOBALS)
    GLOBALS[:CACHE_DIR] = pwd()
    GLOBALS[:VERBOSE] = true
    GLOBALS[:PRINT_FUN] = Base.println
end

# TODO: Use Caching.jl
## ----------------------------------------------------------------------------
set_cache_dir(cache_dir::String) = (GLOBALS[:CACHE_DIR] = cache_dir)
get_cache_dir() = GLOBALS[:CACHE_DIR]
set_verbose(verbose::Bool) = (GLOBALS[:VERBOSE] = verbose)
get_verbose() = GLOBALS[:VERBOSE]
set_fileid(fileid) = (GLOBALS[:FILEID] = string(fileid))
get_fileid() = GLOBALS[:FILEID]
get_print_fun() = GLOBALS[:PRINT_FUN]
set_print_fun(pf::Function) = (GLOBALS[:PRINT_FUN] = pf)

## ----------------------------------------------------------------------------
function is_cfname(fname)
    fname = basename(fname)
    !isvalid_dfname(fname) && return false
    head, params, ext = parse_dfname(fname)
    return isempty(head) && length(params) == 1 && 
        haskey(params, "hash") && (ext == CFNAME_EXT)
end

## ----------------------------------------------------------------------------
function cfname(arg, args...)

    isempty(args) && (arg isa AbstractString) && 
        is_cfname(arg) && return basename(arg)
    
    _hash = hash(hash.((arg, args...)))
    cfile = dfname((;hash = _hash), CFNAME_EXT)
    return cfile
end

cfname() = cfname(rand(), tempname())

## ----------------------------------------------------------------------------
function scache(dat, dirs::Vector{<:AbstractString}, arg, args...; 
        headline::AbstractString = "CACHE SAVED",
        verbose::Bool = get_verbose(), 
        onerr::Function = (err) -> rethrow(err), 
        print_fun::Function = get_print_fun(), 
        mkdir::Bool = false
    )

    cfile = cfname(arg, args...)
    cfile = joinpath(dirs..., cfile)
    try
        mkdir && mkpath(dirname(cfile))
        serialize(cfile, Dict(DATA_KEY => dat))
        verbose && _io_print(print_fun, headline, dat, cfile)
    catch err
        verbose && _io_error_print(print_fun, err, cfile)
        onerr(err)
    end
    return cfile
end

# defaults
scache(dat, arg, args...; kwargs...) = 
    scache(dat, [get_cache_dir()], arg, args...; kwargs...)
    
scache(f::Function, arg, args...; kwargs...) = 
    scache(f(), [get_cache_dir()], arg, args...; kwargs...)

scache(dat; kwargs...) = 
    scache(dat, [get_cache_dir()], time(), rand(); kwargs...)

scache(f::Function; kwargs...) = 
    scache(f(), [get_cache_dir()], time(), rand(); kwargs...)

## ----------------------------------------------------------------------------
function _lcache(f::Function, savecache::Bool, cfile::String; 
        headline::AbstractString = "CACHE LOADED",
        verbose::Bool = get_verbose(), 
        onerr::Function = (err) -> rethrow(err),
        print_fun::Function = get_print_fun(), 
        mkdir::Bool = false
    )
    try
        mkdir && mkpath(dirname(cfile))
        dat = isfile(cfile) ? deserialize(cfile)[DATA_KEY] : f()
        savecache && scache(dat, cfile; verbose, onerr, print_fun)
        verbose && _io_print(print_fun, headline, dat, cfile)
        return dat
    catch err
        @info cfile
        verbose && _io_error_print(print_fun, err, cfile)
        return onerr(err)
    end
end

function lcache(f::Function, dirs::Vector{<:AbstractString}, arg, args...; 
        kwargs...
    ) 
    cfile = cfname(arg, args...)
    cfile = joinpath(dirs..., cfile)
    _lcache(f, true, cfile; kwargs...)
end

lcache(f::Function, arg, args...; kwargs...) = 
    lcache(f::Function, [get_cache_dir()], arg, args...; kwargs...)

function lcache(dirs::Vector{<:AbstractString}, arg, args...; kwargs...) 
    cfile = cfname(arg, args...)
    cfile = joinpath(dirs..., cfile)
    _lcache(() -> nothing, false, cfile; kwargs...)
end

lcache(arg, args...; kwargs...) = 
    lcache([get_cache_dir()], arg, args...; kwargs...)

## ----------------------------------------------------------------------------
function delcache(dirs::Vector{<:AbstractString}, arg, args...; 
        verbose::Bool = get_verbose(), 
        print_fun::Function = get_print_fun()
    )
    cfile = cfname(arg, args...)
    cfile = joinpath(dirs..., cfile)
    rm(cfile; force = true, recursive = true)
    verbose && print_fun(relpath(cfile), " deleted!!!")
    return cfile
end

delcache(arg, args...; kwargs...) = 
    delcache([get_cache_dir()], arg, args...; kwargs...)

function delcache(dirs::Vector{<:AbstractString};
        verbose::Bool = get_verbose(), 
        print_fun::Function = get_print_fun()
    )
    cache_dir = joinpath(dirs...)
    tcaches = filter(is_cfname, readdir(cache_dir))
    for tc in tcaches
        tc = joinpath(cache_dir, tc)
        rm(tc, force = true)
        verbose && print_fun(relpath(tc), " deleted!!!")
    end
    return cache_dir
end

delcache(; kwargs...) = delcache([get_cache_dir()]; kwargs...)

## ----------------------------------------------------------------------------
function exist_cache(dirs::Vector{<:AbstractString}, arg, args...)
    cfile = cfname(arg, args...)
    cfile = joinpath(dirs..., cfile)
    isfile(cfile)
end
exist_cache(arg, args...) = exist_cache([get_cache_dir()], arg, args...)
    
## ----------------------------------------------------------------------------
function backup_cachedir(;
        cache_dir::AbstractString = get_cache_dir(),
        backup_dir::AbstractString = string(cache_dir, "_backup")
    )
    tcaches = filter(is_cfname, readdir(cache_dir))
    !isdir(backup_dir) && mkpath(backup_dir)
    for file in tcaches
        src_file, dest_file = joinpath(cache_dir, file), joinpath(backup_dir, file)
        isfile(dest_file) && mtime(src_file) < mtime(dest_file) && continue
        cp(src_file, dest_file; force = true, follow_symlinks = true)
    end
    return backup_dir
end