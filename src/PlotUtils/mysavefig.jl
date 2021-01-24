function mysavefig(p, pname, dir; params...)
    pname = mysavename(pname, "png"; params...)
    fname = joinpath(dir, pname)
    savefig(p, fname)
    fname
end

function mysavefig(ps::Vector, pname, dir; 
        layout = _auto_layout(length(ps)), 
        margin = 10, params...
    )
    pname = mysavename(pname, "png"; params...)
    fname = joinpath(dir, pname)
    grid = make_grid(ps; layout, margin)
    FileIO.save(fname, grid)
    fname
end