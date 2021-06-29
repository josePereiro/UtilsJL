"""
    Give the percent [0-1] of zero elements
"""
sparsity(col::AbstractArray{<:Number}) = float(count(iszero, col) / length(col))

logspace(start, stop, n = 50; base = 10.0) = base.^range(start, stop, length = n)

"""
    Returns a new dict with symbol keys. 
    It will share the source data.
"""
function to_symbol_dict(src_dict::Dict)
    dict = Dict()
    for (k, dat) in src_dict
        dict[Symbol(k)] = dat
    end
    return dict
end

"""
    Returns dict with symbol keys. 
    It will share the source object data.
"""
function struct_to_dict(obj::T) where T
    dict = Dict()
    for f in fieldnames(T)
        dict[f] = getproperty(obj, f)
    end
    return dict
end

"""
    give the error text as string
"""
function err_str(err; max_len = 10000)
    s = sprint(showerror, err, catch_backtrace())
    return length(s) > max_len ? s[1:max_len] * "\n[...]" : s
end

function get!push!(d; kwargs...)
    for (k, val) in kwargs
        push!(get!(d, k, []), val)
    end
    d
end