function _walkdown(f, root; keepout, onerr, kwargs...) 
    content = readdir(root)
    for name in content
        
        path = joinpath(root, name)
        val = try; f(path)
            catch err; onerr(path, err) 
        end
        (val === true) && return val

        # recursive call
        if isdir(path)
            keepout(path) && continue
            val = _walkdown(f, path; keepout, onerr)
            (val === true) && return val 
        end
    end
end

function _walkdown_th(f, root; 
        keepout, nths, onerr
    ) 

    
    # init engine
    in_waiting_zone = trues(nths)
    dir_ch = Channel{String}(Inf)
    put!(dir_ch, root)

    @threads for _ in 1:nths
        thid = threadid()
        
        for curr_dir in dir_ch
            in_waiting_zone[thid] = false

            iput = false
            content = readdir(curr_dir)
            for name in content
                path = joinpath(curr_dir, name)

                val = try
                    (f(path) === true) && (close(dir_ch); return)
                    iput = isdir(path) && !keepout(path) && isopen(dir_ch)
                    iput && put!(dir_ch, path)
                catch err
                    (onerr(path, err) === true) && (close(dir_ch); return)
                end
            end

            # check some
            in_waiting_zone[thid] = true
            !iput && isempty(dir_ch) && all(in_waiting_zone) && (close(dir_ch); return)
        end
    end
end

"""
`walkdown_th(f, root; keepout = (dir) -> false, th = false)`

walkdown the file tree applaying `f` to all the founded paths.
The return value of `f` is consider a break flag, so if it returns `true`
the walk if over.
`keepout` is a filter that disallows walks a dir if returns `true`.
If `th` if `true` a threaded version is run.
This method do not waranty thread safetiness in any of it call
backs, `f` or `keepout`. You must do it for yourself.

"""
function walkdown(f::Function, root; 
        keepout = (dir) -> false, 
        onerr = (path, err) -> rethrow(err),
        th = false, nths = nthreads()
    ) 
    fun = th ? _walkdown_th : _walkdown
    fun(f, root; keepout, onerr, nths)
    return nothing
end



## ------------------------------------------------------------------------------------
function _filtertree(f, root; kwargs...)
    founds = String[]
    walkdown(root; kwargs..., th = false) do path
        f(path) && let
            push!(founds, path)
        end
        false
    end
    founds
end

function _filtertree_th(f, root; nths, kwargs...)
    founds_pool = [String[] for i in 1:7]
    walkdown(root; kwargs..., th = true) do path 
        f(path) && let
            push!(founds_pool[threadid()], path)
        end
        false
    end
    vcat(founds_pool...)
end

function filtertree(f::Function, root; 
        keepout = (dir) -> false, th = false,
        onerr = (path, err) -> rethrow(onerr),
        nths = nthreads()
    ) 
    fun = th ? _filtertree_th : _filtertree
    fun(f, root; th, keepout, onerr, nths)
end
