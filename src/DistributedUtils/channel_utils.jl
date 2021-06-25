function chunckedChannel(f::Function, 
    iter, chuncksize::Int, 
    ChT::Type = Any, buffsize::Int = nthreads(); 
    chkwargs...
)
return Channel{ChT}(buffsize; chkwargs...) do _Ch
    chunk = eltype(iter)[]
    for itelm in iter
        push!(chunk, f(itelm))
        if length(chunk) == chuncksize
            put!(_Ch, chunk)
            chunk = eltype(iter)[]
        end
    end
    !isempty(chunk) && put!(_Ch, chunk)
    return nothing
end
end
chunckedChannel(iter, chuncksize::Int; kwargs...) = 
chunckedChannel(identity, iter, chuncksize; kwargs...)

# ------------------------------------------------------------
function threadchannel(fun::Function, Ch::Channel; 
        nthrs::Int = nthreads(),
        skipth::Function = (thid) -> false,
    )

    @threads for _ in 1:nthrs
        thid = threadid()
        (skipth(thid) == true) && continue

        for dat in Ch
            flag = fun(thid, dat)
            flag == :break && break
            flag == :continue && continue
            flag == :return && return
        end
    end
end