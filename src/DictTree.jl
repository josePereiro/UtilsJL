## -------------------------------------------------------------------
struct DictTree
    dict::Dict{Any, Any}
    DictTree() = new(Dict())
    DictTree(args) = new(Dict(args))
end

## -------------------------------------------------------------------
Base.haskey(pd::DictTree, k) = haskey(pd.dict, k)
Base.get!(pd::DictTree, k, d) = get!(pd.dict, k, d)

## -------------------------------------------------------------------
ITERABLE = Union{AbstractVecOrMat, AbstractRange}
_extract_keys(k, ks...) = tuple([ki isa ITERABLE ? ki : [ki] for ki in tuple(k, ks...)]...)
_get_dict!(d::Dict, k) = (haskey(d, k) && d[k] isa Dict) ? d[k] : (d[k] = Dict{Any, Any}())

Base.getindex(pd::DictTree, k::ITERABLE) = [pd.dict[ki] for ki in k]
function Base.getindex(pd::DictTree, k, ks...) 
    if isempty(ks) 
        getindex(pd.dict, k)
    else
        cartesian = Iterators.product(_extract_keys(k, ks...)...) |> collect |> vec
        dat = []
        for kis in cartesian
            dati = pd.dict
            for ki in kis; dati = dati[ki]; end
            push!(dat, dati)
        end
        length(cartesian) == 1 ? first(dat) : dat
    end
end

## -------------------------------------------------------------------
function Base.setindex!(pd::DictTree, v, k, ks...) 
    if isempty(ks) 
        setindex!(pd.dict, v, k)
    else
        cartesian = Iterators.product(_extract_keys(k, ks...)...) |> collect |> vec
        for kis in cartesian
            d = pd.dict
            for ki in kis[begin:end - 1]
                d = _get_dict!(d, ki)
            end
            setindex!(d, v, last(kis))
        end
    end
end
