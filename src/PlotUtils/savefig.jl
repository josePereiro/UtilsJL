function sfig(p, args...)
    file = dfname(args...)
    Plots.savefig(p, file)
    return file
end

function sfig(ps::Vector, args...; 
        layout = _auto_layout(length(ps)), 
        margin = 10
    )
    grid = make_grid(ps; layout, margin)
    file = dfname(args...)
    FileIO.save(file, grid)
    return file
end
