const GIT_COMMIT_KEY = :gitcommit
const GIT_PATCH_KEY = :gitpatch
const DIRTY_SUFFIX = "_dirty"

export load_data, save_data, wload, wsave, load_commit_hash, load_commit_short_hash, load_patch

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
    data = tagsave(src_file, Dict(DATA_KEY => data); tagsave_kwargs...)
    verbose && print_fun(relpath(src_file), " saved!!!, size: ", filesize(src_file), " bytes")
    return data
end

load_commit_hash(src_file) = get(wload(src_file), GIT_COMMIT_KEY, "")

load_commit_short_hash(src_file, l = 7) = cut_hash(load_commit_hash(src_file), l)

function cut_hash(commit_hash, l = 7)
    if endswith(commit_hash, DIRTY_SUFFIX)
        commit_hash = commit_hash[1:min(7, end)] * DIRTY_SUFFIX
    elseif !isempty(commit_hash)
        commit_hash = commit_hash[1:min(7, end)]
    end
    commit_hash
end

load_patch(src_file) = get(wload(src_file), GIT_PATCH_KEY, "")
