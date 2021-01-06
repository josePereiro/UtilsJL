# Based in DrWatson

const GIT_COMMIT_KEY = :gitcommit
const GIT_PATCH_KEY = :gitpatch
const DIRTY_SUFFIX = "_dirty"
const SHORT_HASH_LENGTH = 7
const ERROR_LOGGER = SimpleLogger(stdout, Logging.Error)

function load_data(src_file; print_fun = println, verbose = true)
    file_dat = wload(src_file)
    data = file_dat[DATA_KEY]
    commit_hash = get(file_dat, GIT_COMMIT_KEY, nothing)
    verbose && print_fun(
        relpath(src_file), " loaded, size: ", filesize(src_file), " bytes", 
        isnothing(commit_hash) ? "" : string(", commit: ", cut_hash(commit_hash))
    )
    return data
end

function save_data(src_file, data; verbose = true, print_fun = println, tagsave_kwargs...)
    L = verbose ? global_logger() : ERROR_LOGGER
    with_logger(L) do
        data = tagsave(src_file, Dict(DATA_KEY => data); tagsave_kwargs...)
        verbose && print_fun(relpath(src_file), " saved!!!, size: ", filesize(src_file), " bytes")
        return data
    end
end

load_commit_hash(src_file) = get(wload(src_file), GIT_COMMIT_KEY, "")

load_commit_short_hash(src_file, l = SHORT_HASH_LENGTH) = cut_hash(load_commit_hash(src_file), l)

function cut_hash(commit_hash, l = SHORT_HASH_LENGTH)
    short_hash = first(commit_hash, l)
    endswith(commit_hash, DIRTY_SUFFIX) ? string(short_hash, DIRTY_SUFFIX) : short_hash
end

load_patch(src_file) = get(wload(src_file), GIT_PATCH_KEY, "")
