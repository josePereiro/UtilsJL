function get_ticks(f::Function, values; l = length(values))
    idxs = unique(floor.(Int, range(1, length(values); length = l)))
    values = values[idxs]
    values, f.(values)
end
