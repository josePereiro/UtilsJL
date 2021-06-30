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

function Base.iterate(chnk::IterChunck)
    # @info("At Base.iterate(chnk::IterChunck)"); println()
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
    # @info("At Base.iterate(chnk::IterChunck, state)", state) 
    (c >= chnk.len) && return nothing
    iterret = iterate(chnk.iter, last_iterstate)
    # @info("iterate(chnk.iter, last_iterstate)", iterret) 
    isnothing(iterret) && error(
        "Chunk `len` is invalid, `iter` finished in ", c, 
        " iterations but `len` = ", chnk.len
    )
    elem, iterstate = iterret
    # println()
    return (elem, (iterstate, c + 1))
end

## ------------------------------------------------------
# general implementation needs to make a full iteration
function chunks(chnkend::Function, iter)

    state0 = nothing
    last_state = nothing
    count = 0
    next = iterate(iter)
    hasnext(x...) = !isnothing(next)
    geniter = Iterators.takewhile(hasnext, Iterators.countfrom())
    return Base.Generator(geniter) do _

        while true
            (elem, state) = next
            isend = chnkend(elem, state, count)
            isend && iszero(count) && error(
                "chnkend(elem, state, count)::Bool should not return false if count == 0"
            )

            # new chunk
            if isend
                chnk = IterChunck(iter, state0, count)
                state0 = last_state
                count = 0
                return chnk
            end

            count += 1 
            last_state = state
            next = iterate(iter, state)

            # last chunk
            if isnothing(next) && !iszero(count)
                chnk = IterChunck(iter, state0, count)
                return chnk
            end    
        end

    end
end

## ------------------------------------------------------
# Providing layout
function _resolve_layout(iter, chnklen, nchnks)

    SizeType = Base.IteratorSize(iter)

    # Check iter
    (SizeType isa Base.IsInfinite) && error("Infinite iterators can't be chunked")
    
    # Layout not specified
    ((chnklen <= 0) && (nchnks <= 0)) && 
        error("You must provide a layout (e.g. chnklen). Use ?chunks for details")

    
    if (SizeType isa Base.SizeUnknown)
        # A chnklen must be provided
        (chnklen <= 0) &&  error("You must provide a chnklen if the iterator has unknown length")
    elseif (chnklen <= 0)
        # chnklen missing but computable
        iterlen = length(iter)
        chnklen = div(iterlen, nchnks)
        while (nchnks * chnklen) < iterlen; chnklen += 1; end
    else
        # nchnks missing but computable
        iterlen = length(iter)
        nchnks = div(iterlen, chnklen)
        while (nchnks * chnklen) < iterlen; nchnks += 1; end
    end

    return (;chnklen, nchnks)
end

_get_default_ischnkend(chnklen) = (elem, state, count) -> (chnklen == count)

## ------------------------------------------------------------------
# general implementation needs to make a full iteration
function chunks(iter; chnklen::Int = -1, nchnks::Int = -1)
    chnklen, _ = _resolve_layout(iter, chnklen, nchnks)
    chnkend = _get_default_ischnkend(chnklen)
    return chunks(chnkend, iter)
end

## ------------------------------------------------------
# For the AbstractArray interface `view` is used for performance
_chnkrange(iter::AbstractArray, chnki, chnklen, iterlen) = 
    (chnki*chnklen + firstindex(iter)):min(iterlen, (chnki*chnklen + chnklen))
function chunks(iter::AbstractArray; 
        chnklen::Int = -1, nchnks::Int = -1
    )
    
    chnklen, nchnks = _resolve_layout(iter, chnklen, nchnks)
    
    iterlen = length(iter)
    state0 = nothing
    Base.Generator(0:(nchnks - 1)) do chnki
        chnkrange = _chnkrange(iter, chnki, chnklen, iterlen)
        chnkleni = length(chnkrange)
        iteri = view(iter,chnkrange)
        IterChunck(iteri, state0, chnkleni)
    end
end

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