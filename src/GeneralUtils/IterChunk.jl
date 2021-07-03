## ------------------------------------------------------
struct IterChunck{T}
    iter::T
    state0
    len::Int
    
    function IterChunck(iter, state0, len::Int) 
        len < 0 && error("`len` >= 0 expected, got", len)
        new{typeof(iter)}(iter, state0, len)
    end
    IterChunck(iter, len::Int = length(iter)) = IterChunck(iter, nothing, len)
end

Base.eltype(chnk::IterChunck) = eltype(chnk.iter)
Base.length(chnk::IterChunck) = chnk.len
axes(chnk::IterChunck) = axes(chnk.iter)

function Base.iterate(chnk::IterChunck)
    (chnk.len == 0) && return nothing
    iterret = isnothing(chnk.state0) ? 
        iterate(chnk.iter) : iterate(chnk.iter, chnk.state0)
    isnothing(iterret) && error(
        "Chunk `len` is invalid, `iter` finished ",
        "iterations but `len` = ", chnk.len
    )
    elem, iterstate = iterret
    return (elem, (iterstate, 1))
end

function Base.iterate(chnk::IterChunck, state) 
    (last_iterstate, c) = state
    (c >= chnk.len) && return nothing
    iterret = iterate(chnk.iter, last_iterstate)
    isnothing(iterret) && error(
        "Chunk `len` is invalid, `iter` finished in ", c, 
        " iterations but `len` = ", chnk.len
    )
    elem, iterstate = iterret
    return (elem, (iterstate, c + 1))
end

## ------------------------------------------------------------
# general implementation needs to make a full iteration
function _chunk(chunkend::Function, iter, state0 = nothing)

    last_state = state0
    chnklen = 0
    next = isnothing(state0) ? iterate(iter) : iterate(iter, state0)
    while true
        (elem, state) = next
        isend = chunkend(elem, state, chnklen)
        isend && iszero(chnklen) && error(
            "chunkend(elem, state, chnklen)::Bool should not ", 
            "return false if chnklen == 0"
        )

        # new chunk
        if isend
            chnk = IterChunck(iter, state0, chnklen)
            state0 = last_state
            chnklen = 0
            return (chnk, last_state, true)
        end

        chnklen += 1 
        last_state = state
        next = iterate(iter, state)

        # last chunk
        if isnothing(next) && !iszero(chnklen)
            chnk = IterChunck(iter, state0, chnklen)
            return (chnk, last_state, false)
        end    
    end

end

## ------------------------------------------------------------
chunk(chunkend::Function, iter) = 
    first(_chunk(chunkend, iter, nothing))

## ------------------------------------------------------------
function chunks(chnkend::Function, iter, state0 = nothing)

    last_state = state0
    hasnext = true
    geniter = Iterators.takewhile((_)->hasnext, Iterators.countfrom())
    return Base.Generator(geniter) do _
        chk, last_state, hasnext = _chunk(chnkend, iter, last_state)
        return chk
    end
end

## ------------------------------------------------------
# Providing layout
function _resolve_layout(iter, chnklen, nchnks)

    SizeType = Base.IteratorSize(iter)

    # Check iter
    (SizeType isa Base.IsInfinite) && 
        error("Infinite iterators can't be chunked")
    
    # Layout not specified
    (chnklen <= 0) && (nchnks <= 0) && 
        error("You must provide a layout (e.g. chnklen). Use ?chunks for details")
    
    
    # A chnklen must be provided
    if (SizeType isa Base.SizeUnknown)
        (chnklen <= 0) && error("You must provide a chnklen if the iterator has unknown length")
        return Iterators.repeated(chnklen)
    end 
    
    # Known size iters
    iterlen = length(iter)
    if (nchnks >= 0)
        # nchnks missing but computable
        homo = div(iterlen, nchnks)
        iszero(homo) && (nchnks = iterlen)
        chnklens = fill(homo, nchnks)
        for chnki in eachindex(chnklens)
            (sum(chnklens) == iterlen) && break
            chnklens[chnki] += 1
        end
        return (len for len in chnklens)
    else
        # chnklen missing but computable
        nchnks = div(iterlen, chnklen)
        while (nchnks * chnklen) < iterlen; nchnks += 1; end
        return Iterators.repeated(chnklen, nchnks)
    end
end

_chnklen_reached_end(chnklen::Int) = 
    (elem, state, count::Int) -> (chnklen == count)

## ------------------------------------------------------------------
# general implementation needs to make a full iteration
chunk(iter, chnklen::Int) = chunk(_chnklen_reached_end(chnklen), iter)

function chunks(iter; 
        chnklen::Int = -1, nchnks::Int = -1
    )

    layout = _resolve_layout(iter, chnklen, nchnks)
    chnklen, layout_state = iterate(layout)

    last_state = nothing
    hasnext = true
    geniter = Iterators.takewhile((_)->hasnext, Iterators.countfrom())
    return Base.Generator(geniter) do _
        ret = _chunk(iter, last_state) do elem, state, count
            chnklen == count
        end
        chk, last_state, hasnext = ret
        
        itert = iterate(layout, layout_state)
        !isnothing(itert) && ((chnklen, layout_state) = itert)
        return chk
    end
end

## ------------------------------------------------------
# For the AbstractArray interface `view` is used for performance
function _chunk(iter::AbstractArray, chnklen::Int, idx0)
    
    state0 = nothing
    iterlen = length(iter)
    idx1 = min(iterlen, idx0 + chnklen - 1)
    iteri = view(iter, idx0:idx1)
    return IterChunck(iteri, state0, length(iteri))
end

chunk(iter::AbstractArray, chnklen::Int) = _chunk(iter, chnklen, firstindex(iter))

function chunks(iter::AbstractArray; 
        chnklen::Int = -1, nchnks::Int = -1
    )

    layout = _resolve_layout(iter, chnklen, nchnks)

    chnkidx0 = firstindex(iter)
    Base.Generator(layout) do chnklen

        chk = _chunk(iter, chnklen, chnkidx0)
        chnkidx0 += length(chk)

        return chk
    end
end


## ------------------------------------------------------
# For the ProductIterator `chunk` is used and a new ProductIterator
# is formulated

## ------------------------------------------------------
function chunkedChannel(iter;
        chnklen::Int = -1, nchnks::Int = -1,
        buffsize::Int = Base.Threads.nthreads(),
        chkwargs...
    )

    chunkgens = chunks(iter; chnklen, nchnks)
    return Channel{eltype(chunkgens)}(buffsize; chkwargs...) do _Ch
        for chunk in chunkgens
            put!(_Ch, chunk)
        end
    end
end