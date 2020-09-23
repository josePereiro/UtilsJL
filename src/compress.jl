"""
    Returns a copy of the given data. If possible the object is
    stored in a more compacted type, e.i: array -> sparse
"""
compressed_copy(dat; sparsity_th = 0.66) = 
    dat isa AbstractArray{<:Number} ? 
        sparsity(dat) > sparsity_th ? sparse(dat) : deepcopy(dat) :
        deepcopy(dat)


function compressed_copy(dict::Dict; sparsity_th = 0.66)
    new_dict = Dict()
    for (k, dat) in dict
        new_dict[k] = compressed_copy(dat; sparsity_th = sparsity_th)
    end
    return new_dict
end
        
"""
    Returns a copy of the given data in a less 
    compressed format, e.i: sparse -> array
"""
uncompressed_copy(dat) = deepcopy(dat)
uncompressed_copy(dat::AbstractSparseArray) = dat |> collect


function uncompressed_copy(dict::Dict)
    new_dict = Dict()
    for (k, dat) in dict
        new_dict[k] = uncompressed_copy(dat)
    end
    return new_dict
end