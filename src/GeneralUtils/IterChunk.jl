## ------------------------------------------------------
struct IterChunck{T}
    iter::T
    state0
    len::Int
    
    IterChunck(iter, state0, len) = 
        new{typeof(iter)}(iter, state0, len)
    IterChunck(iter, len) = IterChunck(iter, nothing, len)
end
Base.eltype(::IterChunck{T}) where {T} = eltype(T)
Base.eltype(chnk::IterChunck) = eltype(chnk.iter)
Base.length(chnk::IterChunck) = chnk.len
function Base.iterate(chnk::IterChunck) 
    (chnk.len <= 0 ) && return nothing
    elem, iterstate = isnothing(chnk.state0) ? 
        iterate(chnk.iter) : 
        iterate(chnk.iter, chnk.state0)
    return (elem, (iterstate, 1))
end
function Base.iterate(chnk::IterChunck, state) 
    (last_iterstate, c) = state
    (c >= chnk.len) && return nothing
    elem, iterstate = iterate(chnk.iter, last_iterstate)
    return (elem, (iterstate, c + 1))
end

## ------------------------------------------------------
function chuncks(filter::Function, iter; chnk_size::Int)

    chnks = IterChunck{typeof(iter)}[]
    state0 = nothing
    last_state = nothing
    len = 0
    next = iterate(iter)
    while next !== nothing
        (elem, state) = next
        toinclude = filter(elem, len)
        if toinclude && iszero(len)
            # new chunk
            len += 1
            state0 = last_state
        elseif toinclude && len == (chnk_size - 1)
            # force end
            len += 1
            chnk = IterChunck(iter, state0, len)
            push!(chnks, chnk)
            len = 0
        elseif toinclude && len < chnk_size
            # inside a chunk
            len += 1
        elseif !toinclude && !iszero(len)
            # force end2
            chnk = IterChunck(iter, state0, len)
            push!(chnks, chnk)
            len = 0
        end
        last_state = state
        next = iterate(iter, state)
    end
    # last chnk
    if !iszero(len)
        chnk = IterChunck(iter, state0, len)
        push!(chnks, chnk)
    end

    chnks
end
chuncks(iter, chnk_size::Int) = chuncks((elem, len) -> true, iter, chnk_size)

# get a collection and returns an array of chuncks
function _resolve_layout(iterlen, chnklen, nchnks)
    if (chnklen == -1)
        chnklen = div(length(iter), nchnks)
        while (nchnks * chnklen) < iterlen; chnklen += 1; end
    else
        nchnks = div(iterlen, chnklen)
        while (nchnks * chnklen) < iterlen; nchnks += 1; end
    end
    return chnklen, nchnks
end

function chuncks(iter::Vector; 
        chnklen::Int = -1, nchnks::Int = -1
    )
    ((chnklen <= 0) && (nchnks <= 0)) && return [iter]
    iterlen = length(iter)
    chnklen, nchnks = _resolve_layout(iterlen, chnklen, nchnks)

    _chnkis(i) = (i*chnklen + 1):min(iterlen, (i*chnklen + chnklen))
    return [iter[_chnkis(i)] for i in 0:(nchnks - 1)]
end
