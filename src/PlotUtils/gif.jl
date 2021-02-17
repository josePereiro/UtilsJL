## ----------------------------------------------------------------------------
function plot_to_img(p::AbstractPlot; ext = "png", clear = true)
    fn = string(tempname(), ".", ext)
    try
        savefig(p, fn)
        return FileIO.load(fn)
    finally
        clear && rm(fn; force = true)
    end
end

## ----------------------------------------------------------------------------
function _make_mat(imgs)
    length(unique!(size.(imgs))) != 1 && error("All imgs must have the same size")
    
    w, h = size(first(imgs))
    d = length(imgs)
    img_mat = Array{RGB{N0f8}}(undef, w, h, d)
    @views for (i, img) in enumerate(imgs)
        img_mat[:, :, i] = img[:, :]
    end
    img_mat
end

## ----------------------------------------------------------------------------
_def_fn() = string(tempname(), ".gif")
function save_gif(imgs::Vector, fn::String = _def_fn(); 
        fps = 10.0
    ) 
    !endswith(fn, ".gif") && error("filename must end with .gif")
    mat = _make_mat(imgs)
    imgs = nothing # save memory ?
    FileIO.save(fn, mat; fps)
    fn
end

function save_gif(ps::Vector{T}, fn::String = _def_fn(); 
        fps = 10.0
    ) where {T<:AbstractPlot}
    
    imgs = plot_to_img.(ps)
    save_gif(imgs, fn; fps)
end

function save_gif(sourcepaths::Vector{String}, fn::String = _def_fn(); 
        fps = 10.0
    ) 
    imgs = FileIO.load.(sourcepaths)
    save_gif(imgs, fn; fps)
end

save_gif(fn::String, dat; fps = 10.0) = save_gif(dat, fn; fps)

## ----------------------------------------------------------------------------
function make_group_gif(keystone, sourcedir::String; 
        filter = (filename) -> true, 
        sortby = (x) -> x,
        destdir = sourcedir,
        verbose = true
    )

    figs = group_files(keystone, sourcedir; filter)
    gifs = []
    for ((name, params), files_dict) in figs
        gifname = DW.savename(name, params, "gif")
        giffile = joinpath(destdir, gifname)
        ks = sort(collect(keys(files_dict)); by = sortby)
        paths = [files_dict[k] for k in ks]

        save_gif(paths, giffile; fps = 3.0)
        verbose && @info("Gif produced", gifname)
        push!(gifs, giffile)
    end
    gifs
end