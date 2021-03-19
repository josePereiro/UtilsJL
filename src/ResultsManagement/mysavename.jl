function mysavename(name, ext = ""; c...)
    d = Dict{Symbol, Any}(c)
    for (k, v) in d
        if v isa AbstractFloat
            d[k] = abs(log10(abs(v))) > 3 ? sci(v) : v
        end
    end
    DW.savename(name, d, ext)
end
