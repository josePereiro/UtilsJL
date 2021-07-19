## ----------------------------------------------------------------------------
# GLOBALS
const GLOBALS = Dict()
const CFNAME_EXT = ".cache.jls"
const DATA_KEY = :dat

function _init_globals()
    empty!(GLOBALS)
    GLOBALS[:CACHE_DIR] = pwd()
    GLOBALS[:VERBOSE] = false
    GLOBALS[:PRINT_FUN] = Base.println
end

## ----------------------------------------------------------------------------
set_cache_dir(cache_dir::String) = (GLOBALS[:CACHE_DIR] = cache_dir)
get_cache_dir() = GLOBALS[:CACHE_DIR]
set_verbose(verbose::Bool) = (GLOBALS[:VERBOSE] = verbose)
get_verbose() = GLOBALS[:VERBOSE]
set_fileid(fileid) = (GLOBALS[:FILEID] = string(fileid))
get_fileid() = GLOBALS[:FILEID]
get_print_fun() = GLOBALS[:PRINT_FUN]
set_print_fun(pf::Function) = (GLOBALS[:PRINT_FUN] = pf)