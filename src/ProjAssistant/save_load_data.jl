# Based in DrWatson

const GIT_COMMIT_KEY = :gitcommit
const GIT_PATCH_KEY = :gitpatch
const DIRTY_SUFFIX = "_dirty"
const SHORT_HASH_LENGTH = 7
const ERROR_LOGGER = SimpleLogger(stdout, Logging.Error)

function ldat(dfargs...; print_fun = println, verbose = true)
    src_file = dfname(dfargs...)
    file_dat = wload(src_file)
    dat = file_dat[DATA_KEY]
    commit_hash = get(file_dat, GIT_COMMIT_KEY, "")
    verbose && print_fun(
        relpath(src_file), " loaded, size: ", filesize(src_file), " bytes, ", 
        string("commit: ", _cut_hash(commit_hash))
    )
    return dat
end
function ldat(f::Function, dfargs...; kwargs...)
    src_file = dfname(dfargs...)
    !isfile(src_file) && sdat(f(), src_file; kwargs...)
    ldat(src_file; kwargs...)
end

function sdat(f::Function, dfargs...; 
        verbose = true, print_fun = println, 
        tagsave_kwargs...
    )
    dat = f()
    src_file = dfname(dfargs...)
    L = verbose ? global_logger() : ERROR_LOGGER
    with_logger(L) do
        dat = tagsave(src_file, Dict(DATA_KEY => dat); tagsave_kwargs...)
        verbose && print_fun(relpath(src_file), " saved!!!, size: ", filesize(src_file), " bytes")
        return dat
    end
end
sdat(dat, dfargs...; kwargs...) = sdat(() -> dat, dfargs...; kwargs...) 

function dhash(src_file, l = SHORT_HASH_LENGTH) 
    hash = get(wload(src_file), GIT_COMMIT_KEY, "")
    _cut_hash(hash, l)
end

function _cut_hash(commit_hash, l = SHORT_HASH_LENGTH)
    short_hash = first(commit_hash, l)
    endswith(commit_hash, DIRTY_SUFFIX) ? string(short_hash, DIRTY_SUFFIX) : short_hash
end

load_patch(src_file) = get(DW.wload(src_file), GIT_PATCH_KEY, "")
